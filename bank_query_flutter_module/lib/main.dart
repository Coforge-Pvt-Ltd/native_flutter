import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'ai_bot_service.dart';
import 'feature/chat/data/repositories/ai_repository_impl.dart';
import 'feature/chat/domain/usecases/ask_ai_question_usecase.dart';
import 'feature/chat/presentation/bloc/ai_assistant_bloc.dart';
import 'feature/chat/presentation/pages/chat_with_ai_page.dart';
import 'feature/home/presentation/pages/home_page.dart';
import 'firebase_options.dart';

// Voice
import 'core/voice/tts_service.dart';
import 'core/voice/speech_service.dart';

// AI core / data
import 'embedding_service.dart';
import 'financial_sync_service.dart';
import 'llm_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = MethodChannel('com.example.bank_query/token');
  String? _token;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initMethodChannel();
  }

  void _initMethodChannel() {
    platform.setMethodCallHandler((call) async {
      if (call.method == "onTokenReceived") {
        final Map<dynamic, dynamic> args = call.arguments;
        setState(() {
          _token = args['token'];
        });
        debugPrint("Successfully received pushed token: $_token");
        
        // Navigate to chat if requested
        if (args['route'] == "/chat") {
          _navigatorKey.currentState?.pushNamed('/chat');
        }
      }
    });
    
    // Also try to get it once on startup
    _handleInitialToken();
  }

  Future<void> _handleInitialToken() async {
    try {
      final String? token = await platform.invokeMethod('getToken');
      if (token != null) {
        setState(() {
          _token = token;
        });
        debugPrint("Received initial token from native: $_token");
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to get initial token: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TtsService>(create: (_) => TtsService()..init()),
        RepositoryProvider<SpeechService>(create: (_) => SpeechService()),
        RepositoryProvider<OpenAiEmbeddingService>(create: (_) => OpenAiEmbeddingService()),
        RepositoryProvider<OpenAIClient>(create: (_) => OpenAIClient()),
        RepositoryProvider<FinancialSyncService>(
          create: (context) => FinancialSyncService(
            embeddingService: context.read<OpenAiEmbeddingService>(),
          ),
        ),
        RepositoryProvider<AiBotServiceWithFirebase>(
          create: (context) => AiBotServiceWithFirebase(
            embeddingService: context.read<OpenAiEmbeddingService>(),
            syncService: context.read<FinancialSyncService>(),
            llmClient: context.read<OpenAIClient>(),
          ),
        ),
        RepositoryProvider<AiRepositoryImpl>(
          create: (context) => AiRepositoryImpl(
            context.read<AiBotServiceWithFirebase>(),
          ),
        ),
        RepositoryProvider<AskAiQuestionUseCase>(
          create: (context) => AskAiQuestionUseCase(
            context.read<AiRepositoryImpl>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AiAssistantBloc>(
            create: (context) => AiAssistantBloc(
              context.read<AskAiQuestionUseCase>(),
            ),
          ),
        ],
        child: MaterialApp(
          navigatorKey: _navigatorKey,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => const HomePage(),
            '/chat': (context) => ChatWithAiPage(token: _token),
          },
        ),
      ),
    );
  }
}

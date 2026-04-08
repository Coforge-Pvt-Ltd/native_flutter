import 'package:bank_query_flutter_module/src/messages.g.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'ai_bot_service.dart';
import 'core/voice/speech_service.dart';

// Voice
import 'core/voice/tts_service.dart';

// AI core / data
import 'embedding_service.dart';
import 'feature/chat/data/repositories/ai_repository_impl.dart';
import 'feature/chat/domain/usecases/ask_ai_question_usecase.dart';
import 'feature/chat/presentation/bloc/ai_assistant_bloc.dart';
import 'feature/chat/presentation/pages/chat_with_ai_page.dart';
import 'feature/home/presentation/pages/home_page.dart';
import 'financial_sync_service.dart';
import 'firebase_options.dart';
import 'llm_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> implements FlutterTokenApi {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final _nativeApi = NativeApi();
  String? _token;

  @override
  void initState() {
    super.initState();
    FlutterTokenApi.setUp(this);
    _handleInitialToken();
  }

  Future<void> _handleInitialToken() async {
    final String? token = await _nativeApi.getToken();
    setState(() {
      _token = token;
    });
  }

  @override
  void onTokenReceived(TokenPayload payload) {
    setState(() {
      _token = payload.token;
    });
    if (payload.route == '/chat') {
      _navigatorKey.currentState?.pushNamed('/chat');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TtsService>(create: (_) => TtsService()..init()),
        RepositoryProvider<SpeechService>(create: (_) => SpeechService()),
        RepositoryProvider<OpenAiEmbeddingService>(
          create: (_) => OpenAiEmbeddingService(),
        ),
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
          create: (context) =>
              AiRepositoryImpl(context.read<AiBotServiceWithFirebase>()),
        ),
        RepositoryProvider<AskAiQuestionUseCase>(
          create: (context) =>
              AskAiQuestionUseCase(context.read<AiRepositoryImpl>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AiAssistantBloc>(
            create: (context) =>
                AiAssistantBloc(context.read<AskAiQuestionUseCase>()),
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

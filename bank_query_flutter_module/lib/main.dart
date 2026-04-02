import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'ai_bot_service.dart';
import 'feature/chat/data/repositories/ai_repository_impl.dart';
import 'feature/chat/domain/usecases/ask_ai_question_usecase.dart';
import 'feature/chat/presentation/bloc/ai_assistant_bloc.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        /// 🔊 Voice services
        RepositoryProvider<TtsService>(
          create: (_) => TtsService()..init(),
        ),
        RepositoryProvider<SpeechService>(
          create: (_) => SpeechService(),
        ),

        /// 🤖 Low‑level AI services
        RepositoryProvider<OpenAiEmbeddingService>(
          create: (_) => OpenAiEmbeddingService(),
        ),
        RepositoryProvider<OpenAIClient>(
          create: (_) => OpenAIClient(),
        ),
        RepositoryProvider<OpenAiEmbeddingService>(
          create: (context) => OpenAiEmbeddingService(
            // service: context.read<OpenAiEmbeddingService>(),
          ),
        ),
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

        /// 📦 Repository (data → domain)
        RepositoryProvider<AiRepositoryImpl>(
          create: (context) => AiRepositoryImpl(
            context.read<AiBotServiceWithFirebase>(),
          ),
        ),

        /// ✅ Use case
        RepositoryProvider<AskAiQuestionUseCase>(
          create: (context) => AskAiQuestionUseCase(
            context.read<AiRepositoryImpl>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          /// 🧠 Single shared AI BLoC
          BlocProvider<AiAssistantBloc>(
            create: (context) => AiAssistantBloc(
              context.read<AskAiQuestionUseCase>(),
            ),
          ),
        ],
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: HomePage(),
        ),
      ),
    );
  }
}


//
// /// -------------------------------
// /// ViewModel
// /// -------------------------------
// class AiChatViewModel extends ChangeNotifier {
//   // UI state
//   String _response = "Upload a PDF and ask a question!";
//   String get response => _response;
//
//   bool _isUploading = false;
//   bool get isUploading => _isUploading;
//
//   bool _isParsing = false;
//   bool get isParsing => _isParsing;
//
//   bool _isIngesting = false;
//   bool get isIngesting => _isIngesting;
//
//   bool _isAnswering = false;
//   bool get isAnswering => _isAnswering;
//
//   String? _currentTopicName;
//   String? get currentTopicName => _currentTopicName;
//
//   // Services
//
//   final GeminiEmbeddingService embeddingService;
//
//   final GeminiClient llmClient;
//
//
//   late final embeddingClient = GeminiEmbeddingClient(
//       service: embeddingService
//   );
//
//   late final syncService = FinancialSyncService(
//       embeddingClient: embeddingClient);
//
//   late final botServiceWithFB = AiBotServiceWithFirebase(
//       embeddingClient: embeddingClient,
//       syncService: syncService,
//       llmClient: llmClient
//
//   );
//
//
//   // Config
//   final String userId;
//
//   AiChatViewModel({
//     required this.userId,
//     GeminiEmbeddingService? embeddingService,
//     GeminiClient? llmClient,
//   })  :
//         embeddingService = embeddingService ?? GeminiEmbeddingService(),
//
//         llmClient = llmClient ?? GeminiClient();
//
//   /// Public API
//
//   Future<void> pickAndIngestPdf() async {
//     try {
//       _setUploading(true);
//
//       final result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: const ['pdf'],
//         withData: true, // ensures bytes are available
//       );
//
//       if (result == null || result.files.isEmpty) {
//         _showInfo("No file selected.");
//         return;
//       }
//
//       final file = result.files.first;
//       final bytes = file.bytes;
//
//       if (bytes == null || bytes.isEmpty) {
//         _showError("Selected file has no data.");
//         return;
//       }
//
//       _currentTopicName = file.name;
//       notifyListeners();
//
//       // Extract text off the UI thread
//       _setParsing(true);
//       final text = await _extractPdfTextIsolate(bytes);
//       _setParsing(false);
//
//       if (text.trim().isEmpty) {
//         _showError("No text found in PDF.");
//         return;
//       }
//
//       // Ingest vectors
//       _setIngesting(true);
//
//
//
//       final data = generate200PolymorphicEntitiesJson();
//
//       final entities = financialEntitiesFromJson(data);
//
//       await syncAllEntities(userId:userId, entities: entities);
//       _setIngesting(false);
//
//       _setResponse(
//         "✅ Ingestion complete for: ${file.name}\n"
//             "You can now ask questions about this document.",
//       );
//     } catch (e, st) {
//       _setParsing(false);
//       _setIngesting(false);
//       _showError("Failed to process PDF: $e");
//       debugPrintStack(label: "pickAndIngestPdf error", stackTrace: st);
//     } finally {
//       _setUploading(false);
//     }
//   }
//
//   List<FinancialEntity> financialEntitiesFromJson(
//       List<Map<String, dynamic>> jsonList,
//       ) {
//     return jsonList
//         .map((json) => FinancialEntity.fromJson(json))
//         .toList();
//   }
//
//   Future<void> syncAllEntities({
//     required String userId,
//     required List<FinancialEntity> entities,
//
//   }) async {
//     final grouped = <String, List<FinancialEntity>>{};
//
//     for (final entity in entities) {
//       grouped.putIfAbsent(entity.collectionName, () => []).add(entity);
//     }
//
//     for (final entry in grouped.entries) {
//       await syncService.syncBulkRecords(
//         userId: userId,
//         entities: entry.value,
//         collectionName: entry.key,
//       );
//     }
//   }
//
//   Future<void> ask(String question) async {
//     final q = question.trim();
//     if (q.isEmpty) {
//       _showInfo("Please enter a question.");
//       return;
//     }
//
//     try {
//       _setAnswering(true);
//       // final answer = await aiBotService.askQuestion(
//       //   q,
//       //   IngestionMetadata(userId: userId),
//       // );
//       final answer = await botServiceWithFB.askQuestion(
//           userId: userId, question: question);
//       _setResponse(answer);
//     } catch (e, st) {
//       _showError("Unable to get an answer: $e");
//       debugPrintStack(label: "ask error", stackTrace: st);
//     } finally {
//       _setAnswering(false);
//     }
//   }
//
//   /// Private helpers
//
//   void _setUploading(bool v) {
//     _isUploading = v;
//     notifyListeners();
//   }
//
//   void _setParsing(bool v) {
//     _isParsing = v;
//     notifyListeners();
//   }
//
//   void _setIngesting(bool v) {
//     _isIngesting = v;
//     notifyListeners();
//   }
//
//   void _setAnswering(bool v) {
//     _isAnswering = v;
//     notifyListeners();
//   }
//
//   void _setResponse(String text) {
//     _response = text;
//     notifyListeners();
//   }
//
//   void _showInfo(String message) {
//     _response = "ℹ️ $message";
//     notifyListeners();
//   }
//
//   void _showError(String message) {
//     _response = "❗ $message";
//     notifyListeners();
//   }
// }
//
// /// Heavy PDF parsing in isolate
// Future<String> _extractPdfTextIsolate(Uint8List bytes) {
//   return compute(_extractPdfText, bytes);
// }
//
// /// Runs in background isolate
// String _extractPdfText(Uint8List bytes) {
//   final document = PdfDocument(inputBytes: bytes);
//   try {
//     // This extracts concatenated text from all pages
//     final text = PdfTextExtractor(document).extractText();
//     return text;
//   } finally {
//     document.dispose();
//   }
// }
//
// /// -------------------------------
// /// UI
// /// -------------------------------
// class AiChatScreen extends StatefulWidget {
//   const AiChatScreen({super.key});
//
//   @override
//   State<AiChatScreen> createState() => _AiChatScreenState();
// }
//
// class _AiChatScreenState extends State<AiChatScreen> {
//   late final AiChatViewModel vm;
//   final TextEditingController _controller = TextEditingController();
//   final FocusNode _inputFocus = FocusNode();
//
//   @override
//   void initState() {
//     super.initState();
//     vm = AiChatViewModel(userId: '8085');
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _inputFocus.dispose();
//     vm.dispose();
//     super.dispose();
//   }
//
//   bool get _busy =>
//       vm.isUploading || vm.isParsing || vm.isIngesting || vm.isAnswering;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Financial PDF Bot"),
//         actions: [
//           if (vm.currentTopicName != null)
//             Padding(
//               padding: const EdgeInsets.only(right: 12),
//               child: Chip(
//                 label: Text(
//                   vm.currentTopicName!,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ),
//         ],
//       ),
//       body: AnimatedBuilder(
//         animation: vm,
//         builder: (context, _) {
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: _busy ? null : vm.pickAndIngestPdf,
//                         icon: const Icon(Icons.upload_file),
//                         label: Text(
//                           vm.isUploading
//                               ? "Selecting file..."
//                               : vm.isParsing
//                               ? "Parsing PDF..."
//                               : vm.isIngesting
//                               ? "Ingesting vectors..."
//                               : "Upload Statement (PDF)",
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 if (_busy) _buildProgressStrip(),
//                 const Divider(height: 24),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: SelectableText(
//                       vm.response,
//                       style: const TextStyle(fontSize: 15),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: _controller,
//                         focusNode: _inputFocus,
//                         enabled: !_busy,
//                         textInputAction: TextInputAction.send,
//                         onSubmitted: (_) => _onSend(),
//                         decoration: InputDecoration(
//                           hintText: "Ask about your PDF...",
//                           border: const OutlineInputBorder(),
//                           suffixIcon: IconButton(
//                             onPressed: _busy ? null : _onSend,
//                             icon: _busy
//                                 ? const SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                               ),
//                             )
//                                 : const Icon(Icons.send),
//                             tooltip: "Send",
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildProgressStrip() {
//     String label = "Working...";
//     if (vm.isUploading) label = "Selecting file…";
//     if (vm.isParsing) label = "Parsing PDF…";
//     if (vm.isIngesting) label = "Ingesting vectors…";
//     if (vm.isAnswering) label = "Thinking…";
//
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surfaceContainerHighest,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Row(
//         children: [
//           const SizedBox(
//             width: 18,
//             height: 18,
//             child: CircularProgressIndicator(strokeWidth: 2),
//           ),
//           const SizedBox(width: 12),
//           Text(label),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _onSend() async {
//     final text = _controller.text;
//     if (text.trim().isEmpty) {
//       _showSnack("Please type a question.");
//       return;
//     }
//     await vm.ask(text);
//     _controller.clear();
//     _inputFocus.requestFocus();
//   }
//
//   void _showSnack(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }
// }
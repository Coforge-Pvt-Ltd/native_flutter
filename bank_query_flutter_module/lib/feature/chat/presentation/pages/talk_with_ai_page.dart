import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../core/utils/image_constant.dart';
import '../bloc/ai_assistant_bloc.dart';
import '../bloc/ai_assistant_event.dart';
import '../bloc/ai_assistant_state.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/empty_chat_widget.dart';

class TalkWithAiPage extends StatefulWidget {
  const TalkWithAiPage({super.key});

  @override
  State<TalkWithAiPage> createState() => _TalkWithAiPageState();
}

class _TalkWithAiPageState extends State<TalkWithAiPage> {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;

  bool _isListening = false;
  bool _requestInProgress = false;
  bool _isAlive = true;

  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    _initTts();
  }

  /// ✅ TTS SETUP (Bloc-aware)
  Future<void> _initTts() async {
    await _tts.setEngine("com.google.android.tts");
    await _tts.setQueueMode(0);

    await _tts.setLanguage("en-GB");
    await _tts.setVoice({
      "name": "en-gb-x-gbg-network",
      "locale": "en-GB",
    });

    await _tts.setSpeechRate(0.50);
    await _tts.setPitch(1.03);
    await _tts.setVolume(1.0);

    /// ✅ WHEN SPEAKING FINISHES → INFORM BLOC
    _tts.setCompletionHandler(() {
      if (!_isAlive) return;
      context.read<AiAssistantBloc>().add(AiStoppedSpeaking());
    });

    _tts.setErrorHandler((msg) {
      debugPrint("❌ TTS error: $msg");
    });
  }

  /// ✅ START LISTENING
  Future<void> _startListening() async {
    if (!_isAlive || _isListening) return;

    await _tts.stop();

    final available = await _speech.initialize(
      onError: (error) {
        if (!_isAlive) return;
        debugPrint('Speech error: ${error.errorMsg}');
      },
    );

    if (!available || !_isAlive) return;

    setState(() => _isListening = true);

    _speech.listen(
      pauseFor: const Duration(seconds: 3),
      partialResults: false,
      onResult: (result) {
        if (!_isAlive || !result.finalResult) return;

        final text = result.recognizedWords.trim();
        if (text.isEmpty) return;

        setState(() => _isListening = false);

        if (_requestInProgress) return;
        _requestInProgress = true;

        context.read<AiAssistantBloc>().add(AskAi(text));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: const BackButton(color: Colors.black),
        title: Row(
          children: [
            Image.asset(ImageConstant.app_icon, height: 28),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "FinAI",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "Always here to help",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),

      /// ✅ LISTEN FOR AI RESPONSE & SPEAK
      body: BlocListener<AiAssistantBloc, AiAssistantState>(
        listener: (context, state) async {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scroll.hasClients) {
              _scroll.animateTo(
                _scroll.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });

          if (!_isAlive) return;

          if (state is AiChatState &&
              !state.isThinking &&
              state.messages.isNotEmpty &&
              !state.messages.last.isUser) {
            _requestInProgress = false;

            final reply = state.messages.last.text;
            final messageIndex = state.messages.length - 1;

            /// ✅ INFORM BLOC WHO IS SPEAKING
            context
                .read<AiAssistantBloc>()
                .add(AiStartedSpeaking(messageIndex));

            await _tts.stop();
            await _tts.speak(reply);
          }
        },
        child: Center(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: BlocBuilder<AiAssistantBloc, AiAssistantState>(
                  builder: (context, state) {
                    final chat = state as AiChatState;

                    if (chat.messages.isEmpty) {
                      return const EmptyChatWidget();
                    }

                    return ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.all(16),
                      itemCount:
                      chat.messages.length + (chat.isThinking ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (chat.isThinking &&
                            index == chat.messages.length) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              "Thinking...",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }

                        final msg = chat.messages[index];

                        return ChatBubble(
                          isUser: msg.isUser,
                          text: msg.text,
                          isSpeaking: !msg.isUser &&
                              index == chat.speakingMessageIndex,
                        );
                      },
                    );
                  },
                ),
              ),

              /// ✅ MIC BUTTON
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: GestureDetector(
                  onTap: _isListening ? null : _startListening,
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: _isListening
                        ? Colors.blue.shade100
                        : Colors.grey.shade200,
                    child: Image.asset(
                      ImageConstant.mic_icon,
                      height: 200,
                      width: 200,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isAlive = false;
    _speech.stop();
    _speech.cancel();
    _tts.stop();
    super.dispose();
  }
}
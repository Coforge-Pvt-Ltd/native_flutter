import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/chat_message.dart';
import '../../domain/usecases/ask_ai_question_usecase.dart';
import 'ai_assistant_event.dart';
import 'ai_assistant_state.dart';

class AiAssistantBloc
    extends Bloc<AiAssistantEvent, AiAssistantState> {

  final AskAiQuestionUseCase askAi;
  static const _platform = MethodChannel('com.example.bank_query/token');

  AiAssistantBloc(this.askAi)
      : super(
    AiChatState(
      messages: [],
      isThinking: false,
      speakingMessageIndex: null,
    ),
  ) {
    on<AskAi>(_onAskAi);
    on<AiStartedSpeaking>(_onAiStartedSpeaking);
    on<AiStoppedSpeaking>(_onAiStoppedSpeaking);
  }

  /// Helper to send logs to Native System Logs page
  void _logToNative(String message) {
    _platform.invokeMethod('sendAppLog', {"message": message});
  }

  Future<void> _onAskAi(
      AskAi event,
      Emitter<AiAssistantState> emit,
      ) async {
    final current = state as AiChatState;

    _logToNative("User: ${event.question}");

    // 1. Add User message and set thinking state
    emit(
      current.copyWith(
        messages: [
          ...current.messages,
          ChatMessage(text: event.question, isUser: true),
        ],
        isThinking: true,
      ),
    );

    try {
      // 2. Call AI UseCase
      final result = await askAi(event.question);
      
      _logToNative("FinAI: ${result.text}");

      // 3. Add AI response and stop thinking
      final updatedCurrent = state as AiChatState;
      emit(
        updatedCurrent.copyWith(
          messages: [
            ...updatedCurrent.messages,
            ChatMessage(text: result.text, isUser: false),
          ],
          isThinking: false,
        ),
      );
    } catch (e) {
      _logToNative("System Error: $e");
      
      final updatedCurrent = state as AiChatState;
      emit(
        updatedCurrent.copyWith(
          isThinking: false,
          messages: [
            ...updatedCurrent.messages,
            ChatMessage(text: "Sorry, I encountered an error. Please try again.", isUser: false),
          ],
        ),
      );
    }
  }

  void _onAiStartedSpeaking(
      AiStartedSpeaking event,
      Emitter<AiAssistantState> emit,
      ) {
    if (state is AiChatState) {
      final current = state as AiChatState;
      emit(
        current.copyWith(
          speakingMessageIndex: event.messageIndex,
        ),
      );
    }
  }

  void _onAiStoppedSpeaking(
      AiStoppedSpeaking event,
      Emitter<AiAssistantState> emit,
      ) {
    if (state is AiChatState) {
      final current = state as AiChatState;
      emit(
        current.copyWith(
          speakingMessageIndex: null,
        ),
      );
    }
  }
}

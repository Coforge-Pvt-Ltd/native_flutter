import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/chat_message.dart';
import '../../domain/usecases/ask_ai_question_usecase.dart';
import 'ai_assistant_event.dart';
import 'ai_assistant_state.dart';

class AiAssistantBloc
    extends Bloc<AiAssistantEvent, AiAssistantState> {

  final AskAiQuestionUseCase askAi;

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

  Future<void> _onAskAi(
      AskAi event,
      Emitter<AiAssistantState> emit,
      ) async {
    final current = state as AiChatState;

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
      // Handle error by stopping thinking and optionally adding an error message
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

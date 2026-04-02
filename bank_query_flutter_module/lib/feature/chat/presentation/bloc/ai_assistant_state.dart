import '../../data/model/chat_message.dart';

abstract class AiAssistantState {}

class AiChatState extends AiAssistantState {
  final List<ChatMessage> messages;
  final bool isThinking;

  /// ✅ NEW: index of AI message currently being spoken
  final int? speakingMessageIndex;

  AiChatState({
    required this.messages,
    required this.isThinking,
    this.speakingMessageIndex,
  });

  /// ✅ REQUIRED for clean Bloc updates
  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isThinking,
    int? speakingMessageIndex,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
      speakingMessageIndex: speakingMessageIndex,
    );
  }
}
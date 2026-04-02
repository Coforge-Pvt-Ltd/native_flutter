abstract class AiAssistantEvent {}

class AskAi extends AiAssistantEvent {
  final String question;
  AskAi(this.question);
}

/// ✅ NEW EVENTS
class AiStartedSpeaking extends AiAssistantEvent {
  final int messageIndex;
  AiStartedSpeaking(this.messageIndex);
}

class AiStoppedSpeaking extends AiAssistantEvent {}

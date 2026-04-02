/// ✅ UI‑only chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  final bool isThinking;
  ChatMessage({
    required this.text,
    required this.isUser,
    this.isThinking = false,
  });
}
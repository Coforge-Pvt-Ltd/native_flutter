import 'package:flutter/material.dart';
import '../../../../core/utils/helper_methods.dart';
import 'typping_text.dart';

class ChatBubble extends StatelessWidget {
  final bool isUser;
  final String text;
  final bool isSpeaking;

  const ChatBubble({
    super.key,
    required this.isUser,
    required this.text,
    required this.isSpeaking,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[200] : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: isUser
            ? Text(text)
            : !isSpeaking
                ? Text(text)
                : TypingText(
                    text: text,
                    charsPerSecond: HelperMethods.estimateCharsPerSecond(0.70), // sync with TTS
                  ),
      ),
    );
  }
}

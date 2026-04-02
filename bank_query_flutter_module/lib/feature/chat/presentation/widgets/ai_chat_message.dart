import 'package:flutter/material.dart';

class AiChatMessage extends StatefulWidget {
  final String message;
  const AiChatMessage({super.key, required this.message});

  @override
  State<AiChatMessage> createState() => _AiChatMessageState();
}

class _AiChatMessageState extends State<AiChatMessage> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 12,
          right: 60, // ✅ GAP FROM RIGHT
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(widget.message, style: const TextStyle(color: Colors.black87)),
      ),
    );
  }
}

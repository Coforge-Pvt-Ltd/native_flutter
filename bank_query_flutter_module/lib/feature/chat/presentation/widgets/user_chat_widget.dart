import 'package:flutter/material.dart';

class UserChatWidget extends StatefulWidget {
  final String message;
  const UserChatWidget({super.key, required this.message});

  @override
  State<UserChatWidget> createState() => _UserChatWidgetState();
}

class _UserChatWidgetState extends State<UserChatWidget> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 14,
          left: 60, // ✅ GAP FROM LEFT
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(widget.message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

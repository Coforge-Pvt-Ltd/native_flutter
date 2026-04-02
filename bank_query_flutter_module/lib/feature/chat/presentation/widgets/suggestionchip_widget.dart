import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/ai_assistant_bloc.dart';
import '../bloc/ai_assistant_event.dart';

Widget SuggestionChip(BuildContext context, String text) {
  return InkWell(
    borderRadius: BorderRadius.circular(30),
    onTap: () {
      context.read<AiAssistantBloc>().add(AskAi(text));
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

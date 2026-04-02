import 'dart:async';
import 'package:flutter/material.dart';


class TypingText extends StatefulWidget {
  final String text;
  final double charsPerSecond;
  final VoidCallback? onCompleted;

  const TypingText({
    super.key,
    required this.text,
    required this.charsPerSecond,
    this.onCompleted,
  });

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> {
  late Timer _timer;
  String _displayedText = '';
  int _index = 0;

  late Duration _interval;

  @override
  void initState() {
    super.initState();
    _interval = Duration(
      milliseconds: (1000 / widget.charsPerSecond).round(),
    );
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(_interval, (timer) {
      if (_index >= widget.text.length) {
        timer.cancel();
        widget.onCompleted?.call();
      } else {
        setState(() {
          _displayedText += widget.text[_index];
          _index++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: const TextStyle(fontSize: 15),
    );
  }
}
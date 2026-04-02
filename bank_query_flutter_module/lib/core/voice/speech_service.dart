import 'dart:ui';

import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  Future<bool> start({
    required Function(String) onResult,
    required VoidCallback onComplete,
  }) async {
    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          onComplete();
        }
      },
    );

    if (!available) return false;

    await _speech.listen(
      pauseFor: const Duration(seconds: 3),
      partialResults: false,
      onResult: (r) => onResult(r.recognizedWords),
    );

    return true;
  }

  Future<void> stop() async {
    await _speech.cancel();
    await _speech.stop();
  }
}
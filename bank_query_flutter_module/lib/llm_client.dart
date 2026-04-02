import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Define your interface (if not already defined elsewhere)
abstract class LlmClient {
  Future<String> generateResponse(String prompt);
}

/// OpenAI client implementation (Updated for Coforge Quasar)
class OpenAIClient implements LlmClient {
  final String apiKey;
  final String model;

  OpenAIClient({
    this.apiKey = "1bb83fa3-7e28-4261-ab66-81b96231d4dc",
    this.model = "gpt-5-chat", // Matches your .env MODEL_NAME
  });

  @override
  Future<String> generateResponse(String prompt) async {
    // UPDATED: Using the v3 TrustAI endpoint from your .env
    final url = Uri.parse("https://quasarmarket.coforge.com/qag/llmrouter-api/v2/chat/completions");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': apiKey, // UPDATED: Changed from Authorization Bearer to X-API-KEY
        },
        body: jsonEncode({
          "model": model,
          "messages": [
            // UPDATED: Content matches your specific curl example template
            {"role": "user", "content": "You are helpful AI. Reply to: $prompt"}
          ],
          "temperature": 0.8, // Added from your spec
          "top_p": 0.9,       // Added from your spec
          "max_tokens": 1000, // Increased from 200 to 1000 per your spec
        }),
      );

      if (kDebugMode) {
        print(" response:${response.toString()}");
      }

      if (response.statusCode != 200) {
        return "Error: API returned ${response.statusCode} - ${response.body}";
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      // Extraction logic remains compatible with standard OpenAI response format
      final List? choices = data['choices'] as List?;
      final String? textResponse = (choices != null && choices.isNotEmpty)
          ? (choices[0]?['message']?['content'] as String?)
          : null;

      return textResponse?.trim().isNotEmpty == true
          ? textResponse!.trim()
          : "Error: No response from AI";
    } catch (e) {
      return "Error: Failed to connect to Quasar API: $e";
    }
  }
}





class GeminiClient implements LlmClient {
  final String apiKey;

  GeminiClient({
    this.apiKey = "AIzaSyDrvcmMEf8sMrvedbPMHO49XhrO3M7rnJk",
  });

  @override
  Future<String> generateResponse(String prompt) async {
    // Using Gemini 3 Flash as specified in your Kotlin code
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent?key=$apiKey",
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode != 200) {
        return "Error: API returned ${response.statusCode} - ${response.body}";
      }

      // Parsing the deep JSON structure
      final Map<String, dynamic> data = jsonDecode(response.body);

      final String? textResponse = data['candidates']?[0]?['content']?['parts']?[0]?['text'];

      return textResponse ?? "Error: No response from AI";

    } catch (e) {
      return "Error: Failed to connect to Gemini API: $e";
    }
  }
}





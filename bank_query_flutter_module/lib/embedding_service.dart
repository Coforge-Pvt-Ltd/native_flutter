import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class EmbeddingService {
  Future<List<double>> embed(String text);
}

class OpenAiEmbeddingService implements EmbeddingService {
  final String apiKey;

  OpenAiEmbeddingService({
     this.apiKey = "1bb83fa3-7e28-4261-ab66-81b96231d4dc",
  });


  @override
  Future<List<double>> embed(String text) async {
    // Use the v2 or v3 endpoint from your .env
    final url = Uri.parse("https://quasarmarket.coforge.com/qag/llmrouter-api/v2/text/embeddings");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': apiKey, // Your API_KEY
        },
        body: jsonEncode({
          "texts": [text],    // Must be a List/Array to match Python's embed_documents
          "dimensions": 736,  // Matches your input requirement
        }),
      );

      // If you get 405 here, try adding a trailing slash to the URL: .../embeddings/
      if (response.statusCode != 200) {
        print("Error Status: ${response.statusCode}");
        print("Error Body: ${response.body}");
        throw Exception("Embedding failed: ${response.body}");
      }
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Matches your Output JSON: { "embeddings": [...] }
      final List<dynamic> values = data['embeddings'];

      return values.cast<double>();
    } catch (e) {
      print("Embedding Service Error: $e");
      rethrow;
    }
  }
}

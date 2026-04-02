import 'dart:async';


import 'embedding_service.dart';
import 'financial_sync_service.dart';
import 'llm_client.dart';

class AiBotServiceWithFirebase {
  final EmbeddingService embeddingService;
  final FinancialSyncService syncService;
  final LlmClient llmClient;

  AiBotServiceWithFirebase({
    required this.embeddingService,
    required this.syncService,
    required this.llmClient,
  });

  /// ✅ This is the final method your UI should call
  Future<String> askQuestion({
    required String userId,
    required String question,
    int topK = 100,
  }) async {
    if (question.trim().isEmpty) {
      throw ArgumentError('Question cannot be empty');
    }

    // 1️⃣ Embed the user question
    final questionEmbedding = await embeddingService.embed(question);

    // 2️⃣ Vector search (server-side via Cloud Function)
    final results = await syncService.searchUserContext(
      userId: userId,
      queryVector: questionEmbedding,
      limit: topK,
    );

    if (results.isEmpty) {
      return "I couldn't find relevant information in your documents.";
    }

    // 3️⃣ Extract context text
    final contexts =
        results
            .map((e) => e['text'] as String?)
            .where((e) => e != null && e.isNotEmpty)
            .cast<String>()
            .toList();

    if (contexts.isEmpty) {
      return "I found related records, but they didn't contain usable text.";
    }

    // 4️⃣ Build RAG prompt
    final prompt = RagPromptBuilder.build(
      question: question,
      contexts: contexts,
    );

    // 5️⃣ Call Gemini LLM ✅
    final answer = await llmClient.generateResponse(prompt);

    return answer.trim();
  }
}

class RagPromptBuilder {
  static String build({
    required String question,
    required List<String> contexts,
  }) {
    final buffer = StringBuffer();

    buffer.writeln("""
You are a professional financial assistant.

You MUST strictly follow these rules:
 
GENERAL RULES
1. Use ONLY the information provided in the CONTEXT retrieved from the database.
2. NEVER assume, infer, or fabricate any data.
3. If any required value for calculation is missing, respond exactly with:
   "I do not have enough information to answer this question."
4. ALWAYS calculate and show exact numeric values.
5. NEVER provide generic answers without numbers.
6. Automatically identify the correct banking use case.
7. If required, call the appropriate tool to retrieve data.
8. Respond ONLY in the output format defined for that use case.
9. If multiple records exist, show calculations for EACH record separately.
10. Do NOT include reasoning steps, explanations, or assumptions.
 
AVAILABLE USE CASES
- Accounts
- Transactions
- Investments
- Subscriptions
- Loans
""");

    buffer.writeln("""
OPTIONAL VISUAL LOGIC (VERY IMPORTANT):

AFTER writing the textual answer:
- DECIDE whether a visual representation is needed.

You MUST include a visual ONLY IF:
- The answer compares multiple numbers, OR
- Breaks down amounts by categories, OR
- Lists more than 3 numeric values.

If a visual is required, append a JSON block at the VERY END of your response
in the following format, and DO NOT add any text after it:

[VISUAL_START]
{
  "type": "pie" | "bar" | "table",
  "data": [
    { "label": "String", "value": number }
  ]
}
[VISUAL_END]

If the answer is a simple fact or yes/no, DO NOT include a visual block.
""");

    buffer.writeln("\n--- CONTEXT START ---");
    for (final ctx in contexts) {
      buffer.writeln(ctx);
      buffer.writeln("---");
    }
    buffer.writeln("--- CONTEXT END ---\n");

    buffer.writeln("Question: $question\n");
    buffer.writeln("Answer:");

    return buffer.toString();
  }
}

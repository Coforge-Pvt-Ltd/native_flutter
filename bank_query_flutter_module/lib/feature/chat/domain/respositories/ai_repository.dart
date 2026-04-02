import '../entities/ai_answer.dart';

abstract class AiRepository {
  Future<AiAnswer> ask(String question);
}
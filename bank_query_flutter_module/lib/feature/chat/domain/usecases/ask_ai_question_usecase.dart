import '../entities/ai_answer.dart';
import '../respositories/ai_repository.dart';

class AskAiQuestionUseCase {
  final AiRepository repository;

  AskAiQuestionUseCase(this.repository);

  Future<AiAnswer> call(String question) {
    return repository.ask(question);
  }
}
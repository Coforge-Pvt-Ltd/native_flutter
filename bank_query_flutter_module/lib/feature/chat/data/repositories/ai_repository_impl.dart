import '../../../../ai_bot_service.dart';
import '../../domain/entities/ai_answer.dart';
import '../../domain/respositories/ai_repository.dart';

class AiRepositoryImpl implements AiRepository {
  final AiBotServiceWithFirebase bot;

  AiRepositoryImpl(this.bot);

  @override
  Future<AiAnswer> ask(String question) async {
    final response =
    await bot.askQuestion(userId: '8085', question: question);
    return AiAnswer(response);
  }
}
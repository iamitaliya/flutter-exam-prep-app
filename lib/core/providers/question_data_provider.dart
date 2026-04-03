import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/question_loader_service.dart';

final questionDataProvider = FutureProvider<QuestionData>((ref) async {
  return QuestionLoaderService.load();
});

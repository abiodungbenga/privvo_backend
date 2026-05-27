enum AIModel {
  gemini,
  deepseek,
}

extension AIModelExtension on AIModel {
  String get value => toString().split('.').last;
}

String aiModelToString(AIModel model) => model.value;

AIModel stringToAIModel(String model) =>
    AIModel.values.firstWhere((e) => e.value == model);

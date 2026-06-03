abstract interface class QuestionnaireRepository {
  Map<String, dynamic> getActiveDefinition();

  int getActiveVersion();
}

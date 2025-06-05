sealed class SurveyFormEvent {}

class LoadSurveyForm extends SurveyFormEvent {
  final String documentName;

  LoadSurveyForm(this.documentName);
}

class GenerateSurveyDocument extends SurveyFormEvent {
  final String documentName;
  final Map<String, dynamic> answers;

  GenerateSurveyDocument(this.documentName, this.answers);
}
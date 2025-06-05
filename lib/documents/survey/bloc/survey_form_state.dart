import '../form_field_model.dart';

sealed class SurveyFormState {}

class SurveyFormInitial extends SurveyFormState {}

class SurveyFormLoading extends SurveyFormState {}

class SurveyFormLoaded extends SurveyFormState {
  final List<FormFieldModel> fields;

  SurveyFormLoaded(this.fields);
}

class SurveyFormError extends SurveyFormState {
  final String error;

  SurveyFormError(this.error);
}

class SurveyFormGenerated extends SurveyFormState {
  final String filePath;

  SurveyFormGenerated(this.filePath);
}
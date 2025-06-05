import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:myapp/documents/survey/bloc/survey_form_event.dart';
import 'package:myapp/documents/survey/bloc/survey_form_state.dart';
import 'package:myapp/documents/survey/form_field_model.dart';
import 'package:myapp/documents/survey/survey_gemini_service.dart';
import 'package:permission_handler/permission_handler.dart';

class SurveyFormBloc extends Bloc<SurveyFormEvent, SurveyFormState> {
  final SurveyGeminiService _surveyGeminiService;

  SurveyFormBloc(this._surveyGeminiService) : super(SurveyFormInitial()) {
    on<LoadSurveyForm>(_onLoadSurveyForm);
    on<GenerateSurveyDocument>(_onGenerateSurveyDocument);
  }

  Future<void> _onLoadSurveyForm(
    LoadSurveyForm event,
    Emitter<SurveyFormState> emit,
  ) async {
    emit(SurveyFormLoading());
    try {
      final formJson = await _surveyGeminiService.fetchFormStructure(event.documentName);
      final formFields = formJson.map((json) => FormFieldModel.fromJson(json)).toList();
      emit(SurveyFormLoaded(formFields));
    } catch (e) {
      emit(SurveyFormError(e.toString()));
    }
  }

  Future<void> _onGenerateSurveyDocument(
    GenerateSurveyDocument event,
    Emitter<SurveyFormState> emit,
  ) async {
    emit(SurveyFormLoading());
    try {
      final documentContent = await _surveyGeminiService.generateDocumentContent(
        event.documentName,
        event.answers,
      );

      // Request storage permission
      var status = await Permission.storage.request(); // Already imported
      if (!status.isGranted) {
        emit(SurveyFormError("Storage permission not granted."));
        return;
      }

      final pdf = pw.Document();
      pdf.addPage(pw.Page(build: (pw.Context context) {
        return pw.Text(documentContent);
      }));
      final downloadsDirectory = await getDownloadsDirectory();
      final legalitoFolder = Directory('${downloadsDirectory!.path}/legalito');
      await legalitoFolder.create(recursive: true);
      final file = File('${legalitoFolder.path}/${event.documentName}.pdf');
      await file.writeAsBytes(await pdf.save());
      emit(SurveyFormGenerated(file.path));
    } catch (e) {
      emit(SurveyFormError(e.toString()));
    }
  }
}


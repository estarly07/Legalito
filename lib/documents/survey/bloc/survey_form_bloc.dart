import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:legalito/documents/survey/bloc/survey_form_event.dart';
import 'package:legalito/documents/survey/bloc/survey_form_state.dart';
import 'package:legalito/documents/survey/form_field_model.dart';
import 'package:legalito/documents/survey/survey_gemini_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

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
      final formJson = await _surveyGeminiService.fetchFormStructure(
        event.documentName,
      );
      final formFields =
          formJson.map((json) => FormFieldModel.fromJson(json)).toList();
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
      // 1. Obtener el contenido desde Gemini
      final documentContent = await _surveyGeminiService
          .generateDocumentContent(event.documentName, event.answers);

      // 2. Crear documento PDF
      final PdfDocument document = PdfDocument();
      PdfPage page = document.pages.add();

      final lines = documentContent.split('\n');
      final regularFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
      final boldFont = PdfStandardFont(PdfFontFamily.helvetica, 12,
          style: PdfFontStyle.bold);

      double y = 0;

      for (String line in lines) {
        if (line.trim().isEmpty) {
          y += 15;
          continue;
        }

        final isBold = line.trim() == line.trim().toUpperCase() ||
            line.trim().startsWith('*');
        final cleanedLine = line.replaceAll('*', '').trim();
        final font = isBold ? boldFont : regularFont;

        page.graphics.drawString(
          cleanedLine,
          font,
          bounds: Rect.fromLTWH(0, y, page.getClientSize().width, 20),
        );

        y += 20;

        // Nueva página si se llena
        if (y > page.getClientSize().height - 40) {
          page = document.pages.add();
          y = 0;
        }
      }

      // 3. Guardar el PDF
      final directory = Directory(event.savePath);
      await directory.create(recursive: true);

      final filePath = '${directory.path}/${event.documentName}.pdf';
      final file = File(filePath);
      final List<int> bytes = await document.save();
      await file.writeAsBytes(bytes);

      document.dispose();

      emit(SurveyFormGenerated(filePath));
    } catch (e) {
      emit(SurveyFormError(e.toString()));
    }
  }
}

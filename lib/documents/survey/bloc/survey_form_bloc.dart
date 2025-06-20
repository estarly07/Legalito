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
      final documentContent =
          await _surveyGeminiService.generateDocumentContent(
        event.documentName,
        event.answers,
      );

      final PdfDocument document = PdfDocument();
      PdfPage page = document.pages.add();

      final regularFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
      final boldFont = PdfStandardFont(PdfFontFamily.helvetica, 14,
          style: PdfFontStyle.bold);
      final titleFont = PdfStandardFont(PdfFontFamily.helvetica, 18,
          style: PdfFontStyle.bold);

      PdfGraphics graphics = page.graphics;
      Size pageSize = page.getClientSize();

      double y = 0;
      final double margin = 20;
      final double contentWidth = pageSize.width - margin * 2;

      final lines = documentContent.split('\n');

      for (String line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) {
          y += 10;
          continue;
        }

        // Detectar firma
        if (trimmed.toLowerCase().startsWith('firma')) {
          final signatureLabel = trimmed;
          final element = PdfTextElement(text: signatureLabel, font: boldFont);
          final result = element.draw(
            page: page,
            bounds: Rect.fromLTWH(margin, y, contentWidth, double.infinity),
          )!;
          y = result.bounds.bottom + 10;

          // Línea punteada
          graphics.drawLine(
            PdfPen(PdfColor(0, 0, 0), dashStyle: PdfDashStyle.dash),
            Offset(margin, y),
            Offset(margin + contentWidth / 2, y),
          );
          y += 30;
          continue;
        }

        // Detectar título o subtítulo
        final isTitle = trimmed == trimmed.toUpperCase() && trimmed.length > 5;
        final isSubTitle =
            trimmed.endsWith(':') || trimmed.split(' ').length <= 4;

        final font = isTitle
            ? titleFont
            : isSubTitle
                ? boldFont
                : regularFont;

        final element = PdfTextElement(text: trimmed, font: font);

        final result = element.draw(
          page: page,
          bounds: Rect.fromLTWH(margin, y, contentWidth, double.infinity),
        )!;

        y = result.bounds.bottom + 10;

        // Nueva página si es necesario
        if (y > pageSize.height - 60) {
          page = document.pages.add();
          graphics = page.graphics;
          y = 0;
        }
      }

      // Guardar PDF
      final directory = Directory(event.savePath);
      await directory.create(recursive: true);

      final filePath = '${directory.path}/${event.documentName}.pdf';
      final file = File(filePath);
      final bytes = await document.save();
      await file.writeAsBytes(bytes);
      document.dispose();

      emit(SurveyFormGenerated(filePath));
    } catch (e) {
      emit(SurveyFormError(e.toString()));
    }
  }
}

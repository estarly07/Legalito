import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:myapp/documents/survey/bloc/survey_form_bloc.dart';
import 'package:myapp/documents/survey/bloc/survey_form_event.dart';
import 'package:myapp/documents/survey/bloc/survey_form_state.dart';
import 'package:myapp/documents/survey/form_field_model.dart';
import 'package:myapp/documents/survey/survey_gemini_service.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class SurveyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final documentName = args?['pushName'] ?? 'default_name';

    return BlocProvider(
      create: (_) => SurveyFormBloc(SurveyGeminiService())
        ..add(LoadSurveyForm(documentName)),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 6),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    color: Colors.white,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.pop(
                            context); // Regresa a la pantalla anterior
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_back,
                          color: Color(0xFFFA4A0C),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "$documentName",
                      maxLines: 2,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 20,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: BlocBuilder<SurveyFormBloc, SurveyFormState>(
          builder: (context, state) {
            if (state is SurveyFormLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is SurveyFormError) {
              return Center(child: Text('Error: ${state.error}'));
            } else if (state is SurveyFormGenerated) {
              return SfPdfViewer.file(
                File(state.filePath),
                key: Key('pdf_preview'),
              );
            } else if (state is SurveyFormLoaded) {
              return _SurveyFormBuilder(
                formFields: state.fields,
                documentName: documentName,
              );
            } else {
              return Center(child: Text('Bienvenido al formulario'));
            }
          },
        ),
      ),
    );
  }
}

class _SurveyFormBuilder extends StatefulWidget {
  final List<FormFieldModel> formFields;
  final String documentName;

  const _SurveyFormBuilder({
    required this.formFields,
    required this.documentName,
  });

  @override
  State<_SurveyFormBuilder> createState() => _SurveyFormBuilderState();
}

class _SurveyFormBuilderState extends State<_SurveyFormBuilder> {
  final Map<String, TextEditingController> controllers = {};

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _styledContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildFormField(FormFieldModel field) {
    switch (field.type) {
      case 'text':
        final controller = controllers[field.label] ??= TextEditingController();
        return _styledContainer(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: field.label,
              border: InputBorder.none,
            ),
          ),
        );
      case 'dropdown':
        String? selected = field.selectedValue;
        return StatefulBuilder(
          builder: (context, setState) {
            return _styledContainer(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: field.label,
                  border: InputBorder.none,
                ),
                value: selected,
                items: field.options
                        ?.map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList() ??
                    [],
                onChanged: (value) {
                  setState(() {
                    selected = value;
                    field.selectedValue = value;
                  });
                },
              ),
            );
          },
        );
      case 'checkbox':
        bool checked = field.checked ?? false;
        return StatefulBuilder(
          builder: (context, setState) {
            return _styledContainer(
              child: CheckboxListTile(
                title: Text(field.label),
                value: checked,
                onChanged: (value) {
                  setState(() {
                    checked = value ?? false;
                    field.checked = checked;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            );
          },
        );
      default:
        return SizedBox.shrink();
    }
  }

  void _saveForm(BuildContext context) async {
    try {
      String? savePath;

      if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        savePath = directory.path;
      } else if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        if (sdkInt >= 30) {
          final dir = await getExternalStorageDirectory();
          savePath = dir?.path;
        } else {
          var status = await Permission.storage.status;
          if (!status.isGranted) {
            status = await Permission.storage.request();
            if (!status.isGranted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Permiso de almacenamiento denegado')),
              );
              return;
            }
          }
          savePath = '/storage/emulated/0/Download/Legalito';
        }
      }

      for (final field in widget.formFields) {
        if (field.type == 'text') {
          field.value = controllers[field.label]?.text ?? '';
        }
      }

      final Map<String, dynamic> answers = {};
      for (final field in widget.formFields) {
        final value = field.value ?? field.selectedValue ?? field.checked;
        answers[field.label] = value;
      }

      context.read<SurveyFormBloc>().add(
            GenerateSurveyDocument(
              widget.documentName,
              answers,
              savePath: savePath!,
            ),
          );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el formulario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: widget.formFields.map(_buildFormField).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _saveForm(context),
        label: Text('Guardar'),
        icon: Icon(Icons.save),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }
}

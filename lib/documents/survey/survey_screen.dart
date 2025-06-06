import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:myapp/documents/survey/bloc/survey_form_bloc.dart';
import 'package:myapp/documents/survey/bloc/survey_form_event.dart';
import 'package:myapp/documents/survey/bloc/survey_form_state.dart';
import 'package:myapp/documents/survey/form_field_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:myapp/documents/survey/survey_gemini_service.dart';

class SurveyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final documentName = args?['pushName'] ?? 'default_name';

    return BlocProvider(
      create:
          (_) =>
              SurveyFormBloc(SurveyGeminiService())
                ..add(LoadSurveyForm(documentName)),
      child: Scaffold(
        appBar: AppBar(title: Text('Dynamic Survey')),
        body: BlocBuilder<SurveyFormBloc, SurveyFormState>(
          builder: (context, state) {
            if (state is SurveyFormLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is SurveyFormError) {
              return Center(child: Text('Error: ${state.error}'));
            } else if (state is SurveyFormGenerated) {
              return Center(
                child: Text('Fue creado el archivo ${state.filePath}'),
              );
            } else if (state is SurveyFormLoaded) {
              return _SurveyFormBuilder(formFields: state.fields);
            } else {
              return Center(child: Text('Welcome to Survey'));
            }
          },
        ),
      ),
    );
  }
}

class _SurveyFormBuilder extends StatefulWidget {
  final List<FormFieldModel> formFields;

  const _SurveyFormBuilder({required this.formFields});

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

  Widget _buildFormField(FormFieldModel field) {
    switch (field.type) {
      case 'text':
        final controller = controllers[field.label] ??= TextEditingController();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: field.label,
              border: OutlineInputBorder(),
            ),
          ),
        );
      case 'dropdown':
        String? selected = field.selectedValue;
        return StatefulBuilder(
          builder:
              (context, setState) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: field.label,
                    border: OutlineInputBorder(),
                  ),
                  value: selected,
                  items:
                      field.options
                          ?.map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      selected = value;
                      field.selectedValue = value;
                    });
                  },
                ),
              ),
        );
      case 'checkbox':
        bool checked = field.checked ?? false;
        return StatefulBuilder(
          builder:
              (context, setState) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                ),
              ),
        );
      default:
        return SizedBox.shrink();
    }
  }

  void _saveForm(BuildContext context, String documentName) async {
    try {
      // Detectar plataforma
      String? savePath;

      if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        savePath = directory.path;
      } else if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        if (sdkInt >= 30) {
          final dir = await getExternalStorageDirectory();
          savePath = '${dir?.path}';
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

      // Guardar valores desde los campos del formulario
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

      // Enviar evento con path de guardado
      context.read<SurveyFormBloc>().add(
        GenerateSurveyDocument(documentName, answers, savePath: savePath!),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el formulario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: widget.formFields.map(_buildFormField).toList(),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              final args =
                  ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>?;
              final documentName = args?['pushName'] ?? 'default_name';
              _saveForm(context, documentName);
            },
            child: Icon(Icons.save),
          ),
        ),
      ],
    );
  }
}

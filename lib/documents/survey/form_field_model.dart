class FormFieldModel {
  final String label;
  final String key;
  final String type;
  final bool required;
  String? value;
  String? selectedValue;
  bool? checked;
  DateTime? dateValue;
  List<String>? options;

  FormFieldModel({
    required this.label,
    required this.key,
    required this.type,
    required this.required,
    this.value,
    this.selectedValue,
    this.checked,
    this.dateValue,
    this.options,
  });

  factory FormFieldModel.fromJson(Map<String, dynamic> json) {
    return FormFieldModel(
      label: json['label'],
      key: json['key'],
      type: json['type'],
      required: json['required'],
      options: (json['options'] as List?)?.cast<String>(),
    );
  }
}

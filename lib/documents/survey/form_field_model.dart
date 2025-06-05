class FormFieldModel {
  final String type;
  final String label;
  final List<String>? options;
  String? selectedValue;
  bool? checked;
  String? value;

  FormFieldModel({
    required this.type,
    required this.label,
    this.options,
    this.selectedValue,
    this.checked,
    this.value,
  });

  factory FormFieldModel.fromJson(Map<String, dynamic> json) {
    return FormFieldModel(
      type: json['type'],
      label: json['label'],
      options: (json['options'] as List?)?.cast<String>(),
      selectedValue: json['selectedValue'],
      checked: json['checked'],
    );
  }
}

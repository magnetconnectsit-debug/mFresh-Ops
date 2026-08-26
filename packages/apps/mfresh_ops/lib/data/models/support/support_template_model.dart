class SupportTemplateModel {
  final int id;
  final String templateName;
  final String description;
  final List<String> subtasks;

  SupportTemplateModel({
    required this.id,
    required this.templateName,
    required this.description,
    this.subtasks = const [],
  });

  factory SupportTemplateModel.fromJson(Map<String, dynamic> json) {
    return SupportTemplateModel(
      id: json['id'] ?? 0,
      templateName: json['template_subject'] ?? '',
      description: json['template_descp'] ?? '',
      subtasks: json['subtasks'] != null ? List<String>.from(json['subtasks']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'template_subject': templateName,
      'template_descp': description,
      'subtasks': subtasks,
    };
  }
}

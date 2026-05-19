class SupportTemplateModel {
  final int id;
  final String templateName;
  final String description;

  SupportTemplateModel({
    required this.id,
    required this.templateName,
    required this.description,
  });

  factory SupportTemplateModel.fromJson(Map<String, dynamic> json) {
    return SupportTemplateModel(
      id: json['id'] ?? 0,
      templateName: json['template_subject'] ?? '',
      description: json['template_descp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'template_subject': templateName,
      'template_descp': description,
    };
  }
}

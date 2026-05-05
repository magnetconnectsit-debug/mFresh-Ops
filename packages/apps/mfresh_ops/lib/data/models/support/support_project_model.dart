class SupportProjectModel {
  final int id;
  final String project;

  SupportProjectModel({
    required this.id,
    required this.project,
  });

  factory SupportProjectModel.fromJson(Map<String, dynamic> json) {
    return SupportProjectModel(
      id: json['id'] ?? 0,
      project: json['project'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project': project,
    };
  }
}

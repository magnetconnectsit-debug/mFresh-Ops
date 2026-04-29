class AssigneeModel {
  final int id;
  final String name;

  AssigneeModel({required this.id, required this.name});

  factory AssigneeModel.fromJson(Map<String, dynamic> json) {
    return AssigneeModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

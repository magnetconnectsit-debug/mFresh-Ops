class UserModel {
  final int id;
  final String name;
  final String role;
  final String email;
  final String mob;
  final String profileImage;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.mob,
    required this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      role: json['role']?.toString() ?? '',
      email: json['email'] ?? '',
      mob: json['mob'] ?? '',
      profileImage: json['profile_image'] ?? '',
    );
  }
}

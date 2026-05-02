import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String? name;
  
  @HiveField(2)
  final String? email;

  @HiveField(3)
  final String? role;

  @HiveField(4)
  final String? mob;

  @HiveField(5)
  final String? profileImage;

  @HiveField(6)
  final List<String>? permissions;

  User({
    required this.id,
    this.name,
    this.email,
    this.role,
    this.mob,
    this.profileImage,
    this.permissions,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? json;
    final List<String> permissions = json['permissions'] != null 
        ? List<String>.from(json['permissions']) 
        : [];

    return User(
      id: userData['id'] is int ? userData['id'] : int.parse(userData['id'].toString()),
      name: userData['name'],
      email: userData['email'],
      role: userData['role']?.toString(),
      mob: userData['mob']?.toString(),
      profileImage: userData['profile_image'],
      permissions: permissions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'mob': mob,
      'profile_image': profileImage,
      'permissions': permissions,
    };
  }
}

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final id = reader.read();
    final name = reader.read();
    final email = reader.read();
    final role = reader.read();
    final mob = reader.read();
    final profileImage = reader.read();
    final permissions = reader.read();

    return User(
      id: id,
      name: name,
      email: email,
      role: role,
      mob: mob,
      profileImage: profileImage,
      permissions: permissions != null ? List<String>.from(permissions) : null,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.email);
    writer.write(obj.role);
    writer.write(obj.mob);
    writer.write(obj.profileImage);
    writer.write(obj.permissions);
  }
}

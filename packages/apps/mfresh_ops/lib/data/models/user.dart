import 'package:hive_ce/hive_ce.dart';

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
  final String? uimage;

  @HiveField(6)
  final List<String>? permissions;

  @HiveField(7)
  final String? securityGroupIds;

  @HiveField(8)
  final int? activeStatus;

  @HiveField(9)
  final String? createdAt;

  @HiveField(10)
  final String? updatedAt;

  @HiveField(11)
  final String? roleName;

  @HiveField(12)
  final int? isOnDuty;

  @HiveField(13)
  final String? deviceId;

  @HiveField(14)
  final Map<dynamic, dynamic>? trackingConfig;

  User({
    required this.id,
    this.name,
    this.email,
    this.role,
    this.mob,
    this.uimage,
    this.permissions,
    this.securityGroupIds,
    this.activeStatus,
    this.createdAt,
    this.updatedAt,
    this.roleName,
    this.isOnDuty,
    this.deviceId,
    this.trackingConfig,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? json;
    final List<String> permissions = [];
    final permissionsSource = json['permissions'] ?? userData['permissions'];
    if (permissionsSource is Map) {
      permissionsSource.forEach((key, value) {
        if (value == true || value == 'true' || value == 1) {
          permissions.add(key.toString());
        }
      });
    } else if (permissionsSource is List) {
      permissions.addAll(List<String>.from(permissionsSource));
    }

    return User(
      id: userData['id'] is int
          ? userData['id']
          : int.parse(userData['id'].toString()),
      name: userData['name'],
      email: userData['email'],
      role: userData['role']?.toString(),
      mob: userData['Mob']?.toString(),
      uimage: userData['uimage'],
      permissions: permissions,
      securityGroupIds: userData['security_group_ids']?.toString(),
      activeStatus: userData['Active_status'] is int
          ? userData['Active_status']
          : int.tryParse(userData['Active_status']?.toString() ?? ''),
      createdAt: userData['created_at'],
      updatedAt: userData['updated_at'],
      roleName: userData['role_name']?.toString(),
      isOnDuty: userData['is_on_duty'] is int
          ? userData['is_on_duty']
          : int.tryParse(userData['is_on_duty']?.toString() ?? ''),
      deviceId: json['device_id']?.toString(),
      trackingConfig: json['tracking_config'] != null
          ? Map<dynamic, dynamic>.from(json['tracking_config'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'Mob': mob,
      'uimage': uimage,
      'permissions': permissions,
      'security_group_ids': securityGroupIds,
      'Active_status': activeStatus,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'role_name': roleName,
      'is_on_duty': isOnDuty,
      'device_id': deviceId,
      'tracking_config': trackingConfig,
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
    final uimage = reader.read();
    final permissions = reader.read();
    final securityGroupIds = reader.read();
    final activeStatus = reader.read();
    final createdAt = reader.read();
    final updatedAt = reader.read();
    dynamic roleName;
    try {
      roleName = reader.read();
    } catch (_) {}

    dynamic isOnDuty;
    try {
      isOnDuty = reader.read();
    } catch (_) {}

    dynamic deviceId;
    try {
      deviceId = reader.read();
    } catch (_) {}

    dynamic trackingConfig;
    try {
      trackingConfig = reader.read();
    } catch (_) {}

    return User(
      id: id,
      name: name,
      email: email,
      role: role,
      mob: mob,
      uimage: uimage,
      permissions: permissions != null ? List<String>.from(permissions) : null,
      securityGroupIds: securityGroupIds,
      activeStatus: activeStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
      roleName: roleName,
      isOnDuty: isOnDuty,
      deviceId: deviceId,
      trackingConfig: trackingConfig,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.email);
    writer.write(obj.role);
    writer.write(obj.mob);
    writer.write(obj.uimage);
    writer.write(obj.permissions);
    writer.write(obj.securityGroupIds);
    writer.write(obj.activeStatus);
    writer.write(obj.createdAt);
    writer.write(obj.updatedAt);
    writer.write(obj.roleName);
    writer.write(obj.isOnDuty);
    writer.write(obj.deviceId);
    writer.write(obj.trackingConfig);
  }
}

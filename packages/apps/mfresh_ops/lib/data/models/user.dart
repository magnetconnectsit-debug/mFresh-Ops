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

  @HiveField(15)
  final String? imageUrl;

  @HiveField(16)
  final int? trackingSessionId;

  @HiveField(17)
  final bool? isCheckedIn;

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
    this.imageUrl,
    this.trackingSessionId,
    this.isCheckedIn,
  });

  // region Factory & Serialization
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

    final attendanceData = userData['attendance'] ?? json['attendance'];
    bool? isCheckedIn;
    if (attendanceData is Map) {
      final rawChecked = attendanceData['is_checked_in'];
      isCheckedIn = rawChecked == true ||
          rawChecked == 1 ||
          rawChecked == '1' ||
          rawChecked == 'true';
    }

    return User(
      id: userData['id'] is int
          ? userData['id']
          : int.parse(userData['id'].toString()),
      name: userData['name']?.toString(),
      email: userData['email']?.toString(),
      role: userData['role']?.toString(),
      mob: userData['Mob']?.toString(),
      uimage: userData['uimage']?.toString(),
      permissions: permissions,
      securityGroupIds: userData['security_group_ids']?.toString(),
      activeStatus: userData['Active_status'] is int
          ? userData['Active_status']
          : int.tryParse(userData['Active_status']?.toString() ?? ''),
      createdAt: userData['created_at']?.toString(),
      updatedAt: userData['updated_at']?.toString(),
      roleName: userData['role_name']?.toString(),
      isOnDuty: userData['is_on_duty'] is int
          ? userData['is_on_duty']
          : int.tryParse(userData['is_on_duty']?.toString() ?? ''),
      deviceId: json['device_id']?.toString() ?? userData['device_id']?.toString(),
      trackingConfig: json['tracking_config'] != null || userData['tracking_config'] != null
          ? Map<dynamic, dynamic>.from(json['tracking_config'] ?? userData['tracking_config'])
          : null,
      imageUrl: userData['image_url']?.toString(),
      trackingSessionId: null, // Ignore from API since it provides stale data, use current-status instead
      isCheckedIn: isCheckedIn,
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
      'is_checked_in': isCheckedIn,
      if (isCheckedIn != null)
        'attendance': {
          'is_checked_in': isCheckedIn,
        },
    };
  }
  // endregion

  // region CopyWith
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? mob,
    String? uimage,
    List<String>? permissions,
    String? securityGroupIds,
    int? activeStatus,
    String? createdAt,
    String? updatedAt,
    String? roleName,
    int? isOnDuty,
    String? deviceId,
    Map<dynamic, dynamic>? trackingConfig,
    String? imageUrl,
    int? trackingSessionId,
    bool? isCheckedIn,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      mob: mob ?? this.mob,
      uimage: uimage ?? this.uimage,
      permissions: permissions ?? this.permissions,
      securityGroupIds: securityGroupIds ?? this.securityGroupIds,
      activeStatus: activeStatus ?? this.activeStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      roleName: roleName ?? this.roleName,
      isOnDuty: isOnDuty ?? this.isOnDuty,
      deviceId: deviceId ?? this.deviceId,
      trackingConfig: trackingConfig ?? this.trackingConfig,
      imageUrl: imageUrl ?? this.imageUrl,
      trackingSessionId: trackingSessionId ?? this.trackingSessionId,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
    );
  }
  // endregion
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

    dynamic imageUrl;
    try {
      imageUrl = reader.read();
    } catch (_) {}

    dynamic trackingSessionId;
    try {
      trackingSessionId = reader.read();
    } catch (_) {}

    dynamic isCheckedIn;
    try {
      isCheckedIn = reader.read();
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
      imageUrl: imageUrl,
      trackingSessionId: trackingSessionId,
      isCheckedIn: isCheckedIn is bool ? isCheckedIn : null,
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
    writer.write(obj.imageUrl);
    writer.write(obj.trackingSessionId);
    writer.write(obj.isCheckedIn);
  }
}

class UserPermissions {
  final List<String> _permissions;
  UserPermissions(this._permissions);

  bool get customerMemberRadio => _permissions.contains('customerMemberRadio');
  bool get scannerAccess => _permissions.contains('scannerAccess');
  bool get userProfileFilter => _permissions.contains('userProfileFilter');
  bool get resendReceiptCustomer => _permissions.contains('resendReceiptCustomer');
  bool get onlineOfflineToggle => _permissions.contains('onlineOfflineToggle');
  bool get externalQr => _permissions.contains('externalQr');
  bool get additionalPhoneNo => _permissions.contains('additionalPhoneNo');
  bool get receiptPrint => _permissions.contains('receiptPrint');
  bool get paymentGateway => _permissions.contains('paymentGateway');
  bool get cashCollectionAccess => _permissions.contains('cashCollectionAccess');
  bool get resetPrint => _permissions.contains('resetPrint');
}

extension UserPermissionsExtension on User {
  UserPermissions get appPermissions => UserPermissions(permissions ?? []);
  String get customeUserID => id.toString(); // Map customUserID to id.toString()
}

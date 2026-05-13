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
  final UserPermissions? appPermissions;

  @HiveField(7)
  final String? customeUserID;

  @HiveField(8)
  final String? unitId;

  User({
    required this.id,
    this.name,
    this.email,
    this.role,
    this.mob,
    this.profileImage,
    this.appPermissions,
    this.customeUserID,
    this.unitId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // 1. Resolve User Data
    Map<String, dynamic> userData;
    if (json['data'] != null && json['data'] is Map && (json['data']['id'] != null || json['data']['user'] != null)) {
      userData = json['data']['user'] != null 
          ? Map<String, dynamic>.from(json['data']['user'])
          : Map<String, dynamic>.from(json['data']);
    } else if (json['user'] != null && json['user'] is Map) {
      userData = Map<String, dynamic>.from(json['user']);
    } else if (json['customer'] != null && json['customer'] is Map) {
      userData = Map<String, dynamic>.from(json['customer']);
    } else {
      userData = json;
    }

    // 2. Resolve Permissions (Handles both top-level and nested structure)
    UserPermissions? appPerms;
    dynamic permsSource = json['permissions'] ?? (json['data'] is Map ? json['data']['permissions'] : null);
    
    if (permsSource is Map) {
      appPerms = UserPermissions.fromJson(Map<String, dynamic>.from(permsSource));
    }

    // 3. Safe ID Parsing
    int resolvedId = 0;
    final dynamic rawId = userData['id'];
    if (rawId != null) {
      if (rawId is int) {
        resolvedId = rawId;
      } else {
        resolvedId = int.tryParse(rawId.toString()) ?? 0;
      }
    }

    return User(
      id: resolvedId,
      name: userData['name']?.toString(),
      email: userData['email']?.toString(),
      role: userData['role']?.toString(),
      mob: userData['mob']?.toString(),
      profileImage: userData['profile_image']?.toString(),
      customeUserID: userData['custome_userID']?.toString(),
      unitId: userData['unitId']?.toString(),
      appPermissions: appPerms,
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
      'custome_userID': customeUserID,
      'unitId': unitId,
      'appPermissions': appPermissions?.toJson(),
    };
  }
}

@HiveType(typeId: 1)
class UserPermissions extends HiveObject {
  @HiveField(0)
  final bool customerMemberRadio;
  @HiveField(1)
  final bool scannerAccess;
  @HiveField(2)
  final bool userProfileFilter;
  @HiveField(3)
  final bool resendReceiptCustomer;
  @HiveField(4)
  final bool onlineOfflineToggle;
  @HiveField(5)
  final bool externalQr;
  @HiveField(6)
  final bool additionalPhoneNo;
  @HiveField(7)
  final bool receiptPrint;
  @HiveField(8)
  final bool paymentGateway;
  @HiveField(9)
  final bool cashCollectionAccess;
  @HiveField(10)
  final bool resetPrint;

  UserPermissions({
    this.customerMemberRadio = false,
    this.scannerAccess = false,
    this.userProfileFilter = false,
    this.resendReceiptCustomer = false,
    this.onlineOfflineToggle = false,
    this.externalQr = false,
    this.additionalPhoneNo = false,
    this.receiptPrint = false,
    this.paymentGateway = false,
    this.cashCollectionAccess = false,
    this.resetPrint = false,
  });

  static bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final s = value.toLowerCase();
      return s == 'true' || s == '1' || s == 'yes';
    }
    return false;
  }

  factory UserPermissions.fromJson(Map<String, dynamic> json) {
    return UserPermissions(
      customerMemberRadio: _toBool(json['customer_member_radio']),
      scannerAccess: _toBool(json['Scanner_access']),
      userProfileFilter: _toBool(json['User_Profile_Filter']),
      cashCollectionAccess: _toBool(json['cash_collection_access']),
      resendReceiptCustomer: _toBool(json['resend_receipt_customer']),
      onlineOfflineToggle: _toBool(json['online_offline_toggle']),
      externalQr: _toBool(json['external_qr']),
      additionalPhoneNo: _toBool(json['additional_phone_no']),
      receiptPrint: _toBool(json['receipt_print']),
      paymentGateway: _toBool(json['payment_gateway']),
      resetPrint: _toBool(json['reset_print']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_member_radio': customerMemberRadio,
      'Scanner_access': scannerAccess,
      'User_Profile_Filter': userProfileFilter,
      'cash_collection_access': cashCollectionAccess,
      'resend_receipt_customer': resendReceiptCustomer,
      'online_offline_toggle': onlineOfflineToggle,
      'external_qr': externalQr,
      'additional_phone_no': additionalPhoneNo,
      'receipt_print': receiptPrint,
      'payment_gateway': paymentGateway,
      'reset_print': resetPrint,
    };
  }
}

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final id = reader.read();
    final name = reader.read();
    final email = reader.read();
    final role = reader.read();
    final mob = reader.read();
    final profileImage = reader.read();
    final appPermissions = reader.read();
    final customeUserID = reader.read();
    final unitId = reader.read();

    return User(
      id: id,
      name: name,
      email: email,
      role: role,
      mob: mob,
      profileImage: profileImage,
      appPermissions: appPermissions as UserPermissions?,
      customeUserID: customeUserID,
      unitId: unitId,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.writeByte(9); // Number of fields written
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.email);
    writer.write(obj.role);
    writer.write(obj.mob);
    writer.write(obj.profileImage);
    writer.write(obj.appPermissions);
    writer.write(obj.customeUserID);
    writer.write(obj.unitId);
  }
}

class UserPermissionsAdapter extends TypeAdapter<UserPermissions> {
  @override
  final int typeId = 1;

  @override
  UserPermissions read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    return UserPermissions(
      customerMemberRadio: reader.read(),
      scannerAccess: reader.read(),
      userProfileFilter: reader.read(),
      cashCollectionAccess: reader.read(),
      resendReceiptCustomer: reader.read(),
      onlineOfflineToggle: reader.read(),
      externalQr: reader.read(),
      additionalPhoneNo: reader.read(),
      receiptPrint: reader.read(),
      paymentGateway: numOfFields > 9 ? reader.read() : false,
      resetPrint: numOfFields > 10 ? reader.read() : false,
    );
  }

  @override
  void write(BinaryWriter writer, UserPermissions obj) {
    writer.writeByte(11); // Number of fields
    writer.write(obj.customerMemberRadio);
    writer.write(obj.scannerAccess);
    writer.write(obj.userProfileFilter);
    writer.write(obj.cashCollectionAccess);
    writer.write(obj.resendReceiptCustomer);
    writer.write(obj.onlineOfflineToggle);
    writer.write(obj.externalQr);
    writer.write(obj.additionalPhoneNo);
    writer.write(obj.receiptPrint);
    writer.write(obj.paymentGateway);
    writer.write(obj.resetPrint);
  }
}

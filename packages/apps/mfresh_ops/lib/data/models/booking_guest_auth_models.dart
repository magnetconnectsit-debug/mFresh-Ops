// region Models
class GuestCheckMobileResult {
  final bool status;
  final bool exists;
  final bool pending;
  final bool approved;
  final bool needName;
  final bool otpSent;
  final String? name;
  final String? nextStep;
  final String? message;
  final Map<String, dynamic>? guest;

  GuestCheckMobileResult({
    required this.status,
    this.exists = false,
    this.pending = false,
    this.approved = false,
    this.needName = false,
    this.otpSent = false,
    this.name,
    this.nextStep,
    this.message,
    this.guest,
  });

  // region Factory & Serialization
  factory GuestCheckMobileResult.fromJson(Map<String, dynamic> json) {
    return GuestCheckMobileResult(
      status: json['status'] == true || json['status'] == 'true',
      exists: json['exists'] == true || json['exists'] == 'true',
      pending: json['pending'] == true || json['pending'] == 'true',
      approved: json['approved'] == true || json['approved'] == 'true',
      needName: json['need_name'] == true || json['need_name'] == 'true',
      otpSent: json['otp_sent'] == true || json['otp_sent'] == 'true',
      name: json['name']?.toString(),
      nextStep: json['next_step']?.toString(),
      message: json['message']?.toString(),
      guest: json['guest'] is Map<String, dynamic>
          ? json['guest'] as Map<String, dynamic>
          : (json['guest'] is Map ? Map<String, dynamic>.from(json['guest']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'exists': exists,
      'pending': pending,
      'approved': approved,
      'need_name': needName,
      'otp_sent': otpSent,
      'name': name,
      'next_step': nextStep,
      'message': message,
      'guest': guest,
    };
  }
  // endregion
}

class GuestSendOtpResult {
  final bool status;
  final bool approved;
  final bool otpSent;
  final String? message;
  final int? otpExpiresIn;
  final String? otpVerificationToken;
  final String? nextStep;
  final Map<String, dynamic>? guest;

  GuestSendOtpResult({
    required this.status,
    this.approved = false,
    this.otpSent = false,
    this.message,
    this.otpExpiresIn,
    this.otpVerificationToken,
    this.nextStep,
    this.guest,
  });

  // region Factory & Serialization
  factory GuestSendOtpResult.fromJson(Map<String, dynamic> json) {
    return GuestSendOtpResult(
      status: json['status'] == true || json['status'] == 'true',
      approved: json['approved'] == true || json['approved'] == 'true',
      otpSent: json['otp_sent'] == true || json['otp_sent'] == 'true',
      message: json['message']?.toString(),
      otpExpiresIn: json['otp_expires_in'] is int
          ? json['otp_expires_in'] as int
          : int.tryParse(json['otp_expires_in']?.toString() ?? ''),
      otpVerificationToken: json['otp_verification_token']?.toString(),
      nextStep: json['next_step']?.toString(),
      guest: json['guest'] is Map<String, dynamic>
          ? json['guest'] as Map<String, dynamic>
          : (json['guest'] is Map ? Map<String, dynamic>.from(json['guest']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'approved': approved,
      'otp_sent': otpSent,
      'message': message,
      'otp_expires_in': otpExpiresIn,
      'otp_verification_token': otpVerificationToken,
      'next_step': nextStep,
      'guest': guest,
    };
  }
  // endregion
}

class BookingSessionModel {
  final bool status;
  final String? loginMode;
  final int? bookingActorUserId;
  final String? bookingActorUserIdStr;
  final String? bookingActorName;
  final String? userType;
  final GuestParentInfo? guestParent;
  final String? nextStep;

  BookingSessionModel({
    required this.status,
    this.loginMode,
    this.bookingActorUserId,
    this.bookingActorUserIdStr,
    this.bookingActorName,
    this.userType,
    this.guestParent,
    this.nextStep,
  });

  // region Factory & Serialization
  factory BookingSessionModel.fromJson(Map<String, dynamic> json) {
    final rawActorId = json['booking_actor_user_id'];
    final int? parsedActorId = rawActorId is int
        ? rawActorId
        : int.tryParse(rawActorId?.toString() ?? '');

    return BookingSessionModel(
      status: json['status'] == true || json['status'] == 'true',
      loginMode: json['login_mode']?.toString(),
      bookingActorUserId: parsedActorId,
      bookingActorUserIdStr: json['booking_actor_userid']?.toString(),
      bookingActorName: json['booking_actor_name']?.toString(),
      userType: json['user_type']?.toString(),
      guestParent: json['guest_parent'] is Map
          ? GuestParentInfo.fromJson(Map<String, dynamic>.from(json['guest_parent']))
          : null,
      nextStep: json['next_step']?.toString(),
    );
  }
  // endregion
}

class GuestParentInfo {
  final int? id;
  final String? userid;
  final String? name;
  final String? mobile;
  final String? unitId;

  GuestParentInfo({
    this.id,
    this.userid,
    this.name,
    this.mobile,
    this.unitId,
  });

  // region Factory & Serialization
  factory GuestParentInfo.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    return GuestParentInfo(
      id: rawId is int ? rawId : int.tryParse(rawId?.toString() ?? ''),
      userid: json['userid']?.toString(),
      name: json['name']?.toString(),
      mobile: json['mobile']?.toString(),
      unitId: json['unitId']?.toString() ?? json['unit_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userid': userid,
      'name': name,
      'mobile': mobile,
      'unitId': unitId,
    };
  }
  // endregion
}
// endregion

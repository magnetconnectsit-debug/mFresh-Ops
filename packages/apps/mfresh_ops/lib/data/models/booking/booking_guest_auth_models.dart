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
// endregion

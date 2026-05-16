import 'package:flutter/foundation.dart';
import 'package:mfresh/core/env/env.dart';

class AppConstants {
  AppConstants._();

  // region Base URL
  static final String defaultBaseUrl = ProdEnv.baseUrl;
  static final String devBaseUrl = DevEnv.baseUrl;
  static String baseUrl = defaultBaseUrl;
  static const bool isDevBuild = kDebugMode;
  // endregion

  // region API Endpoints
  static const String login = '/customer/login';
  static const String signup = '/customer/register';
  static const String profile = '/customer/profile';
  static const String logout = '/customer/logout';
  static const String passwordUpdate = '/customer/password-update';
  static const String profileUpdate = '/customer/profile-update';
  static const String profileEdit = '/customer/profile-edit';
  static const String sendOtp = '/customer/send-otp';
  static const String verifyOtp = '/customer/login-with-otp';
  static const String customerBookingDetails = '/customer/customerbookingdetails';
  static const String allUnits = '/customer/All-Units';
  static const String deleteProfile = '/customer/delete-profile';
  static const String allServices = '/customer/Api-get-Unit-services';
  static const String initiateBooking = '/customer/Api-initiateBooking';
  static const String successBooking = '/customer/Api-SuccessBooking';
  static const String sentSms = '/customer/resend-booking-sms';
  static const String validateMemPhone = '/customer/validate-mem-phone';
  static const String sendOtpMember = '/customer/send-otp-member';
  static const String verifyOtpMember = '/customer/verify-otp-member';
  static const String bookingHistory = '/customer/bookinghistory';
  static const String deleteCart = '/customer/delete_cart';
  static const String kioskScan = '/customer/kiosk-scan';
  static const String serviceImageBaseUrl = 'https://magnetconnects.com/public/images/';
  static const String privacyPolicyUrl = 'https://magnetconnects.com/privacy-Policy';
  static const String termsConditionUrl = 'https://magnetconnects.com/Terms-Condition';
  // endregion

  // region Hive Keys
  static const String userBoxName = 'userBox';
  static const String userKey = 'currentUser';
  // endregion
}

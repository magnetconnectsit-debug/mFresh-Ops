import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

class PhonePeService extends GetxService {
  final Dio _dio = Dio();

  static bool _isDevMode = true;

  bool get _isProduction => !_isDevMode;

  static void init({required bool isProduction}) {
    _isDevMode = !isProduction;
  }

  @override
  void onInit() {
    super.onInit();
    initSDK();
  }

  // Production Credentials
  static const String _prodSaltKey = 'dae92370-2265-4768-8c5b-e8fb8e2f6797';
  static const String _prodSaltIndex = '1';
  static const String _prodMerchantId = 'M22MA1RAEX7NC';
  static const String _prodApiBaseUrl = 'https://api.phonepe.com/apis/hermes';
  static const String _prodCallbackUrl =
      'https://magnetconnects.com/payment/callback/';
  static const String _prodAppSchema =
      "mfreshMerchant"; // Custom schema for iOS

  // Sandbox (UAT) Credentials
  static const String _uatSaltKey = '14fa5465-f8a7-443f-8477-f986b8fcfde9';
  static const String _uatSaltIndex = '1';
  static const String _uatMerchantId = 'PGTESTPAYUAT77';
  static const String _uatApiBaseUrl =
      'https://api-preprod.phonepe.com/apis/pg-sandbox';
  static const String _uatCallbackUrl =
      'https://magnetconnects.com/payment/callback/';
  static const String _uatAppSchema = "mfreshMerchantUAT";

  // Dynamic getters
  String get _saltKey => _isProduction ? _prodSaltKey : _uatSaltKey;

  String get _saltIndex => _isProduction ? _prodSaltIndex : _uatSaltIndex;

  String get _merchantId => _isProduction ? _prodMerchantId : _uatMerchantId;

  String get _apiBaseUrl => _isProduction ? _prodApiBaseUrl : _uatApiBaseUrl;

  String get _callbackUrl => _isProduction ? _prodCallbackUrl : _uatCallbackUrl;

  String get _appSchema => _isProduction ? _prodAppSchema : _uatAppSchema;

  Future<bool> initSDK() async {
    try {
      final environment = _isProduction ? "PRODUCTION" : "SANDBOX";
      final result = await PhonePePaymentSdk.init(
        environment,
        _merchantId,
        _merchantId,
        true,
      );
      debugPrint("PhonePe SDK Initialized: $result");

      // Print signature for debugging
      if (Platform.isAndroid) {
        getPackageSignature();
      }

      return result ?? false;
    } catch (e) {
      debugPrint("PhonePe SDK Init Error: $e");
      return false;
    }
  }

  /// Helper to get the package signature to share with PhonePe team
  Future<void> getPackageSignature() async {
    try {
      if (Platform.isAndroid) {
        // final signature = await PhonePePaymentSdk.getPackageSignatureForAndroid();
        debugPrint("------------------------------------------");
        debugPrint("PHONEPE: Signature helper disabled for compilation");
        debugPrint("------------------------------------------");
      }
    } catch (e) {
      debugPrint("Error getting signature: $e");
    }
  }

  /// Initiates payment via Native SDK
  Future<Map<String, dynamic>?> startSDKTransaction({
    required String bookingId,
    required String encryptedBookingId,
    required double amount,
    required String phone,
  }) async {
    try {
      debugPrint("--- PHONEPE SDK TRANSACTION ---");
      final uniqueTxnId =
          "${encryptedBookingId}_${DateTime.now().millisecondsSinceEpoch}";

      final payload = {
        "merchantId": _merchantId,
        "merchantTransactionId": uniqueTxnId,
        "merchantUserId": bookingId,
        "amount": (amount * 100).toInt(),
        "redirectUrl": "https://magnetconnects.com/booking-success/",
        "redirectMode": "POST",
        "callbackUrl": _callbackUrl,
        "mobileNumber": phone,
        "paymentInstrument": {"type": "PAY_PAGE"},
      };

      String payloadJson = jsonEncode(payload);
      String encodedPayload = base64Encode(utf8.encode(payloadJson));

      // Standard path for checksum
      String apiPath = "/pg/v1/pay";
      String checksumStr = "$encodedPayload$apiPath$_saltKey";
      var digest = sha256.convert(utf8.encode(checksumStr));
      String xVerify = "$digest###$_saltIndex";

      debugPrint("Starting SDK Transaction (Legacy V1)...");
      final dynamic result = await PhonePePaymentSdk.startTransaction(
        encodedPayload,
        _callbackUrl,
        xVerify,
        "", // Empty string lets the SDK choose the best handler
      );

      debugPrint("SDK Result: $result");

      if (result != null && result is Map) {
        return {
          'status': result['status']?.toString() ?? "FAILURE",
          'transactionId': uniqueTxnId,
          'error': result['error']?.toString(),
        };
      }
      return null;
    } catch (e) {
      debugPrint("PhonePe SDK Transaction Failed: $e");
      return null;
    }
  }

  // Fallback REST Flow (Reliable for QR if SDK fails)
  Future<Map<String, dynamic>?> initiateRESTTransaction({
    required String bookingId,
    required String encryptedBookingId,
    required double amount,
    required String phone,
  }) async {
    try {
      final uniqueTxnId =
          "${encryptedBookingId}_${DateTime.now().millisecondsSinceEpoch}";

      final payload = {
        "merchantId": _merchantId,
        "merchantTransactionId": uniqueTxnId,
        "merchantUserId": bookingId,
        "amount": (amount * 100).toInt(),
        "redirectUrl": "https://magnetconnects.com/booking-success/",
        "redirectMode": "POST",
        "callbackUrl": _callbackUrl,
        "mobileNumber": phone,
        "paymentInstrument": {"type": "PAY_PAGE"},
      };

      String encodedPayload = base64Encode(utf8.encode(jsonEncode(payload)));
      String checksumStr = "$encodedPayload/pg/v1/pay$_saltKey";
      String xVerify =
          "${sha256.convert(utf8.encode(checksumStr))}###$_saltIndex";

      final response = await _dio.post(
        "$_apiBaseUrl/pg/v1/pay",
        data: {"request": encodedPayload},
        options: Options(
          headers: {'Content-Type': 'application/json', 'X-VERIFY': xVerify},
        ),
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {
        return {
          'url': response
              .data['data']['instrumentResponse']['redirectInfo']['url'],
          'transactionId': uniqueTxnId,
        };
      }
      return null;
    } catch (e) {
      debugPrint("REST Transaction Failed: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> checkPaymentStatus({
    required String merchantTransactionId,
  }) async {
    try {
      String statusPath = "/pg/v1/status/$_merchantId/$merchantTransactionId";
      String xVerify =
          "${sha256.convert(utf8.encode("$statusPath$_saltKey"))}###$_saltIndex";

      final response = await _dio.get(
        "$_apiBaseUrl$statusPath",
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-VERIFY': xVerify,
            'X-MERCHANT-ID': _merchantId,
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("PhonePe Status Check Error: $e");
      return null;
    }
  }
}

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;

class PhonePeService extends GetxService {
  final Dio _dio = Dio();

  static bool _isDevMode = true;
  bool get _isProduction => !_isDevMode;

  static void init({required bool isProduction}) {
    _isDevMode = !isProduction;
  }

  // Production Credentials
  static const String _prodSaltKey = 'dae92370-2265-4768-8c5b-e8fb8e2f6797';
  static const String _prodSaltIndex = '1';
  static const String _prodMerchantId = 'M22MA1RAEX7NC';
  static const String _prodApiBaseUrl = 'https://api.phonepe.com/apis/hermes';
  static const String _prodWhiteListedDomain = 'https://magnetconnects.com/';
  static const String _prodRedirectUrl = 'https://magnetconnects.com/booking-success';
  static const String _prodCallbackUrl = 'https://magnetconnects.com/payment/callback';

  // Sandbox (UAT) Credentials - Updated with your Salt Key
  static const String _uatSaltKey = '14fa5465-f8a7-443f-8477-f986b8fcfde9';
  static const String _uatSaltIndex = '1';
  static const String _uatMerchantId = 'PGTESTPAYUAT77';
  static const String _uatApiBaseUrl =
      'https://api-preprod.phonepe.com/apis/pg-sandbox';
  static const String _uatRedirectUrl =
      'https://magnetconnects.com/booking-success';
  static const String _uatCallbackUrl =
      'https://magnetconnects.com/payment/callback';

  // Dynamic getters
  String get _saltKey => _isProduction ? _prodSaltKey : _uatSaltKey;
  String get _saltIndex => _isProduction ? _prodSaltIndex : _uatSaltIndex;
  String get _merchantId => _isProduction ? _prodMerchantId : _uatMerchantId;
  String get _apiBaseUrl => _isProduction ? _prodApiBaseUrl : _uatApiBaseUrl;
  String get _redirectUrl =>
      _isProduction ? _prodRedirectUrl : _uatRedirectUrl;
  String get _callbackUrl =>
      _isProduction ? _prodCallbackUrl : _uatCallbackUrl;

  Future<Map<String, String>?> initiatePayment({
    required String bookingId,
    required String encryptedBookingId,
    required double amount,
    required String phone,
  }) async {
    try {
      debugPrint("--- PHONEPE INITIATION ---");
      debugPrint("Mode: ${_isProduction ? 'PRODUCTION' : 'UAT/SANDBOX'}");
      debugPrint("Merchant ID: $_merchantId");

      // Append a small timestamp for uniqueness to avoid INVALID_TRANSACTION_ID from re-runs
      final uniqueTxnId = "${encryptedBookingId}_${DateTime.now().millisecondsSinceEpoch}";

      final payload = {
        "merchantId": _merchantId,
        "merchantTransactionId": uniqueTxnId,
        "merchantUserId": bookingId,
        "amount": (amount * 100).toInt(),
        "redirectUrl": _redirectUrl,
        "redirectMode": "POST",
        "callbackUrl": _callbackUrl,
        "mobileNumber": phone,
        "paymentInstrument": {"type": "PAY_PAGE"},
      };

      debugPrint("PhonePe Payload: ${jsonEncode(payload)}");

      String payloadJson = jsonEncode(payload);
      String encodedPayload = base64Encode(utf8.encode(payloadJson));

      // Standard path for checksum is always /pg/v1/pay
      String apiPath = "/pg/v1/pay";

      String checksumStr = "$encodedPayload$apiPath$_saltKey";
      var bytes = utf8.encode(checksumStr);
      var digest = sha256.convert(bytes);
      String xVerify = "$digest###$_saltIndex";

      debugPrint("X-VERIFY: $xVerify");

      final response = await _dio.post(
        "$_apiBaseUrl/pg/v1/pay",
        data: {"request": encodedPayload},
        options: Options(
          headers: {'Content-Type': 'application/json', 'X-VERIFY': xVerify},
        ),
      );

      debugPrint("PhonePe Response Body: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true) {
          return {
            'url': data['data']['instrumentResponse']['redirectInfo']['url'],
            'transactionId': uniqueTxnId,
          };
        }
      }
      return null;
    } catch (e) {
      if (e is DioException) {
        debugPrint("PhonePe Error Status: ${e.response?.statusCode}");
        debugPrint("PhonePe Error Body: ${e.response?.data}");
      }
      debugPrint("PhonePe Initiation Failed: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> checkPaymentStatus({
    required String merchantTransactionId,
  }) async {
    try {
      // Standard status path
      String statusPath = "/pg/v1/status/$_merchantId/$merchantTransactionId";
      String checksumStr = "$statusPath$_saltKey";
      var bytes = utf8.encode(checksumStr);
      var digest = sha256.convert(bytes);
      String xVerify = "$digest###$_saltIndex";

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
        final Map<String, dynamic> result = Map<String, dynamic>.from(
          response.data,
        );
        result['calculated_checksum'] = xVerify;
        return result;
      }
      return null;
    } catch (e) {
      debugPrint("PhonePe Status Check Error: $e");
      return null;
    }
  }
}

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

class PhonePeService extends GetxService {
  final Dio _dio = Dio();
  
  // Constants from legacy PHP code
  static const String saltKey = 'dae92370-2265-4768-8c5b-e8fb8e2f6797';
  static const String saltIndex = '1';
  static const String merchantId = 'M22MA1RAEX7NC';
  static const String baseUrl = 'https://api.phonepe.com/apis/hermes/pg/v1/pay';
  static const String baseUri = '/pg/v1/pay';

  Future<String?> initiatePayment({
    required String bookingId,
    required String encryptedBookingId,
    required double amount,
    required String phone,
  }) async {
    try {
      final payload = {
        "merchantId": merchantId,
        "merchantTransactionId": encryptedBookingId,
        "merchantUserId": bookingId,
        "amount": (amount * 100).toInt(), // PhonePe expects amount in paise
        "redirectUrl": 'https://magnetconnects.com/payment/redirect',
        "redirectMode": "POST",
        "callbackUrl": 'https://magnetconnects.com/payment/callback',
        "mobileNumber": phone,
        "paymentInstrument": {"type": "PAY_PAGE"}
      };

      String payloadJson = jsonEncode(payload);
      String encodedPayload = base64Encode(utf8.encode(payloadJson));

      // Checksum generation: SHA256(encodedPayload + baseUri + saltKey) + "###" + saltIndex
      String checksumStr = "$encodedPayload$baseUri$saltKey";
      var bytes = utf8.encode(checksumStr);
      var digest = sha256.convert(bytes);
      String xVerify = "$digest###$saltIndex";

      final response = await _dio.post(
        baseUrl,
        data: {"request": encodedPayload},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-VERIFY': xVerify,
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data']['instrumentResponse']['redirectInfo']['url'];
        }
      }
      return null;
    } catch (e) {
      print("PhonePe Error: $e");
      return null;
    }
  }
}

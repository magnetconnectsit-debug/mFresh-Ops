import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PlutusService extends GetxService {
  static const MethodChannel _channel = MethodChannel('PLUTUS-API');

  @override
  void onInit() {
    super.onInit();
    bindToService();
  }

  Future<String> bindToService() async {
    try {
      final result = await _channel.invokeMethod('bindToService');
      return result;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> startTransaction(String transactionData) async {
    try {
      final result = await _channel.invokeMethod('startTransaction', {
        'transactionData': transactionData,
      });
      return result;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> startPrintJob(String printData) async {
    try {
      final result = await _channel.invokeMethod('startPrintJob', {
        'printData': printData,
      });
      return result;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> startScanner(String payload) async {
    try {
      final result = await _channel.invokeMethod('startTransaction', payload);
      return result;
    } catch (e) {
      throw Exception("Scanner failed: $e");
    }
  }
}

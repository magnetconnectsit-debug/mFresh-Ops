import 'package:get/get.dart';
import 'package:mfresh/core/config/app_config.dart';
import 'package:flutter/material.dart';

import 'package:mfresh/data/repositories/common_repository.dart';
import 'package:mfresh/modules/profile/controllers/profile_controller.dart';
import 'package:mfresh/routes/app_routes.dart';

import 'package:services/phonepe_service.dart';
import 'package:core/utils/app_common_toast_message.dart';

class ServiceItem {
  final String assignServiceId;
  final String name;
  final int price;
  final String? image;
  final RxInt quantity;

  ServiceItem({
    required this.assignServiceId,
    required this.name,
    required this.price,
    this.image,
    int initialQty = 0,
  }) : quantity = initialQty.obs;
}

class ServiceDetailsController extends GetxController {
  final CommonRepository _commonRepository = Get.find<CommonRepository>();
  final ProfileController _profileController = Get.find<ProfileController>();
  // final PlutusService _plutusService = Get.find<PlutusService>();
  final PhonePeService _phonePeService = Get.find<PhonePeService>();

  // Unit info
  final unitNo = ''.obs;
  final location = ''.obs;
  final unitImage = ''.obs;

  // Toggle states
  final isCustomer = true.obs; // true = Customer, false = Membership
  final isOnline = false.obs;
  final isLoading = false.obs;

  // Contact details
  final mobileController = TextEditingController();
  final nameController = TextEditingController();
  final createAccount = false.obs;

  // Member flow
  final memberMobileController = TextEditingController();
  final otpController = TextEditingController();
  final isOtpSent = false.obs;
  final isOtpVerified = false.obs;
  final isVerifyingMember = false.obs;

  // Services list
  final services = <ServiceItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Get arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      unitNo.value = args['unitNo']?.toString() ?? '';
      location.value = args['location']?.toString() ?? '';
      unitImage.value = args['unitImage']?.toString() ?? '';
    }

    // Pre-fill user info
    final user = _profileController.user.value;
    if (user != null) {
      nameController.text = user.name ?? '';
      mobileController.text = user.mob ?? '';
    }

    fetchServices();
  }

  Future<void> fetchServices() async {
    if (unitNo.value.isEmpty) return;

    try {
      isLoading.value = true;
      services.clear();

      final fetchedServices = await _commonRepository.getServices(
        customerMode: isCustomer.value ? '0' : '1',
        unitNo: unitNo.value,
        serviceMode: isOnline.value ? '2' : '1',
      );

      services.assignAll(
        fetchedServices.map(
          (s) => ServiceItem(
            assignServiceId: s.assignServiceId,
            name: s.serviceName,
            price: s.price.toInt(),
            image: s.imagePath,
          ),
        ),
      );
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Failed to fetch services: $e",
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyMemberPhone(String phone) async {
    if (phone.length != 10) return;

    try {
      isVerifyingMember.value = true;
      final isValid = await _commonRepository.validateMemberPhone(phone: phone);
      if (isValid) {
        final sent = await _commonRepository.sendMemberOtp(phone: phone);
        isOtpSent.value = sent;
        if (sent) {
          AppCommonToastMessage.show(
            message: "OTP sent successfully",
            type: ToastType.success,
          );
        }
      } else {
        AppCommonToastMessage.show(
          message: "Member phone number not found",
          type: ToastType.error,
        );
      }
    } finally {
      isVerifyingMember.value = false;
    }
  }

  Future<void> verifyMemberOtp() async {
    final otp = otpController.text.trim();
    if (otp.isEmpty) return;

    try {
      isLoading.value = true;
      final verified = await _commonRepository.verifyMemberOtp(
        phone: memberMobileController.text.trim(),
        otp: otp,
      );
      isOtpVerified.value = verified;
      if (verified) {
        AppCommonToastMessage.show(
          message: "OTP verified successfully",
          type: ToastType.success,
        );
      } else {
        AppCommonToastMessage.show(
          message: "Invalid OTP",
          type: ToastType.error,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  DateTime? _lastInitiateTime;

  Future<void> initiateBooking({required bool isExternalQr}) async {
    // 1. DUPLICATE BOOKING CHECK (Last 10 Seconds)
    final now = DateTime.now();
    if (_lastInitiateTime != null &&
        now.difference(_lastInitiateTime!).inSeconds < 10) {
      AppCommonToastMessage.show(
        message: "Please wait, your previous booking is processing.",
        type: ToastType.info,
      );
      return;
    }
    _lastInitiateTime = now;

    final phone = mobileController.text.trim();
    final name = nameController.text.trim();

    // 2. HARD VALIDATION
    if (total <= 0) {
      AppCommonToastMessage.show(
        message: "Invalid amount",
        type: ToastType.error,
      );
      return;
    }

    if (phone.isEmpty || phone.length < 10) {
      AppCommonToastMessage.show(
        message: "Please enter a valid phone number",
        type: ToastType.error,
      );
      return;
    }

    final selectedServices = services
        .where((s) => s.quantity.value > 0)
        .toList();
    if (selectedServices.isEmpty) {
      AppCommonToastMessage.show(
        message: "Cart empty, cannot proceed booking",
        type: ToastType.error,
      );
      return;
    }

    // Member validation
    if (!isCustomer.value && !isOtpVerified.value) {
      AppCommonToastMessage.show(
        message: "Please verify membership OTP first",
        type: ToastType.error,
      );
      return;
    }

    try {
      isLoading.value = true;

      String paymentMode = "1"; // Cash
      if (isOnline.value) paymentMode = "2"; // Online
      if (isExternalQr) paymentMode = "3"; // External QR

      final cartItems = services
          .where((s) => s.quantity.value > 0)
          .map(
            (s) => {
              "Assign_Service_Id": s.assignServiceId,
              "service_quantity": s.quantity.value.toString(),
              "Price": s.price.toString(),
              "Total_price": (s.price * s.quantity.value).toString(),
            },
          )
          .toList();

      final body = {
        "Unit_no": unitNo.value,
        "User_Id": _profileController.user.value?.id.toString() ?? "",
        "phone_no": phone,
        "Add_phone_no": !isCustomer.value
            ? memberMobileController.text.trim()
            : "",
        "User_name": name,
        "total_amount": total.toString(),
        "Payment_status": "Pending",
        "payment_mode": paymentMode,
        "cart": cartItems,
      };

      final response = await _commonRepository.initiateBooking(data: body);

      if (response != null) {
        final bookingId = response['booking_id'];
        final encryptBookingId = response['encrypt_booking_id'];

        AppCommonToastMessage.show(
          message: "Booking initiated successfully",
          type: ToastType.success,
        );

        // Handle Admin/Cash or External QR auto-success if role is 3
        if (_profileController.user.value?.role == "3" &&
            (!isOnline.value || isExternalQr)) {
          await _confirmSuccess(bookingId, encryptBookingId);
        } else if (isOnline.value && !isExternalQr) {
          // Handle PhonePe Payment
          await _handlePhonePePayment(
            bookingId,
            encryptBookingId,
            total.toDouble(),
            phone,
          );
        }
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Booking failed: $e",
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _confirmSuccess(
    String bookingId,
    String encryptBookingId, {
    Map<String, dynamic>? phonePeData,
  }) async {
    final successData = {
      "userId": _profileController.user.value?.id.toString() ?? "",
      "bookingId": bookingId,
      "Payment_status": phonePeData?['code'] ?? "PAYMENT_SUCCESS",
      "provider_reference_id":
          phonePeData?['providerReferenceId'] ?? "ADMIN_MANUAL_CONFIRM",
      "check_sum":
          phonePeData?['checksum'] ??
          phonePeData?['providerReferenceId'] ??
          "VERIFIED_DIRECT",
    };

    final confirmed = await _commonRepository.confirmSuccessBooking(
      data: successData,
    );
    if (confirmed) {
      Get.toNamed(
        AppRoutes.bookingConfirmed,
        arguments: {
          'bookingId': bookingId,
          'encryptBookingId': encryptBookingId,
        },
      );
    }
  }

  Future<void> _handlePhonePePayment(
    String bookingId,
    String encryptBookingId,
    double amount,
    String phone,
  ) async {
    try {
      final redirectUrl = await _phonePeService.initiatePayment(
        bookingId: bookingId,
        encryptedBookingId: encryptBookingId,
        amount: amount,
        phone: phone,
      );

      if (redirectUrl != null) {
        final result = await Get.toNamed(
          AppRoutes.webView,
          arguments: {
            'url': redirectUrl,
            'title': 'PhonePe Payment',
            'redirectUrlToCapture': AppConfig.isDev
                ? 'https://testenv.magnetconnects.com/'
                : 'https://magnetconnects.com/',
          },
        );

        if (result != null && result is Map<String, dynamic>) {
          debugPrint('PhonePe Response: $result');
          String responseCode = result['code']?.toString() ?? "";
          String providerRefId =
              result['providerReferenceId']?.toString() ?? "";

          // 1. Check if we got clear SUCCESS from the URL
          if (responseCode == 'PAYMENT_SUCCESS' && providerRefId.isNotEmpty) {
            await _confirmSuccess(
              bookingId,
              encryptBookingId,
              phonePeData: result,
            );
            return;
          }

          // 2. FALLBACK: Verify with PhonePe directly (Most Secure)
          // This ensures we don't rely on the URL params or the backend history table.
          AppCommonToastMessage.show(
            message: "Verifying with PhonePe...",
            type: ToastType.info,
          );
          final phonePeStatus = await _phonePeService.checkPaymentStatus(
            merchantTransactionId: encryptBookingId,
          );

          if (phonePeStatus != null) {
            final String code = phonePeStatus['code']?.toString() ?? "";
            final realData = phonePeStatus['data'] ?? {};

            // Construct the response map for logging/debugging
            // Capture params from WebView if available
            final Map<String, dynamic> capturedParams = result;

            // Construct the response map for logging/debugging
            final responseMap = {
              'success': phonePeStatus['success'],
              'code': code,
              'message': phonePeStatus['message'],
              'providerReferenceId':
                  realData['transactionId'] ?? capturedParams['transactionId'],
              'amount': realData['amount'],
              'merchantTransactionId': realData['merchantTransactionId'],
              'paymentState': realData['state'],
              'responseCode': realData['responseCode'],
              'checksum':
                  capturedParams['checksum'] ??
                  phonePeStatus['calculated_checksum'] ??
                  realData['transactionId'],
            };

            debugPrint('=========================================');
            debugPrint('📊 REAL PHONEPE RESPONSE CAPTURED:');
            debugPrint('$responseMap');
            debugPrint('=========================================');

            if (phonePeStatus['success'] == true && code == 'PAYMENT_SUCCESS') {
              // PhonePe confirms success!
              await _confirmSuccess(
                bookingId,
                encryptBookingId,
                phonePeData: responseMap,
              );
            } else {
              AppCommonToastMessage.show(
                message: "Payment Status: ${realData['state'] ?? code}",
                type: ToastType.error,
              );
            }
          } else {
            // Fallback to Server check if PhonePe API fails
            final bookingDetails = await _commonRepository.getBookingDetails(
              bookingId: bookingId,
            );
            if (bookingDetails != null &&
                (bookingDetails.paymentStatus.toLowerCase() == 'paid' ||
                    bookingDetails.paymentStatus.toLowerCase() == 'success')) {
              await _confirmSuccess(
                bookingId,
                encryptBookingId,
                phonePeData: {'code': 'PAYMENT_SUCCESS'},
              );
            } else {
              AppCommonToastMessage.show(
                message: "Verification failed. Please contact support.",
                type: ToastType.error,
              );
            }
          }
        } else {
          // User returned without completion or redirect not caught
          AppCommonToastMessage.show(
            message: "Payment was not completed",
            type: ToastType.info,
          );
        }
      } else {
        AppCommonToastMessage.show(
          message: "Failed to initiate PhonePe payment",
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Payment Error: $e",
        type: ToastType.error,
      );
    }
  }



  void increment(int index) {
    services[index].quantity.value++;
  }

  void decrement(int index) {
    if (services[index].quantity.value > 0) {
      services[index].quantity.value--;
    }
  }

  int get total {
    int sum = 0;
    for (var s in services) {
      sum += s.price * s.quantity.value;
    }
    return sum;
  }

  void toggleCustomerType(bool isCustomerSelected) {
    if (isCustomer.value != isCustomerSelected) {
      isCustomer.value = isCustomerSelected;
      fetchServices();
    }
  }

  void toggleOnline() {
    isOnline.value = !isOnline.value;
    fetchServices();
  }
}

// region Imports
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:mfresh_ops/data/repositories/booking_repository.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/data/models/booking/booking_models.dart';
import 'package:mfresh_ops/modules/profile/controllers/profile_controller.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/modules/booking/controllers/booking_unit_selection_controller.dart';
import 'package:mfresh_ops/modules/service_details/views/widgets/handover_dialog_helper.dart';

import 'package:mfresh_ops/core/config/app_config.dart';
import 'package:services/phonepe_service.dart';
import 'package:services/plutus_service.dart';
import 'package:core/core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
// endregion

// region Models
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
// endregion

class ServiceDetailsController extends GetxController {
  // region Dependencies & Repositories
  final BookingRepository _bookingRepository = Get.find<BookingRepository>();
  final ProfileController _profileController = Get.find<ProfileController>();
  final PlutusService _plutusService = Get.find<PlutusService>();
  final PhonePeService _phonePeService = Get.find<PhonePeService>();
  // endregion

  // region Observables & State Variables
  // Unit info
  final unitNo = ''.obs;
  final location = ''.obs;
  final unitImage = ''.obs;
  final printingType = 'thermal'.obs;
  final paperRollSize = 80.obs;
  final cashierSessionId = Rxn<int>();

  // Observable strings for UI summary
  final customerName = ''.obs;
  final customerPhone = ''.obs;

  // Toggle states
  final isCustomer = true.obs; // true = Customer, false = Membership
  final isOnline = false.obs;
  final isLoading = false.obs;

  // Services list
  final services = <ServiceItem>[].obs;

  // Recent 6 Cashier Bookings
  final recentBookings = <RecentBookingItemModel>[].obs;
  final isLoadingRecentBookings = false.obs;

  // Member flow
  final isOtpSent = false.obs;
  final isOtpVerified = false.obs;
  final isVerifyingMember = false.obs;
  // endregion

  // region Text Controllers & Focus Nodes
  // Contact details
  final mobileController = TextEditingController();
  final nameController = TextEditingController();
  final addPhoneController = TextEditingController();
  final referralController = TextEditingController();

  // Member flow
  final memberMobileController = TextEditingController();
  final otpController = TextEditingController();
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    // Get arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      unitNo.value = args['unitNo']?.toString() ?? '';
      location.value = args['location']?.toString() ?? '';
      unitImage.value = args['unitImage']?.toString() ?? '';
      printingType.value = args['printingType']?.toString() ?? 'thermal';
      paperRollSize.value =
          int.tryParse(args['paperRollSize']?.toString() ?? '80') ?? 80;
      final rawSessionId = args['cashierSessionId'];
      if (rawSessionId != null) {
        cashierSessionId.value = rawSessionId is int
            ? rawSessionId
            : int.tryParse(rawSessionId.toString());
      }
    }

    // Pre-fill user info
    final user = _profileController.user.value;
    if (user != null) {
      nameController.text = user.name ?? '';
      mobileController.text = user.mob ?? '';
      customerName.value = user.name ?? '';
      customerPhone.value = user.mob ?? '';
    }

    fetchServices();
  }

  @override
  void onClose() {
    mobileController.dispose();
    nameController.dispose();
    addPhoneController.dispose();
    referralController.dispose();
    memberMobileController.dispose();
    otpController.dispose();
    super.onClose();
  }

  Future<void> refreshData() async {
    await Future.wait([
      _profileController.fetchProfile(),
      if (Get.isRegistered<BookingUnitSelectionController>())
        Get.find<BookingUnitSelectionController>().fetchUnits(),
    ]);

    try {
      if (Get.isRegistered<BookingUnitSelectionController>()) {
        final dashUnits =
            Get.find<BookingUnitSelectionController>().allUnitsList;
        final currentUnit =
            dashUnits.firstWhereOrNull((u) => u.unitId == unitNo.value);
        if (currentUnit != null) {
          printingType.value = currentUnit.printingType;
          paperRollSize.value = currentUnit.paperRollSize;
        }
      } else {
        final units = await _bookingRepository.getAllUnits();
        final currentUnit =
            units.firstWhereOrNull((u) => u.unitId == unitNo.value);
        if (currentUnit != null) {
          printingType.value = currentUnit.printingType;
          paperRollSize.value = currentUnit.paperRollSize;
        }
      }
    } catch (e) {
      debugPrint("Failed to update unit config on refresh: $e");
    }

    resetAll();
    await fetchServices();
  }

  void resetAll() {
    final modeChanged = isOnline.value || !isCustomer.value;
    isOnline.value = false; // Default is Offline
    isCustomer.value = true; // Default is Customer
    isOtpSent.value = false;
    isOtpVerified.value = false;

    // Clear selections
    for (var service in services) {
      service.quantity.value = 0;
    }

    // Clear controllers
    addPhoneController.clear();
    referralController.clear();
    otpController.clear();
    memberMobileController.clear();

    // Reset user data to profile defaults
    final user = _profileController.user.value;
    if (user != null) {
      nameController.text = user.name ?? '';
      mobileController.text = user.mob ?? '';
      customerName.value = user.name ?? '';
      customerPhone.value = user.mob ?? '';
    } else {
      nameController.clear();
      mobileController.clear();
      customerName.value = '';
      customerPhone.value = '';
    }

    // If online/customer modes changed, re-fetch default catalog
    if (modeChanged) {
      fetchServices();
    }
  }
  // endregion

  // region Exit & Handover Guard
  Future<void> handleBackExit(BuildContext context) async {
    final effectiveSessionId = cashierSessionId.value ??
        _bookingRepository.rxActiveCashierSessionId.value;

    if (effectiveSessionId == null ||
        effectiveSessionId <= 0 ||
        unitNo.value.isEmpty) {
      if (Navigator.of(context).canPop()) {
        Get.back();
      } else {
        Get.offAllNamed(AppRoutes.bookingUnitSelection);
      }
      return;
    }

    try {
      final res = await _bookingRepository.exitCheck(
        unitId: unitNo.value,
        sessionId: effectiveSessionId,
      );

      if (res.canExit) {
        if (Navigator.of(context).canPop()) {
          Get.back();
        } else {
          Get.offAllNamed(AppRoutes.bookingUnitSelection);
        }
      } else {
        if (!context.mounted) return;
        final shouldHandover = await AppCommonDialogBox.showConfirm(
          context,
          title: 'Handover Pending',
          message: res.message.isNotEmpty
              ? res.message
              : 'You have pending cash of ₹${res.pendingAmount.toStringAsFixed(2)}. Please complete cash handover before exiting the unit.',
          confirmText: 'Handover Now',
          cancelText: 'Stay',
          icon: Icons.payments_outlined,
          iconColor: const Color(0xFFF15A24),
        );

        if (shouldHandover && context.mounted) {
          HandoverDialogHelper.showHandoverDialog(
            context: context,
            unitNo: unitNo.value,
            cashierSessionId: effectiveSessionId,
            onSuccess: () {
              if (context.mounted) {
                if (Navigator.of(context).canPop()) {
                  Get.back();
                } else {
                  Get.offAllNamed(AppRoutes.bookingUnitSelection);
                }
              }
            },
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        if (Navigator.of(context).canPop()) {
          Get.back();
        } else {
          Get.offAllNamed(AppRoutes.bookingUnitSelection);
        }
      }
    }
  }
  // endregion

  // region API & Network Operations


  Future<void> fetchRecentBookings() async {
    if (unitNo.value.isEmpty) return;
    try {
      isLoadingRecentBookings.value = true;
      final effectiveSessionId = cashierSessionId.value ??
          _bookingRepository.rxActiveCashierSessionId.value;
      final results = await _bookingRepository.getRecentBookings(
        unitId: unitNo.value,
        cashierSessionId: effectiveSessionId,
      );
      recentBookings.assignAll(results.take(6).toList());
    } catch (e) {
      debugPrint('Error fetching recent bookings: ');
    } finally {
      isLoadingRecentBookings.value = false;
    }
  }

  Future<void> fetchServices() async {
    if (unitNo.value.isEmpty) return;

    try {
      isLoading.value = true;
      services.clear();

      final fetchedServices = await _bookingRepository.getServices(
        customerMode: isCustomer.value ? '0' : '1',
        unitNo: unitNo.value,
        serviceMode: isOnline.value ? '2' : '1',
        cashierSessionId: cashierSessionId.value,
      );

      // Deduplicate by assignServiceId / id to avoid duplicates in UI/Cart
      final Map<String, ServiceItem> uniqueServices = {};
      for (var s in fetchedServices) {
        final key = s.assignServiceId.isNotEmpty ? s.assignServiceId : s.id.toString();
        if (!uniqueServices.containsKey(key)) {
          uniqueServices[key] = ServiceItem(
            assignServiceId: key,
            name: s.serviceName,
            price: s.price.toInt(),
            image: s.imagePath,
          );
        }
      }

      services.assignAll(uniqueServices.values.toList());
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
      final validateResult = await _bookingRepository.validateMemberPhone(phone: phone);
      if (validateResult.isValid) {
        final sendResult = await _bookingRepository.sendMemberOtp(phone: phone);
        isOtpSent.value = sendResult.isSuccess;
        if (sendResult.isSuccess) {
          AppCommonToastMessage.show(
            message: sendResult.message,
            type: ToastType.success,
          );
        } else {
          AppCommonToastMessage.show(
            message: sendResult.message,
            type: ToastType.error,
          );
        }
      } else {
        AppCommonToastMessage.show(
          message: validateResult.message,
          type: ToastType.error,
        );
      }
    } finally {
      isVerifyingMember.value = false;
    }
  }

  Future<bool> verifyMemberOtp({
    String? phone,
    String? otp,
    bool showLoading = true,
  }) async {
    debugPrint(
      "verifyMemberOtp: phone=$phone, otp=$otp, showLoading=$showLoading",
    );
    final targetOtp = otp ?? otpController.text.trim();
    if (targetOtp.isEmpty) return false;

    try {
      if (showLoading) isLoading.value = true;
      final verifyResult = await _bookingRepository.verifyMemberOtp(
        phone: phone ?? memberMobileController.text.trim(),
        otp: targetOtp,
      );
      isOtpVerified.value = verifyResult.isVerified;
      if (verifyResult.isVerified) {
        AppCommonToastMessage.show(
          message: verifyResult.message,
          type: ToastType.success,
        );
      } else {
        AppCommonToastMessage.show(
          message: verifyResult.message,
          type: ToastType.error,
        );
      }
      return verifyResult.isVerified;
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
    if (!isCustomer.value) {
      final memberPhone = memberMobileController.text.trim();
      if (memberPhone.isEmpty || memberPhone.length < 10) {
        AppCommonToastMessage.show(
          message: "Please enter a valid member phone number",
          type: ToastType.error,
        );
        return;
      }

      // Automatically send OTP and show bottomsheet
      try {
        isVerifyingMember.value = true;
        final validateResult = await _bookingRepository.validateMemberPhone(
          phone: memberPhone,
        );
        if (!validateResult.isValid) {
          AppCommonToastMessage.show(
            message: validateResult.message,
            type: ToastType.error,
          );
          return;
        }

        final sendResult = await _bookingRepository.sendMemberOtp(phone: memberPhone);
        isOtpSent.value = sendResult.isSuccess;
        if (sendResult.isSuccess) {
          debugPrint("OTP Sent, showing bottomsheet...");
          final verified = await _showOtpBottomSheet(memberPhone);
          debugPrint("BottomSheet Result: $verified");
          if (!verified) return; // User cancelled or failed OTP
        } else {
          AppCommonToastMessage.show(
            message: sendResult.message,
            type: ToastType.error,
          );
          return;
        }
      } finally {
        isVerifyingMember.value = false;
      }
    }

    debugPrint("Proceeding to initiate booking logic...");
    debugPrint(
      "Payment Mode: ${isOnline.value ? 'Online' : 'Cash'}, External QR: $isExternalQr",
    );

    try {
      isLoading.value = true;

      // Payment Mode and Service Type mapping according to Complete Booking API flow:
      // Mode 1: Offline Cash -> payment_mode = 1, service_type = 1, Payment_status = PAYMENT_SUCCESS
      // Mode 2: PhonePe SDK  -> payment_mode = 2, service_type = 2, Payment_status = Pending
      // Mode 3: External QR  -> payment_mode = 3, service_type = 2, Payment_status = PAYMENT_SUCCESS, external_payment_confirmed = true
      int paymentMode = 1;
      int serviceType = 1;
      String initialPaymentStatus = "PAYMENT_SUCCESS";
      bool externalPaymentConfirmed = false;

      if (isExternalQr) {
        paymentMode = 3;
        serviceType = 2;
        initialPaymentStatus = "PAYMENT_SUCCESS";
        externalPaymentConfirmed = true;
      } else if (isOnline.value) {
        paymentMode = 2;
        serviceType = 2;
        initialPaymentStatus = "Pending";
      } else {
        paymentMode = 1;
        serviceType = 1;
        initialPaymentStatus = "PAYMENT_SUCCESS";
      }

      final cartItems = services
          .where((s) => s.quantity.value > 0)
          .map(
            (s) => CartItemPayload(
              assignServiceId: s.assignServiceId,
              serviceQuantity: s.quantity.value,
              price: s.price.toDouble(),
              totalPrice: (s.price * s.quantity.value).toDouble(),
            ),
          )
          .toList();

      final actorUserId = _bookingRepository.rxBookingActorUserId.value ??
          _profileController.user.value?.id ??
          0;
      final effectiveSessionId = cashierSessionId.value ??
          _bookingRepository.rxActiveCashierSessionId.value ??
          0;

      final initiateResult = await _bookingRepository.initiateAdminBooking(
        unitNo: unitNo.value,
        userId: actorUserId.toString(),
        cashierSessionId: effectiveSessionId,
        phoneNo: phone,
        addPhoneNo: addPhoneController.text.trim(),
        userName: name,
        totalAmount: total.toDouble(),
        paymentStatus: initialPaymentStatus,
        paymentMode: paymentMode,
        serviceType: serviceType,
        memStatus: !isCustomer.value ? 1 : 0,
        externalPaymentConfirmed: externalPaymentConfirmed,
        cart: cartItems,
      );

      debugPrint("Initiate Booking Result: ${initiateResult.status}, ID: ${initiateResult.bookingId}");

      if (initiateResult.status && initiateResult.bookingId != null) {
        final bookingId = initiateResult.bookingId!;
        final encryptBookingId = initiateResult.encryptBookingId ?? bookingId;

        // Mode 1 (Cash) & Mode 3 (External QR): Immediate Confirmation Screen
        if (paymentMode == 1 || paymentMode == 3) {
          AppCommonToastMessage.show(
            message: initiateResult.message.isNotEmpty
                ? initiateResult.message
                : "Booking Successful",
            type: ToastType.success,
          );

          final selectedServiceItems = services
              .where((s) => s.quantity.value > 0)
              .map(
                (s) => BookingServiceDetailItem(
                  servicesName: s.name,
                  quantity: s.quantity.value.toString(),
                  price: s.price.toString(),
                ),
              )
              .toList();

          final customerPhone = phone;
          final customerAddPhone = addPhoneController.text.trim();

          final bookingDetailsModel = initiateResult.toBookingDetailsModel(
            fallbackServices: selectedServiceItems,
            fallbackLocation: location.value,
            phone: customerPhone,
            addPhone: customerAddPhone,
          );

          fetchRecentBookings();
          resetAll();
          Get.toNamed(
            AppRoutes.bookingConfirmed,
            arguments: {
              'bookingModel': bookingDetailsModel,
              'bookingId': bookingId,
              'encryptBookingId': encryptBookingId,
              'paperRollSize': paperRollSize.value,
              'printingType': printingType.value,
              'receiptUrl': initiateResult.receiptUrl,
              'phone': customerPhone,
              'addPhone': customerAddPhone,
            },
          );
          return;
        }

        // Mode 2 (PhonePe SDK / Gateway):
        if (paymentMode == 2) {
          final usePineLabs = Get.isRegistered<AuthRepository>() &&
              Get.find<AuthRepository>()
                  .rxUserPermissions
                  .contains('payment_gateway');

          if (usePineLabs) {
            await _handlePineLabsPayment(
              bookingId,
              encryptBookingId,
              total.toDouble(),
            );
          } else {
            await _handlePhonePePayment(
              bookingId,
              encryptBookingId,
              total.toDouble(),
              phone,
            );
          }
        }
      } else {
        AppCommonToastMessage.show(
          message: initiateResult.message.isNotEmpty
              ? initiateResult.message
              : "Failed to initiate booking",
          type: ToastType.error,
        );
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

  Future<void> _handlePineLabsPayment(
    String bookingId,
    String encryptBookingId,
    double amount,
  ) async {
    try {
      AppCommonToastMessage.show(
        message: "Initiating PineLabs Payment...",
        type: ToastType.info,
      );

      final String amountInPaisa = (amount * 100).toInt().toString();

      final paymentPayload = {
        "Header": {
          "ApplicationId": "com.mFresh", // Whitelisted ID
          "UserId": "user1234",
          "MethodId": "1001",
          "VersionNo": "1.0",
        },
        "Detail": {
          "TransactionType": "4001",
          "BillingRefNo": bookingId,
          "TransactionAmount": amountInPaisa,
        },
      };

      final result = await _plutusService.startTransaction(
        jsonEncode(paymentPayload),
      );

      final Map<String, dynamic> data = jsonDecode(result);
      final responseCode = data['Response']?['ResponseCode'];

      if (responseCode == "0") {
        AppCommonToastMessage.show(
          message: "PineLabs Payment Successful",
          type: ToastType.success,
        );
        await _confirmSuccess(
          bookingId,
          encryptBookingId,
          phonePeData: {
            'code': 'PAYMENT_SUCCESS',
            'providerReferenceId':
                data['Response']?['RRN'] ?? "PINELABS_$bookingId",
          },
        );
      } else {
        String errorMsg =
            data['Response']?['ResponseMessage'] ??
            "Payment failed on terminal";
        AppCommonToastMessage.show(
          message: "PineLabs Error: $errorMsg (Code: $responseCode)",
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: "PineLabs Error: $e",
        type: ToastType.error,
      );
    }
  }

  Future<void> _confirmSuccess(
    String bookingId,
    String encryptBookingId, {
    Map<String, dynamic>? phonePeData,
  }) async {
    final String userId = _profileController.user.value?.id.toString() ?? "";
    final String paymentStatus =
        phonePeData?['code']?.toString() ?? "PAYMENT_SUCCESS";
    final String providerRefId =
        phonePeData?['providerReferenceId']?.toString() ??
            phonePeData?['data']?['transactionId']?.toString() ??
            "ADMIN_MANUAL_CONFIRM";

    // Backend validation requires check_sum <= 255 characters
    String checkSum = "VERIFIED_DIRECT";
    if (phonePeData != null) {
      final possibleChecksum = phonePeData['checksum'] ??
          phonePeData['check_sum'] ??
          phonePeData['providerReferenceId'] ??
          phonePeData['data']?['transactionId'];

      if (possibleChecksum != null &&
          possibleChecksum.toString().isNotEmpty &&
          possibleChecksum.toString().length <= 255) {
        checkSum = possibleChecksum.toString();
      } else {
        // Standard SHA-256 hash (64 chars) of payment data
        checkSum = sha256.convert(utf8.encode(jsonEncode(phonePeData))).toString();
      }
    }

    final result = await _bookingRepository.submitPaymentSuccess(
      userId: userId,
      bookingId: bookingId,
      paymentStatus: paymentStatus,
      providerReferenceId: providerRefId,
      checkSum: checkSum,
    );
    debugPrint("Booking Confirmation API Result: ${result.status}");
    if (result.status) {
      debugPrint("Navigating to Booking Confirmed Screen...");
      final selectedServiceItems = services
          .where((s) => s.quantity.value > 0)
          .map(
            (s) => BookingServiceDetailItem(
              servicesName: s.name,
              quantity: s.quantity.value.toString(),
              price: s.price.toString(),
            ),
          )
          .toList();

      final customerPhone = mobileController.text.trim();
      final customerAddPhone = addPhoneController.text.trim();

      final bookingDetailsModel = BookingDetailsModel(
        bookingId: bookingId,
        unitNo: unitNo.value,
        bookingTimeDate: DateTime.now().toString(),
        unitLocation: location.value,
        totalAmount: total.toString(),
        serviceIcon: '',
        fullAddress: location.value,
        services: selectedServiceItems,
        paymentMode: 2,
        paymentStatus: paymentStatus,
        encryptBookingId: encryptBookingId,
        phone: customerPhone,
        addPhone: customerAddPhone,
      );

      fetchRecentBookings();
      resetAll();
      Get.toNamed(
        AppRoutes.bookingConfirmed,
        arguments: {
          'bookingModel': bookingDetailsModel,
          'bookingId': bookingId,
          'encryptBookingId': encryptBookingId,
          'paperRollSize': paperRollSize.value,
          'printingType': printingType.value,
          'receiptUrl': result.receiptUrl,
          'phone': customerPhone,
          'addPhone': customerAddPhone,
        },
      );
    } else {
      AppCommonToastMessage.show(
        message: result.message.isNotEmpty
            ? result.message
            : "Failed to confirm booking on server",
        type: ToastType.error,
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
      final isInitialized =
          await _phonePeService.setProduction(AppConfig.isPhonePeProduction);
      debugPrint("PhonePe setProduction initialized: $isInitialized (Prod: ${AppConfig.isPhonePeProduction})");

      AppCommonToastMessage.show(
        message: "Initiating payment gateway...",
        type: ToastType.info,
      );

      final restResponse = await _phonePeService.initiateRESTTransaction(
        bookingId: bookingId,
        encryptedBookingId: encryptBookingId,
        amount: amount,
        phone: phone,
        redirectUrl: "https://magnetconnects.com/",
        redirectMode: "REDIRECT",
      );

      if (restResponse != null && restResponse['url'] != null) {
        final String paymentUrl = restResponse['url'].toString();
        final String txnId =
            restResponse['transactionId']?.toString() ?? encryptBookingId;

        debugPrint(
            "Opening PhonePe Web Payment URL: $paymentUrl (txn: $txnId)");

        final result = await Get.toNamed(
          AppRoutes.webView,
          arguments: {
            'url': paymentUrl,
            'title': 'PhonePe Payment',
            'redirectUrlToCapture': 'https://magnetconnects.com/',
          },
        );

        debugPrint("Payment WebView closed with result: $result");

        // Verify status after returning from web payment
        AppCommonToastMessage.show(
          message: "Checking payment status...",
          type: ToastType.info,
        );

        Map<String, dynamic>? phonePeStatus;
        // Verify with PhonePe API (with small retry to allow backend sync)
        for (int i = 0; i < 3; i++) {
          phonePeStatus = await _phonePeService.checkPaymentStatus(
            merchantTransactionId: txnId,
          );
          if (phonePeStatus != null &&
              phonePeStatus['success'] == true &&
              phonePeStatus['code']?.toString() == 'PAYMENT_SUCCESS') {
            break;
          }
          if (i < 2) {
            await Future.delayed(const Duration(milliseconds: 1500));
          }
        }

        if (phonePeStatus != null) {
          final String code = phonePeStatus['code']?.toString() ?? "";
          final realData = phonePeStatus['data'] ?? {};

          if (phonePeStatus['success'] == true && code == 'PAYMENT_SUCCESS') {
            await _confirmSuccess(
              bookingId,
              encryptBookingId,
              phonePeData: {
                ...phonePeStatus,
                'providerReferenceId': realData['transactionId'] ?? txnId,
                'code': code,
              },
            );
          } else {
            // NEVER confirm success if PhonePe status is not PAYMENT_SUCCESS!
            String errorMsg = "Payment was not completed.";
            if (code.contains("CANCEL") || code.contains("USER_CANCEL")) {
              errorMsg = "Payment was cancelled.";
            } else if (code.contains("FAIL") || code.contains("DECLIN")) {
              errorMsg = "Payment failed: ${realData['state'] ?? code}";
            } else if (code.isNotEmpty) {
              errorMsg = "Payment Status: ${realData['state'] ?? code}";
            }

            AppCommonToastMessage.show(
              message: errorMsg,
              type: ToastType.error,
            );
          }
        } else {
          // If status check could not verify with PhonePe, check if webview reported failure or cancel
          final bool isCancelled = result == null ||
              (result is Map &&
                  (result['status'] == 'FAILURE' ||
                      (result['code']?.toString() ?? '').contains('CANCEL')));

          AppCommonToastMessage.show(
            message: isCancelled
                ? "Payment was cancelled."
                : "Unable to verify payment status with gateway. Please check transaction.",
            type: ToastType.warning,
          );
        }
      } else {
        AppCommonToastMessage.show(
          message: "Could not initiate payment gateway. Please try again.",
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
    fetchRecentBookings();
  }

  Future<bool> _showOtpBottomSheet(String phone) async {
    final TextEditingController bottomOtpController = TextEditingController();
    final RxBool isVerifying = false.obs;

    final defaultPinTheme = PinTheme(
      width: 45.w,
      height: 50.h,
      textStyle: AppTextStyle.style_20_600(color: AppColors.black),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey100),
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.grey50.withValues(alpha: 0.5),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primary),
        color: AppColors.white,
      ),
    );

    final RxBool hasVerified = false.obs;

    final result = await Get.bottomSheet<bool>(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Verify Membership',
              style: AppTextStyle.style_18_600(color: AppColors.primary),
            ),
            SizedBox(height: 10.h),
            Text(
              'Enter the 6-digit OTP sent to\n+91 $phone',
              textAlign: TextAlign.center,
              style: AppTextStyle.style_13_400(color: AppColors.grey300),
            ),
            SizedBox(height: 30.h),
            Obx(() => Pinput(
              length: 6,
              autofillHints: const [AutofillHints.oneTimeCode],
              controller: bottomOtpController,
              readOnly: isVerifying.value || hasVerified.value,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              onCompleted: (pin) async {
                if (hasVerified.value || isVerifying.value) return;

                isVerifying.value = true;
                final success = await verifyMemberOtp(
                  phone: phone,
                  otp: pin,
                  showLoading: false,
                );
                isVerifying.value = false;
                if (success) {
                  hasVerified.value = true;
                  debugPrint(
                    "OTP Verified in onCompleted. Closing via Navigator.pop...",
                  );
                  Navigator.pop(Get.context!, true);
                }
              },
            )),
            SizedBox(height: 30.h),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (isVerifying.value || hasVerified.value)
                      ? null
                      : () async {
                          if (bottomOtpController.text.length < 6) {
                            AppCommonToastMessage.show(
                              message: "Please enter 6-digit OTP",
                              type: ToastType.error,
                            );
                            return;
                          }

                          isVerifying.value = true;
                          final success = await verifyMemberOtp(
                            phone: phone,
                            otp: bottomOtpController.text.trim(),
                            showLoading: false,
                          );
                          isVerifying.value = false;
                          if (success) {
                            hasVerified.value = true;
                            debugPrint(
                              "OTP Verified via button. Closing via Navigator.pop...",
                            );
                            Navigator.pop(Get.context!, true);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    elevation: 0,
                  ),
                  child: isVerifying.value
                      ? const CustomAppLoader(size: 20, strokeWidth: 1.5)
                      : Text(
                          'VERIFY & PROCEED',
                          style: AppTextStyle.style_14_600(
                            color: AppColors.white,
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(
                'Cancel',
                style: AppTextStyle.style_12_600(color: AppColors.red),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
      isScrollControlled: true,
      barrierColor: AppColors.black.withValues(alpha: 0.5),
    );

    return result ?? false;
  }

  void showContactDetailsBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Customer Information',
                style: AppTextStyle.style_18_600(color: AppColors.primary),
              ),
              SizedBox(height: 15.h),

              // Mobile Number
              buildBottomSheetField(
                controller: mobileController,
                label: 'Mobile Number*',
                hintText: 'Mobile Number*',
                showLabel: false,
                keyboardType: TextInputType.phone,
                icon: Icons.phone_android,
              ),
              SizedBox(height: 12.h),

              // Full Name
              buildBottomSheetField(
                controller: nameController,
                label: 'Full Name',
                hintText: 'Full Name',
                showLabel: false,
                icon: Icons.person_outline,
              ),
              SizedBox(height: 12.h),

              // Additional Phone
              buildBottomSheetField(
                controller: addPhoneController,
                label: 'Additional Phone',
                hintText: 'Additional Phone',
                showLabel: false,
                keyboardType: TextInputType.phone,
                icon: Icons.phone_android,
              ),
              SizedBox(height: 12.h),

              // Referral ID
              buildBottomSheetField(
                controller: referralController,
                label: 'Referral ID',
                hintText: 'Referral ID',
                showLabel: false,
                icon: Icons.person_add_alt,
              ),

              SizedBox(height: 30.h),
              AppCommonButton(
                text: 'DONE',
                width: double.infinity,
                height: 42.h,
                textSize: 14.sp,
                buttonColor: AppColors.primary,
                useGradient: false,
                borderRadius: 10.r,
                onPressed: () {
                  customerName.value = nameController.text.trim();
                  customerPhone.value = mobileController.text.trim();
                  Get.back();
                },
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget buildBottomSheetField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    bool showLabel = true,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text(
            label,
            style: AppTextStyle.style_12_600(color: AppColors.grey300),
          ),
          SizedBox(height: 6.h),
        ],
        AppCommonTextField(
          controller: controller,
          labelText: label,
          hintText: hintText ?? 'Enter $label',
          useFloatingLabel: true,
          keyboardType: keyboardType,
          readOnly: readOnly,
          prefixIcon: Icon(icon, size: 16.sp, color: AppColors.iconPrimary),
          borderRadius: 8.r,
          fillColor: AppColors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 8.h,
          ),
        ),
      ],
    );
  }
  // endregion
}
// endregion

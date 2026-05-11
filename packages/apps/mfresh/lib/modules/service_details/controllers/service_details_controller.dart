import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:mfresh/data/repositories/common_repository.dart';
import 'package:mfresh/modules/profile/controllers/profile_controller.dart';
import 'package:mfresh/routes/app_routes.dart';
import 'package:mfresh/data/models/unit_model.dart';

import 'package:services/phonepe_service.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';

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
  final printingType = 'thermal'.obs;
  final paymentMode = 'phonepe'.obs;
  final paperRollSize = 80.obs;
  final hasPermission = UnitPermission().obs;

  // Observable strings for UI summary
  final customerName = ''.obs;
  final customerPhone = ''.obs;

  // Toggle states
  final isCustomer = true.obs; // true = Customer, false = Membership
  final isOnline = false.obs;
  final isLoading = false.obs;

  // Contact details
  final mobileController = TextEditingController();
  final nameController = TextEditingController();
  final addPhoneController = TextEditingController();

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
      printingType.value = args['printingType']?.toString() ?? 'thermal';
      paymentMode.value = args['paymentMode']?.toString() ?? 'phonepe';
      paperRollSize.value = int.tryParse(args['paperRollSize']?.toString() ?? '80') ?? 80;
    }

    if (unitNo.value.isNotEmpty && (args?['paymentMode'] == null)) {
      _fetchUnitConfig();
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

  Future<void> refreshData() async {
    await Future.wait([
      _fetchUnitConfig(),
      fetchServices(),
    ]);
  }

  void resetAll() {
    isOnline.value = false;
    isCustomer.value = true;
    isOtpSent.value = false;
    isOtpVerified.value = false;

    // Clear selections
    for (var service in services) {
      service.quantity.value = 0;
    }

    // Clear controllers
    addPhoneController.clear();
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

      // Deduplicate by assignServiceId to avoid duplicates in UI/Cart
      final Map<String, ServiceItem> uniqueServices = {};
      for (var s in fetchedServices) {
        if (!uniqueServices.containsKey(s.assignServiceId)) {
          uniqueServices[s.assignServiceId] = ServiceItem(
            assignServiceId: s.assignServiceId,
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

  Future<void> _fetchUnitConfig() async {
    try {
      final config = await _commonRepository.getUnitConfig(unitId: unitNo.value);
      if (config != null) {
        printingType.value = config.printingType;
        paymentMode.value = config.paymentMode;
        paperRollSize.value = config.paperRollSize;
        hasPermission.value = config.permission;
        
        if (!hasPermission.value.isActive) {
          services.clear();
          AppCommonToastMessage.show(
            message: "Access Denied for this unit",
            type: ToastType.error,
          );
        } else {
          fetchServices(); // Re-fetch if permission granted
        }
        
        debugPrint(
            "Unit Config Updated: Printing=${printingType.value}, Payment=${paymentMode.value}, RollSize=${paperRollSize.value}, Permission=${hasPermission.value.isActive}");
      }
    } catch (e) {
      debugPrint("Failed to fetch unit config: $e");
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

  Future<bool> verifyMemberOtp({String? phone, String? otp, bool showLoading = true}) async {
    debugPrint("verifyMemberOtp: phone=$phone, otp=$otp, showLoading=$showLoading");
    final targetOtp = otp ?? otpController.text.trim();
    if (targetOtp.isEmpty) return false;

    try {
      if (showLoading) isLoading.value = true;
      final verified = await _commonRepository.verifyMemberOtp(
        phone: phone ?? memberMobileController.text.trim(),
        otp: targetOtp,
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
      return verified;
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
        final isValid = await _commonRepository.validateMemberPhone(phone: memberPhone);
        if (!isValid) {
          AppCommonToastMessage.show(
            message: "Member phone number not found",
            type: ToastType.error,
          );
          return;
        }

        final sent = await _commonRepository.sendMemberOtp(phone: memberPhone);
        isOtpSent.value = sent;
        if (sent) {
          debugPrint("OTP Sent, showing bottomsheet...");
          final verified = await _showOtpBottomSheet(memberPhone);
          debugPrint("BottomSheet Result: $verified");
          if (!verified) return; // User cancelled or failed OTP
        } else {
          AppCommonToastMessage.show(
            message: "Failed to send OTP",
            type: ToastType.error,
          );
          return;
        }
      } finally {
        isVerifyingMember.value = false;
      }
    }

    debugPrint("Proceeding to initiate booking logic...");
    debugPrint("Payment Mode: ${isOnline.value ? 'Online' : 'Cash'}, External QR: $isExternalQr");

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
        "Membership_No": !isCustomer.value
            ? memberMobileController.text.trim()
            : "",
        "User_name": name,
        "total_amount": total.toString(),
        "Payment_status": "Pending",
        "payment_mode": paymentMode,
        "Add_phone_no": addPhoneController.text.trim(),
        "cart": cartItems,
      };

      final response = await _commonRepository.initiateBooking(data: body);
      debugPrint("Initiate Booking Response: $response");

      if (response != null) {
        final bookingId = response['booking_id'];
        final encryptBookingId = response['encrypt_booking_id'];

        AppCommonToastMessage.show(
          message: "Booking initiated successfully",
          type: ToastType.success,
        );

        // Handle Cash or External QR auto-success
        debugPrint("User Role: ${_profileController.user.value?.role}");
        if (!isOnline.value || isExternalQr) {
          debugPrint("Calling _confirmSuccess for direct confirmation...");
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
    debugPrint("Booking Confirmation API Result: $confirmed");
    if (confirmed) {
      debugPrint("Navigating to Booking Confirmed Screen...");
      Get.toNamed(
        AppRoutes.bookingConfirmed,
        arguments: {
          'bookingId': bookingId,
          'encryptBookingId': encryptBookingId,
          'paperRollSize': paperRollSize.value,
        },
      );
    } else {
      AppCommonToastMessage.show(
        message: "Failed to confirm booking on server",
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
      final paymentData = await _phonePeService.initiatePayment(
        bookingId: bookingId,
        encryptedBookingId: encryptBookingId,
        amount: amount,
        phone: phone,
      );

      if (paymentData != null) {
        final redirectUrl = paymentData['url'];
        final actualTxnId = paymentData['transactionId'] ?? encryptBookingId;

        final result = await Get.toNamed(
          AppRoutes.webView,
          arguments: {
            'url': redirectUrl,
            'title': 'PhonePe Payment',
            'redirectUrlToCapture': 'magnetconnects.com',
          },
        );

        if (result != null) {
          // Verification logic...
          AppCommonToastMessage.show(
            message: "Verifying payment...",
            type: ToastType.info,
          );
          final phonePeStatus = await _phonePeService.checkPaymentStatus(
            merchantTransactionId: actualTxnId,
          );

          if (phonePeStatus != null) {
            final String code = phonePeStatus['code']?.toString() ?? "";
            final realData = phonePeStatus['data'] ?? {};

            if (phonePeStatus['success'] == true && code == 'PAYMENT_SUCCESS') {
              // PhonePe confirms success!
              await _confirmSuccess(
                bookingId,
                encryptBookingId,
                phonePeData: {
                  ...phonePeStatus,
                  'providerReferenceId': realData['transactionId'],
                  'code': code,
                },
              );
            } else {
              // Fallback to Server check if PhonePe says pending/failed but user insists
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
                  message: "Payment Status: ${realData['state'] ?? code}",
                  type: ToastType.error,
                );
              }
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
                message: "Verification failed. Please try again or contact support.",
                type: ToastType.error,
              );
            }
          }
        } else {
          // User cancelled verification
          AppCommonToastMessage.show(
            message: "Verification was not completed",
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
            Pinput(
              length: 6,
              controller: bottomOtpController,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              onCompleted: (pin) async {
                if (hasVerified.value) return;
                
                isVerifying.value = true;
                final success = await verifyMemberOtp(
                  phone: phone,
                  otp: pin,
                  showLoading: false,
                );
                isVerifying.value = false;
                if (success) {
                  hasVerified.value = true;
                  debugPrint("OTP Verified in onCompleted. Closing via Navigator.pop...");
                  Navigator.pop(Get.context!, true);
                }
              },
            ),
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
                             debugPrint("OTP Verified via button. Closing via Navigator.pop...");
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
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
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
              
              SizedBox(height: 30.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    customerName.value = nameController.text.trim();
                    customerPhone.value = mobileController.text.trim();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'DONE',
                    style: AppTextStyle.style_14_600(color: AppColors.white),
                  ),
                ),
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
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.grey50.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.grey100),
          ),
          child: Row(
            children: [
              Icon(icon, size: 14.sp, color: AppColors.grey300),
              SizedBox(width: 10.w),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: AppTextStyle.style_12_400(color: AppColors.black),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: hintText,
                    hintStyle: AppTextStyle.style_12_400(color: AppColors.grey200),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// region Imports
import 'dart:async';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:pinput/pinput.dart';
// endregion

// region Enums
enum GuestFlowStep {
  enterMobile,
  enterNameRegistration,
  waitingForApproval,
  verifyOtp,
}
// endregion

// region GuestFlowBottomSheet Controller
class GuestFlowController extends GetxController {
  // region Dependencies & Repositories
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  // endregion

  // region Observables & State Variables
  final String guestFlowToken;
  final currentStep = GuestFlowStep.enterMobile.obs;
  final isLoading = false.obs;

  // Guest details
  final guestName = ''.obs;
  final guestMobile = ''.obs;
  final registeredGuestId = Rxn<int>();
  final isMobileChecked = false.obs;

  // OTP Verification
  String? otpVerificationToken;
  final resendCooldown = 0.obs;
  Timer? _cooldownTimer;
  // endregion

  // region Text Controllers & Focus Nodes
  final mobileController = TextEditingController();
  final nameController = TextEditingController();
  final guestNameController = TextEditingController();
  final otpController = TextEditingController();

  final mobileFocusNode = FocusNode();
  final nameFocusNode = FocusNode();
  final otpFocusNode = FocusNode();
  // endregion

  // region Constructor & Lifecycle
  GuestFlowController({required this.guestFlowToken}) {
    mobileController.addListener(_onMobileChanged);
  }

  void _onMobileChanged() {
    if (isMobileChecked.value) {
      isMobileChecked.value = false;
      guestName.value = '';
      guestNameController.clear();
    }
  }

  @override
  void onClose() {
    _cooldownTimer?.cancel();
    mobileController.removeListener(_onMobileChanged);
    mobileController.dispose();
    nameController.dispose();
    guestNameController.dispose();
    otpController.dispose();
    mobileFocusNode.dispose();
    nameFocusNode.dispose();
    otpFocusNode.dispose();
    super.onClose();
  }
  // endregion

  // region Business Logic & API Operations
  void _startCooldown([int seconds = 60]) {
    _cooldownTimer?.cancel();
    resendCooldown.value = seconds;
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCooldown.value > 0) {
        resendCooldown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  // Step 2: Check Mobile
  Future<void> checkGuestMobile() async {
    final mob = mobileController.text.trim();
    if (mob.isEmpty || mob.length != 10) {
      AppCommonToastMessage.show(
        message: 'Please enter a valid 10-digit mobile number',
        type: ToastType.warning,
      );
      mobileFocusNode.requestFocus();
      return;
    }

    isLoading.value = true;
    try {
      final result = await _authRepository.guestCheckMobile(
        mobile: mob,
        guestFlowToken: guestFlowToken,
      );

      guestMobile.value = mob;

      if (result.status) {
        // Case A — Already registered and approved
        if (result.approved) {
          final foundName = result.name ?? (result.guest?['name']?.toString() ?? 'Guest Cashier');
          guestName.value = foundName;
          guestNameController.text = foundName;
          isMobileChecked.value = true;
          return;
        }

        // Case C — Already registered, approval pending
        if (result.pending) {
          guestName.value = result.name ?? (result.guest?['name']?.toString() ?? '');
          currentStep.value = GuestFlowStep.waitingForApproval;
          return;
        }

        // Case B — New guest, not registered
        if (!result.exists || result.needName) {
          nameController.clear();
          currentStep.value = GuestFlowStep.enterNameRegistration;
          Future.delayed(const Duration(milliseconds: 300), () {
            nameFocusNode.requestFocus();
          });
          return;
        }
      } else {
        AppCommonToastMessage.show(
          message: result.message ?? 'Unable to verify mobile number',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: e.toString().replaceFirst('Exception: ', ''),
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Step 3: Register New Guest
  Future<void> registerGuest() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      AppCommonToastMessage.show(
        message: 'Please enter cashier full name',
        type: ToastType.warning,
      );
      nameFocusNode.requestFocus();
      return;
    }

    isLoading.value = true;
    try {
      final result = await _authRepository.guestRegister(
        mobile: guestMobile.value,
        name: name,
        guestFlowToken: guestFlowToken,
      );

      if (result.status) {
        guestName.value = name;
        currentStep.value = GuestFlowStep.waitingForApproval;
        AppCommonToastMessage.show(
          message: result.message ?? 'Registration submitted for Web Admin approval',
          type: ToastType.success,
        );
      } else {
        AppCommonToastMessage.show(
          message: result.message ?? 'Registration failed',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: e.toString().replaceFirst('Exception: ', ''),
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Step 4: Send OTP to Approved Guest Cashier
  Future<void> sendGuestOtp() async {
    isLoading.value = true;
    try {
      final result = await _authRepository.guestSendOtp(
        mobile: guestMobile.value,
        guestFlowToken: guestFlowToken,
      );

      if (result.status && (result.otpSent || result.otpVerificationToken != null)) {
        otpVerificationToken = result.otpVerificationToken;
        otpController.clear();
        currentStep.value = GuestFlowStep.verifyOtp;
        _startCooldown(60);

        AppCommonToastMessage.show(
          message: result.message ?? 'OTP sent successfully',
          type: ToastType.success,
        );

        Future.delayed(const Duration(milliseconds: 300), () {
          otpFocusNode.requestFocus();
        });
      } else {
        AppCommonToastMessage.show(
          message: result.message ?? 'Failed to send OTP',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: e.toString().replaceFirst('Exception: ', ''),
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Step 5: Verify Guest OTP & Complete JWT Login
  Future<void> verifyGuestOtp(String otp) async {
    if (otp.trim().length != 6) {
      AppCommonToastMessage.show(
        message: 'Please enter a valid 6-digit OTP',
        type: ToastType.warning,
      );
      return;
    }

    if (otpVerificationToken == null) {
      AppCommonToastMessage.show(
        message: 'OTP verification session expired. Please resend OTP.',
        type: ToastType.error,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await _authRepository.guestVerifyOtp(
        mobile: guestMobile.value,
        otp: otp.trim(),
        otpVerificationToken: otpVerificationToken!,
      );

      if (response['status'] == true && response['token'] != null) {
        AppCommonToastMessage.show(
          message: 'Guest Cashier Login Successful',
          type: ToastType.success,
        );

        // Close bottom sheet modal
        Get.back();

        // Navigate directly to Booking Unit Selection screen
        Get.offAllNamed(AppRoutes.bookingUnitSelection);
      } else {
        AppCommonToastMessage.show(
          message: response['message']?.toString() ?? 'OTP verification failed',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: e.toString().replaceFirst('Exception: ', ''),
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Re-check status when in waiting for approval step
  Future<void> recheckApprovalStatus() async {
    await checkGuestMobile();
  }
  // endregion
}
// endregion

// region GuestFlowBottomSheet View
class GuestFlowBottomSheet extends StatelessWidget {
  final GuestFlowController controller;

  const GuestFlowBottomSheet({
    super.key,
    required this.controller,
  });

  static Future<void> show(BuildContext context, {required String guestFlowToken}) async {
    final c = Get.put(GuestFlowController(guestFlowToken: guestFlowToken));
    await AppCommonBottomSheet.showModal(
      context,
      title: 'Guest Cashier Verification',
      child: GuestFlowBottomSheet(controller: c),
    );
    if (Get.isRegistered<GuestFlowController>()) {
      Get.delete<GuestFlowController>();
    }
  }

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.currentStep.value) {
        case GuestFlowStep.enterMobile:
          return _buildMobileStep();
        case GuestFlowStep.enterNameRegistration:
          return _buildRegistrationStep();
        case GuestFlowStep.waitingForApproval:
          return _buildWaitingForApprovalStep();
        case GuestFlowStep.verifyOtp:
          return _buildVerifyOtpStep();
      }
    });
  }
  // endregion

  // region Step 1: Mobile Entry
  Widget _buildMobileStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Parent account verified. Please enter the Cashier’s 10-digit mobile number to proceed with booking access.',
          style: AppTextStyle.style_13_400(color: AppColors.grey500),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20.h),
        AppCommonTextField(
          controller: controller.mobileController,
          focusNode: controller.mobileFocusNode,
          titleText: 'Mobile Number',
          hintText: 'Enter 10-digit mobile',
          useFloatingLabel: true,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          borderRadius: 8.r,
          fillColor: AppColors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          prefixIconConstraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
          prefixIcon: Icon(
            Icons.phone_android_rounded,
            size: 18.sp,
            color: AppColors.iconPrimary,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) {
            if (!controller.isMobileChecked.value) {
              controller.checkGuestMobile();
            }
          },
        ),
        SizedBox(height: 16.h),
        Obx(() {
          if (!controller.isMobileChecked.value) {
            return AppCommonButton(
              width: double.infinity,
              height: 38.h,
              textSize: 13.sp,
              borderRadius: 8.r,
              buttonColor: AppColors.primary,
              textColor: AppColors.white,
              text: 'Check Mobile Number',
              isLoading: controller.isLoading.value,
              onPressed: controller.checkGuestMobile,
            );
          }

          // Mobile checked & approved: show Guest Name and Send OTP button
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 6,
                child: AppCommonTextField(
                  controller: controller.guestNameController,
                  titleText: 'Guest Name',
                  hintText: 'Guest Name',
                  useFloatingLabel: true,
                  readOnly: true,
                  borderRadius: 8.r,
                  fillColor: AppColors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  prefixIconConstraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                    size: 18.sp,
                    color: AppColors.iconPrimary,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                flex: 5,
                child: AppCommonButton(
                  height: 38.h,
                  textSize: 13.sp,
                  borderRadius: 8.r,
                  buttonColor: AppColors.primary,
                  textColor: AppColors.white,
                  icon: Icons.sms_outlined,
                  text: 'Send OTP',
                  isLoading: controller.isLoading.value,
                  onPressed: controller.sendGuestOtp,
                ),
              ),
            ],
          );
        }),
        SizedBox(height: 12.h),
      ],
    );
  }
  // endregion

  // region Step 2: New Cashier Registration
  Widget _buildRegistrationStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.blue500.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18.sp, color: AppColors.blue500),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'New guest detected. Enter name to submit for Admin approval.',
                  style: AppTextStyle.style_12_500(color: AppColors.blue500),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        AppCommonTextField(
          controller: TextEditingController(text: controller.guestMobile.value),
          hintText: 'Mobile Number',
          titleText: 'Mobile Number',
          useFloatingLabel: true,
          readOnly: true,
          borderRadius: 8.r,
          fillColor: AppColors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          prefixIconConstraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
          prefixIcon: Icon(
            Icons.phone_android_rounded,
            size: 18.sp,
            color: AppColors.iconPrimary,
          ),
        ),
        SizedBox(height: 14.h),
        AppCommonTextField(
          controller: controller.nameController,
          focusNode: controller.nameFocusNode,
          titleText: 'Cashier Full Name',
          hintText: 'e.g. Rahul Sharma',
          useFloatingLabel: true,
          textCapitalization: TextCapitalization.words,
          borderRadius: 8.r,
          fillColor: AppColors.white,
          prefixIcon: Icon(Icons.person_outline, size: 18.sp, color: AppColors.iconPrimary),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => controller.registerGuest(),
        ),
        SizedBox(height: 20.h),
        Obx(
          () => AppCommonButton(
            width: double.infinity,
            height: 38.h,
            textSize: 13.sp,
            borderRadius: 8.r,
            buttonColor: AppColors.primary,
            textColor: AppColors.white,
            text: 'Submit for Admin Approval',
            isLoading: controller.isLoading.value,
            onPressed: controller.registerGuest,
          ),
        ),
        SizedBox(height: 8.h),
        TextButton(
          onPressed: () {
            controller.currentStep.value = GuestFlowStep.enterMobile;
          },
          child: Text(
            'Change Mobile Number',
            style: AppTextStyle.style_12_500(color: AppColors.grey500),
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
  // endregion

  // region Step 3: Waiting for Approval
  Widget _buildWaitingForApprovalStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_top_rounded,
              size: 28.sp,
              color: AppColors.warning,
            ),
          ),
        ),
        SizedBox(height: 14.h),
        Text(
          'Waiting for Admin Approval',
          style: AppTextStyle.style_16_700(color: AppColors.black),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6.h),
        Text(
          'Registration exists for ${controller.guestName.value.isNotEmpty ? controller.guestName.value : controller.guestMobile.value}.\nOTP login is disabled until the account is approved via the Web Admin Panel.',
          style: AppTextStyle.style_12_400(color: AppColors.grey500),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 22.h),
        Obx(
          () => AppCommonButton(
            width: double.infinity,
            height: 38.h,
            textSize: 13.sp,
            borderRadius: 8.r,
            buttonColor: AppColors.primary,
            textColor: AppColors.white,
            text: 'Check Approval Status',
            isLoading: controller.isLoading.value,
            onPressed: controller.recheckApprovalStatus,
          ),
        ),
        SizedBox(height: 10.h),
        TextButton(
          onPressed: () {
            controller.currentStep.value = GuestFlowStep.enterMobile;
          },
          child: Text(
            'Use Different Mobile Number',
            style: AppTextStyle.style_12_500(color: AppColors.grey500),
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
  // endregion

  // region Step 4: OTP Verification
  Widget _buildVerifyOtpStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Enter the 6-digit OTP sent to\n${controller.guestMobile.value} (${controller.guestName.value})',
          style: AppTextStyle.style_13_400(color: AppColors.grey500),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20.h),
        Center(
          child: Pinput(
            controller: controller.otpController,
            focusNode: controller.otpFocusNode,
            length: 6,
            autofocus: true,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            keyboardType: TextInputType.number,
            defaultPinTheme: PinTheme(
              width: 44.w,
              height: 46.h,
              textStyle: AppTextStyle.style_18_700(color: AppColors.black),
              decoration: BoxDecoration(
                color: AppColors.blue500.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.grey200),
              ),
            ),
            focusedPinTheme: PinTheme(
              width: 44.w,
              height: 46.h,
              textStyle: AppTextStyle.style_18_700(color: AppColors.black),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.primary, width: 1.8),
              ),
            ),
            onCompleted: (pin) {
              if (!controller.isLoading.value) {
                controller.verifyGuestOtp(pin);
              }
            },
          ),
        ),
        SizedBox(height: 20.h),
        Obx(
          () => AppCommonButton(
            width: double.infinity,
            height: 38.h,
            textSize: 13.sp,
            borderRadius: 8.r,
            buttonColor: AppColors.primary,
            textColor: AppColors.white,
            text: 'Verify & Login',
            isLoading: controller.isLoading.value,
            onPressed: () {
              if (controller.otpController.text.length == 6) {
                controller.verifyGuestOtp(controller.otpController.text);
              } else {
                AppCommonToastMessage.show(
                  message: 'Please enter a valid 6-digit OTP',
                  type: ToastType.warning,
                );
              }
            },
          ),
        ),
        SizedBox(height: 12.h),
        Obx(() {
          final cd = controller.resendCooldown.value;
          if (cd > 0) {
            return Center(
              child: Text(
                'Resend OTP in ${cd}s',
                style: AppTextStyle.style_12_500(color: AppColors.grey400),
              ),
            );
          }
          return Center(
            child: TextButton(
              onPressed: controller.isLoading.value ? null : controller.sendGuestOtp,
              child: Text(
                'Resend OTP',
                style: AppTextStyle.style_13_600(color: AppColors.primary),
              ),
            ),
          );
        }),
        SizedBox(height: 8.h),
      ],
    );
  }
  // endregion
}
// endregion

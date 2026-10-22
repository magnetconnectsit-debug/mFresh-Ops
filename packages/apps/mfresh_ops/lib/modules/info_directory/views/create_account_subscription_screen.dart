// region Imports
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/create_account_subscription_controller.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
// endregion

// region CreateAccountSubscriptionScreen Class
class CreateAccountSubscriptionScreen extends StatelessWidget {
  const CreateAccountSubscriptionScreen({super.key});

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateAccountSubscriptionController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(controller),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
              child: Container(
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAccountAndCompanyRow(context, controller),
                      SizedBox(height: 8.h),
                      _buildBrandAndServiceRow(context, controller),
                      SizedBox(height: 8.h),
                      _buildUnitAndCityRow(context, controller),
                      SizedBox(height: 8.h),
                      _buildLocationAndCustomerIdRow(context, controller),
                      SizedBox(height: 8.h),
                      _buildMobileAndEmailRow(context, controller),
                      SizedBox(height: 8.h),
                      _buildUserNameAndPasswordRow(context, controller),
                      SizedBox(height: 8.h),
                      _buildUrlsAndRemarksRow(context, controller),
                      SizedBox(height: 8.h),
                      _buildPlanNameAndPaymentRow(context, controller),
                      SizedBox(height: 8.h),
                      _buildBillingCycleAndNextDueRow(context, controller),
                      SizedBox(height: 8.h),
                      _buildLastPaymentRow(context, controller),
                      SizedBox(height: 8.h),
                      _buildPaymentDetailsField(context, controller),
                      SizedBox(height: 8.h),
                      _buildCommentsField(context, controller),
                      SizedBox(height: 32.h),
                      _buildActionButtons(controller),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  // endregion

  // region App Bar
  PreferredSizeWidget _buildAppBar(
    CreateAccountSubscriptionController controller,
  ) {
    return AppCommonAppBar(
      topHeader: const CommonShortcutHeader(),
      title: Obx(
        () => Text(
          controller.isEdit.value ? 'Update Account' : 'Create Account',
          style: AppTextStyle.style_18_700(color: AppColors.black),
        ),
      ),
      hasBackButton: true,
      showAppDrawer: false,
    );
  }
  // endregion

  // region Form Field Rows
  Widget _buildAccountAndCompanyRow(
    BuildContext context,
    CreateAccountSubscriptionController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 0: Account *
        Expanded(
          child: SizedBox(
            height: 32.h,
            child: Obx(
              () => AppCommonMultiSelectDropdown<String>(
                key: controller.accountKey,
                label: 'Account *',
                isSingleSelect: true,
                selectedValues: controller.selectedAccount.value.isEmpty
                    ? {}
                    : {controller.selectedAccount.value},
                items: controller.accountList.map((acc) {
                  return DropdownMenuItem(
                    value: acc.id.toString(),
                    child: Text(
                      acc.accountName,
                      style: AppTextStyle.style_12_400(
                        color: AppColors.grey900,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val.isNotEmpty) {
                    controller.selectedAccount.value = val.first;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.focusNextUnfilledField(0, context);
                    });
                  } else {
                    controller.selectedAccount.value = '';
                  }
                },
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        // 1: Company
        Expanded(
          child: AppCommonTextField(
            controller: controller.companyCtrl,
            focusNode: controller.companyFocus,
            labelText: 'Company',
            hintText: 'Enter company',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(1, context),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandAndServiceRow(
    BuildContext context,
    CreateAccountSubscriptionController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 2: Brand
        Expanded(
          child: AppCommonTextField(
            controller: controller.brandCtrl,
            focusNode: controller.brandFocus,
            labelText: 'Brand',
            hintText: 'Enter brand',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(2, context),
          ),
        ),
        SizedBox(width: 16.w),
        // 3: Service
        Expanded(
          child: AppCommonTextField(
            controller: controller.serviceCtrl,
            focusNode: controller.serviceFocus,
            labelText: 'Service',
            hintText: 'Enter service',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(3, context),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitAndCityRow(
    BuildContext context,
    CreateAccountSubscriptionController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 4: Unit
        Expanded(
          child: AppCommonTextField(
            controller: controller.unitCtrl,
            focusNode: controller.unitFocus,
            labelText: 'Unit',
            hintText: 'Enter unit',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(4, context),
          ),
        ),
        SizedBox(width: 16.w),
        // 5: City
        Expanded(
          child: AppCommonTextField(
            controller: controller.cityCtrl,
            focusNode: controller.cityFocus,
            labelText: 'City',
            hintText: 'Enter city',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(5, context),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationAndCustomerIdRow(
    BuildContext context,
    CreateAccountSubscriptionController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 6: Location
        Expanded(
          child: AppCommonTextField(
            controller: controller.locationCtrl,
            focusNode: controller.locationFocus,
            labelText: 'Location',
            hintText: 'Enter location',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(6, context),
          ),
        ),
        SizedBox(width: 16.w),
        // 7: Customer ID
        Expanded(
          child: AppCommonTextField(
            controller: controller.customerIdCtrl,
            focusNode: controller.customerIdFocus,
            labelText: 'Customer ID',
            hintText: 'Enter customer ID',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(7, context),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileAndEmailRow(
    BuildContext context,
    CreateAccountSubscriptionController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 8: Mobile No
        Expanded(
          child: AppCommonTextField(
            controller: controller.mobileNoCtrl,
            focusNode: controller.mobileNoFocus,
            labelText: 'Mobile No',
            hintText: 'Enter mobile number',
            height: 32.h,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(8, context),
          ),
        ),
        SizedBox(width: 16.w),
        // 9: Email
        Expanded(
          child: AppCommonTextField(
            controller: controller.emailCtrl,
            focusNode: controller.emailFocus,
            labelText: 'Email',
            hintText: 'Enter email address',
            height: 32.h,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(9, context),
          ),
        ),
      ],
    );
  }

  Widget _buildUserNameAndPasswordRow(
    BuildContext context,
    CreateAccountSubscriptionController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 10: User Name
        Expanded(
          child: AppCommonTextField(
            controller: controller.userNameCtrl,
            focusNode: controller.userNameFocus,
            labelText: 'User Name',
            hintText: 'Enter user name',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(10, context),
          ),
        ),
        SizedBox(width: 16.w),
        // 11: Password
        Expanded(
          child: AppCommonTextField(
            controller: controller.passwordCtrl,
            focusNode: controller.passwordFocus,
            labelText: 'Password',
            hintText: 'Enter password',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(11, context),
          ),
        ),
      ],
    );
  }

  Widget _buildUrlsAndRemarksRow(
    BuildContext context,
    CreateAccountSubscriptionController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 12: URLs
        Expanded(
          child: AppCommonTextField(
            controller: controller.urlsCtrl,
            focusNode: controller.urlsFocus,
            labelText: 'URLs',
            hintText: 'Enter URLs',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(12, context),
          ),
        ),
        SizedBox(width: 16.w),
        // 13: Remarks
        Expanded(
          child: AppCommonTextField(
            controller: controller.remarksCtrl,
            focusNode: controller.remarksFocus,
            labelText: 'Remarks',
            hintText: 'Enter remarks',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(13, context),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanNameAndPaymentRow(
    BuildContext context,
    CreateAccountSubscriptionController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 14: Plan Name
        Expanded(
          child: AppCommonTextField(
            controller: controller.planNameCtrl,
            focusNode: controller.planNameFocus,
            labelText: 'Plan Name',
            hintText: 'Enter plan name',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(14, context),
          ),
        ),
        SizedBox(width: 16.w),
        // 15: Payment
        Expanded(
          child: SizedBox(
            height: 32.h,
            child: Obx(
              () => AppCommonMultiSelectDropdown<String>(
                key: controller.paymentKey,
                label: 'Payment',
                isSingleSelect: true,
                selectedValues: controller.selectedPayment.value.isEmpty
                    ? {}
                    : {controller.selectedPayment.value},
                items: [
                  DropdownMenuItem(
                    value: '1',
                    child: Text(
                      'Yes',
                      style: AppTextStyle.style_12_400(
                        color: AppColors.grey900,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: '0',
                    child: Text(
                      'No',
                      style: AppTextStyle.style_12_400(
                        color: AppColors.grey900,
                      ),
                    ),
                  ),
                ],
                onChanged: (val) {
                  if (val.isNotEmpty) {
                    controller.selectedPayment.value = val.first;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.focusNextUnfilledField(15, context);
                    });
                  } else {
                    controller.selectedPayment.value = '';
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBillingCycleAndNextDueRow(
    BuildContext context,
    CreateAccountSubscriptionController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 16: Billing cycle & Due
        Expanded(
          child: AppCommonTextField(
            controller: controller.billingCycleCtrl,
            focusNode: controller.billingCycleFocus,
            labelText: 'Billing cycle & Due',
            hintText: 'Enter billing cycle & due',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(16, context),
          ),
        ),
        SizedBox(width: 16.w),
        // 17: Next Due On
        Expanded(
          child: Obx(
            () => AppCommonDateField(
              key: controller.nextDueKey,
              focusNode: controller.nextDueFocus,
              labelText: 'Next Due On',
              hintText: 'Select Date',
              height: 32.h,
              selectedDate: controller.nextDueDateTime,
              onDateSelected: (date) {
                controller.selectedNextDue.value =
                    "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.focusNextUnfilledField(17, context);
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastPaymentRow(
    BuildContext context,
    CreateAccountSubscriptionController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 18: Last Payment
        Expanded(
          child: Obx(
            () => AppCommonDateField(
              key: controller.lastPaymentKey,
              focusNode: controller.lastPaymentFocus,
              labelText: 'Last Payment',
              hintText: 'Select Date',
              height: 32.h,
              selectedDate: controller.lastPaymentDateTime,
              onDateSelected: (date) {
                controller.selectedLastPayment.value =
                    "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.focusNextUnfilledField(18, context);
                });
              },
            ),
          ),
        ),
        SizedBox(width: 16.w),
        const Expanded(child: SizedBox()),
      ],
    );
  }

  Widget _buildPaymentDetailsField(
    BuildContext context,
    CreateAccountSubscriptionController controller,
  ) {
    // 19: Payment Details
    return AppCommonTextField(
      controller: controller.paymentDetailsCtrl,
      focusNode: controller.paymentDetailsFocus,
      labelText: 'Payment Details',
      hintText: 'Enter payment details',
      maxLines: 2,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => controller.focusNextUnfilledField(19, context),
    );
  }

  Widget _buildCommentsField(
    BuildContext context,
    CreateAccountSubscriptionController controller,
  ) {
    // 20: Comments
    return AppCommonTextField(
      controller: controller.commentsCtrl,
      focusNode: controller.commentsFocus,
      labelText: 'Comments',
      hintText: 'Enter comments',
      maxLines: 1,
      height: 32.h,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => controller.focusNextUnfilledField(20, context),
    );
  }
  // endregion

  // region Action Handlers & Submit Buttons
  Widget _buildActionButtons(CreateAccountSubscriptionController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AppCommonButton(
          text: 'Cancel',
          onPressed: () => Get.back(),
          variant: ButtonVariant.outline,
          buttonColor: AppColors.white,
          borderColor: AppColors.borderColor,
          textColor: AppColors.black,
          height: 30.h,
          width: 80.w,
          borderRadius: 4.r,
        ),
        SizedBox(width: 12.w),
        Obx(
          () => AppCommonButton(
            text: 'Submit',
            isLoading: controller.isLoading.value,
            onPressed: controller.isLoading.value ? null : controller.submit,
            buttonColor: AppColors.primary,
            textColor: AppColors.white,
            height: 30.h,
            width: 80.w,
            borderRadius: 4.r,
          ),
        ),
      ],
    );
  }
  // endregion
}
// endregion

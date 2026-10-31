// region Imports
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/create_contact_controller.dart';
// endregion

// region CreateContactScreen Class
class CreateContactScreen extends StatelessWidget {
  const CreateContactScreen({super.key});

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateContactController());

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CommonSidebar(),
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
                      _buildContactTypeAndNameRow(context, controller),
                      SizedBox(height: 8.h),
                      _buildBrandAndCompanyRow(context, controller),
                      SizedBox(height: 8.h),
                      _buildWorkedOnAndGstinRow(context, controller),
                      SizedBox(height: 8.h),
                      _buildDesignationAndDepartmentRow(context, controller),
                      SizedBox(height: 8.h),
                      _buildMobileRow(context, controller),
                      SizedBox(height: 8.h),
                      _buildEmailAndLevelRow(context, controller),
                      SizedBox(height: 8.h),
                      _buildTypeServiceField(context, controller),
                      SizedBox(height: 8.h),
                      _buildLocationField(context, controller),
                      SizedBox(height: 8.h),
                      _buildAddressField(context, controller),
                      SizedBox(height: 8.h),
                      _buildWebsiteLinksField(context, controller),
                      SizedBox(height: 8.h),
                      _buildCommentField(context, controller),
                      SizedBox(height: 8.h),
                      _buildAttachmentSection(controller),
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
  PreferredSizeWidget _buildAppBar(CreateContactController controller) {
    return AppCommonAppBar(
      topHeader: const CommonShortcutHeader(),
      title: Obx(
        () => Text(
          controller.isEdit.value ? 'Edit Contact' : 'Create Contact',
          style: AppTextStyle.style_18_700(color: AppColors.black),
        ),
      ),
    );
  }
  // endregion

  // region Form Field Rows
  Widget _buildContactTypeAndNameRow(
    BuildContext context,
    CreateContactController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 0: Contact Type
        Expanded(
          child: SizedBox(
            height: 32.h,
            child: Obx(
              () => AppCommonMultiSelectDropdown<String>(
                key: controller.contactTypeKey,
                label: 'Contact Type',
                isSingleSelect: true,
                showSearch: true,
                selectedValues: controller.selectedContactType.value == null
                    ? <String>{}
                    : {controller.selectedContactType.value!},
                items: controller.availableContactTypes
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(
                          e,
                          style: AppTextStyle.style_12_400(
                            color: AppColors.grey900,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (values) {
                  controller.selectedContactType.value =
                      values.isEmpty ? null : values.first;
                  if (values.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.focusNextUnfilledField(0, context);
                    });
                  }
                },
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        // 1: Name *
        Expanded(
          child: AppCommonTextField(
            controller: controller.nameCtrl,
            focusNode: controller.nameFocus,
            labelText: 'Name',
            hintText: 'Enter name',
            isRequired: true,
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(1, context),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Name is required';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBrandAndCompanyRow(
    BuildContext context,
    CreateContactController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 2: Brand
        Expanded(
          child: SizedBox(
            height: 32.h,
            child: Obx(
              () => AppCommonMultiSelectDropdown<String>(
                key: controller.brandKey,
                label: 'Brand',
                isSingleSelect: true,
                showSearch: true,
                selectedValues: controller.selectedBrand.value == null
                    ? <String>{}
                    : {controller.selectedBrand.value!},
                items: controller.availableBrands
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e['id'].toString(),
                        child: Text(
                          e['name']?.toString() ?? '',
                          style: AppTextStyle.style_12_400(
                            color: AppColors.grey900,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (values) {
                  controller.selectedBrand.value =
                      values.isEmpty ? null : values.first;
                  if (values.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.focusNextUnfilledField(2, context);
                    });
                  }
                },
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        // 3: Company
        Expanded(
          child: SizedBox(
            height: 32.h,
            child: Obx(
              () => AppCommonMultiSelectDropdown<String>(
                key: controller.companyKey,
                label: 'Company',
                isSingleSelect: true,
                showSearch: true,
                selectedValues: controller.selectedCompany.value == null
                    ? <String>{}
                    : {controller.selectedCompany.value!},
                items: controller.availableCompanies
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e['id'].toString(),
                        child: Text(
                          e['name']?.toString() ?? '',
                          style: AppTextStyle.style_12_400(
                            color: AppColors.grey900,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (values) {
                  controller.selectedCompany.value =
                      values.isEmpty ? null : values.first;
                  if (values.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.focusNextUnfilledField(3, context);
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkedOnAndGstinRow(
    BuildContext context,
    CreateContactController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 4: Worked On
        Expanded(
          child: AppCommonTextField(
            controller: controller.workedOnCtrl,
            focusNode: controller.workedOnFocus,
            labelText: 'Worked On',
            hintText: 'Enter worked on',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(4, context),
          ),
        ),
        SizedBox(width: 16.w),
        // 5: GST IN
        Expanded(
          child: AppCommonTextField(
            controller: controller.gstinCtrl,
            focusNode: controller.gstinFocus,
            labelText: 'GST IN',
            hintText: 'Enter GST IN',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(5, context),
          ),
        ),
      ],
    );
  }

  Widget _buildDesignationAndDepartmentRow(
    BuildContext context,
    CreateContactController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 6: Designation
        Expanded(
          child: AppCommonTextField(
            controller: controller.designationCtrl,
            focusNode: controller.designationFocus,
            labelText: 'Designation',
            hintText: 'Enter designation',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(6, context),
          ),
        ),
        SizedBox(width: 16.w),
        // 7: Department
        Expanded(
          child: AppCommonTextField(
            controller: controller.departmentCtrl,
            focusNode: controller.departmentFocus,
            labelText: 'Department',
            hintText: 'Enter department',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(7, context),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileRow(
    BuildContext context,
    CreateContactController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 8: Mobile 1 *
        Expanded(
          child: AppCommonTextField(
            controller: controller.mobile1Ctrl,
            focusNode: controller.mobile1Focus,
            labelText: 'Mobile 1',
            hintText: 'Enter mobile 1',
            isRequired: true,
            height: 32.h,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(8, context),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Mobile 1 is required';
              }
              if (!RegExp(r'^\d{10}$').hasMatch(val.trim())) {
                return 'Enter valid 10-digit number';
              }
              return null;
            },
          ),
        ),
        SizedBox(width: 16.w),
        // 9: Mobile 2
        Expanded(
          child: AppCommonTextField(
            controller: controller.mobile2Ctrl,
            focusNode: controller.mobile2Focus,
            labelText: 'Mobile 2',
            hintText: 'Enter mobile 2',
            height: 32.h,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(9, context),
            validator: (val) {
              if (val != null && val.trim().isNotEmpty) {
                if (!RegExp(r'^\d{10}$').hasMatch(val.trim())) {
                  return 'Enter valid 10-digit number';
                }
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmailAndLevelRow(
    BuildContext context,
    CreateContactController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 10: Email
        Expanded(
          child: AppCommonTextField(
            controller: controller.emailCtrl,
            focusNode: controller.emailFocus,
            labelText: 'Email',
            hintText: 'Enter email',
            height: 32.h,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(10, context),
          ),
        ),
        SizedBox(width: 16.w),
        // 11: Level *
        Expanded(
          child: SizedBox(
            height: 32.h,
            child: Obx(
              () => AppCommonMultiSelectDropdown<String>(
                key: controller.levelKey,
                label: 'Level *',
                isSingleSelect: true,
                showSearch: true,
                selectedValues: controller.selectedLevel.value == null
                    ? <String>{}
                    : {controller.selectedLevel.value!},
                items: ['1', '2', '3']
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(
                          'Level $e',
                          style: AppTextStyle.style_12_400(
                            color: AppColors.grey900,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (values) {
                  controller.selectedLevel.value =
                      values.isEmpty ? null : values.first;
                  if (values.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.focusNextUnfilledField(11, context);
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeServiceField(
    BuildContext context,
    CreateContactController controller,
  ) {
    // 12: Type Service *
    return AppCommonTextField(
      controller: controller.typeServiceCtrl,
      focusNode: controller.typeServiceFocus,
      labelText: 'Type Service',
      hintText: 'Enter type service',
      isRequired: true,
      height: 32.h,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => controller.focusNextUnfilledField(12, context),
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'Type Service is required';
        }
        return null;
      },
    );
  }

  Widget _buildLocationField(
    BuildContext context,
    CreateContactController controller,
  ) {
    // 13: Location
    return AppCommonTextField(
      controller: controller.locationCtrl,
      focusNode: controller.locationFocus,
      labelText: 'Location',
      hintText: 'Enter location',
      height: 32.h,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => controller.focusNextUnfilledField(13, context),
    );
  }

  Widget _buildAddressField(
    BuildContext context,
    CreateContactController controller,
  ) {
    // 14: Address
    return AppCommonTextField(
      controller: controller.addressCtrl,
      focusNode: controller.addressFocus,
      labelText: 'Address',
      hintText: 'Enter address',
      height: 32.h,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => controller.focusNextUnfilledField(14, context),
    );
  }

  Widget _buildWebsiteLinksField(
    BuildContext context,
    CreateContactController controller,
  ) {
    // 15: Website Links
    return AppCommonTextField(
      controller: controller.websiteLinksCtrl,
      focusNode: controller.websiteLinksFocus,
      labelText: 'Website Links',
      hintText: 'Enter website links',
      height: 32.h,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => controller.focusNextUnfilledField(15, context),
    );
  }

  Widget _buildCommentField(
    BuildContext context,
    CreateContactController controller,
  ) {
    // 16: Comment/Description
    return AppCommonTextField(
      controller: controller.commentCtrl,
      focusNode: controller.commentFocus,
      labelText: 'Comment/Description',
      hintText: 'Enter comment or description',
      maxLines: 2,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => controller.focusNextUnfilledField(16, context),
    );
  }
  // endregion

  // region File Attachment
  Widget _buildAttachmentSection(CreateContactController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attach Files',
          style: AppTextStyle.style_12_700(color: AppColors.black),
        ),
        SizedBox(height: 8.h),
        AppCommonButton(
          text: 'Choose file',
          onPressed: controller.pickFile,
          buttonColor: AppColors.white,
          textColor: AppColors.black,
          borderColor: AppColors.borderColor,
          variant: ButtonVariant.outline,
          height: 30.h,
          width: 110.w,
          borderRadius: 4.r,
        ),
        SizedBox(height: 8.h),
        Obx(() {
          if (controller.selectedFiles.isEmpty) {
            return const SizedBox.shrink();
          }
          return Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: List.generate(
              controller.selectedFiles.length,
              (i) => _buildFileChip(controller, i),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFileChip(CreateContactController controller, int index) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, size: 14.sp, color: AppColors.grey900),
          SizedBox(width: 4.w),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 120.w),
            child: Text(
              controller.selectedFileNames[index],
              style: AppTextStyle.style_12_400(color: AppColors.grey900),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: () => controller.removeFile(index),
            child: Icon(Icons.close, size: 14.sp, color: AppColors.red),
          ),
        ],
      ),
    );
  }
  // endregion

  // region Action Handlers & Submit Buttons
  Widget _buildActionButtons(CreateContactController controller) {
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

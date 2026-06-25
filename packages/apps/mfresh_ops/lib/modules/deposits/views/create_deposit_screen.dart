import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/modules/deposits/controllers/create_deposit_controller.dart';
import 'package:core/widgets/month_year_picker_field.dart';
import 'package:intl/intl.dart';

class CreateDepositScreen extends StatelessWidget {
  const CreateDepositScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Delete existing controller to make sure it recreates with fresh state (especially when switching between add and edit)
    Get.delete<CreateDepositController>();
    final controller = Get.put(CreateDepositController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        hasBackButton: true,
        title: Text(
          controller.editingItem != null ? 'Edit Deposit' : 'Deposite Cash',
          style: const TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: controller.formKey,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: AppColors.borderColor, width: 1.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4.r),
                      topRight: Radius.circular(4.r),
                    ),
                    border: Border(
                      bottom: BorderSide(color: AppColors.borderColor, width: 1.0),
                    ),
                  ),
                  child: Text(
                    controller.editingItem != null ? 'Edit Deposit Form' : 'Deposit Form',
                    style: AppTextStyle.style_14_600(color: AppColors.black),
                  ),
                ),
                
                // Form Body
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Deposited Date*'),
                      SizedBox(height: 6.h),
                      _buildDateField(controller),
                      
                      SizedBox(height: 16.h),
                      _buildLabel('Actual Deposit*'),
                      SizedBox(height: 6.h),
                      _buildTextField(controller),
                      
                      SizedBox(height: 16.h),
                      _buildLabel('For Month*'),
                      SizedBox(height: 6.h),
                      _buildMonthField(controller),
                      
                      SizedBox(height: 16.h),
                      _buildLabel(controller.editingItem != null ? 'Supervisor File (PDF/Image)' : 'Supervisor File* (PDF/Image)'),
                      SizedBox(height: 6.h),
                      _buildFilePicker(controller),
                      
                      SizedBox(height: 16.h),
                      _buildLabel('Remarks'),
                      SizedBox(height: 6.h),
                      _buildTextArea(controller),
                      
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        height: 40.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D6EFD), // Blue button from mockup
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                          ),
                          onPressed: controller.submit,
                          child: Text(
                            controller.editingItem != null ? 'Update' : 'Submit',
                            style: AppTextStyle.style_14_600(color: AppColors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyle.style_12_600(color: AppColors.black),
    );
  }

  Widget _buildTextField(CreateDepositController controller) {
    return TextFormField(
      controller: controller.actualDepositController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(color: AppColors.borderColor, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(color: AppColors.borderColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: const BorderSide(color: Color(0xffF15A24), width: 1.5),
        ),
      ),
      style: AppTextStyle.style_12_400(color: AppColors.black),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter actual deposit amount';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  Widget _buildTextArea(CreateDepositController controller) {
    return TextFormField(
      controller: controller.remarksController,
      maxLines: 4,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(color: AppColors.borderColor, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(color: AppColors.borderColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: const BorderSide(color: Color(0xffF15A24), width: 1.5),
        ),
      ),
      style: AppTextStyle.style_12_400(color: AppColors.black),
    );
  }

  Widget _buildDateField(CreateDepositController controller) {
    return Obx(() => GestureDetector(
      onTap: controller.pickDate,
      child: Container(
        height: 36.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: AppColors.borderColor, width: 1.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Row(
          children: [
            Expanded(
              child: Text(
                controller.depositedDate.value ?? 'dd-mm-yyyy',
                style: AppTextStyle.style_12_400(
                  color: controller.depositedDate.value == null ? AppColors.grey300 : AppColors.black,
                ),
              ),
            ),
            Icon(Icons.calendar_today_outlined, size: 16.r, color: AppColors.black),
          ],
        ),
      ),
    ));
  }

  Widget _buildMonthField(CreateDepositController controller) {
    return Obx(() {
      String? displayVal;
      if (controller.forMonth.value != null) {
        try {
          final parsed = DateFormat('yyyy-MM').parse(controller.forMonth.value!);
          displayVal = DateFormat('MMM-yyyy').format(parsed);
        } catch (_) {
          displayVal = controller.forMonth.value;
        }
      }
      return MonthYearPickerField(
        value: displayVal,
        label: 'Select Month',
        onChanged: (val) {
          if (val == null) {
            controller.forMonth.value = null;
          } else {
            try {
              final parsed = DateFormat('MMM-yyyy').parse(val);
              controller.forMonth.value = DateFormat('yyyy-MM').format(parsed);
            } catch (_) {
              controller.forMonth.value = val;
            }
          }
        },
      );
    });
  }

  Widget _buildFilePicker(CreateDepositController controller) {
    return Obx(() {
      final hasFile = controller.supervisorFileName.value != null;
      return Container(
        height: 36.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: AppColors.borderColor, width: 1.0),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: controller.pickFile,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  border: Border(
                    right: BorderSide(color: AppColors.borderColor, width: 1.0),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Choose file',
                  style: AppTextStyle.style_12_400(color: AppColors.black),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  hasFile ? controller.supervisorFileName.value! : 'No file chosen',
                  style: AppTextStyle.style_12_400(color: AppColors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

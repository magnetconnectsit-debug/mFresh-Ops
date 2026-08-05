import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/account_subscription_controller.dart';
import 'package:mfresh_ops/data/models/account_subscription_model.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/modules/info_directory/views/widgets/info_directory_table.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:flutter/services.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';

const List<(String, double)> _kColumns = [
  ('Action', 65),
  ('Account', 70),
  ('Company', 85),
  ('Brand', 90),
  ('Service', 100),
  ('Unit', 90),
  ('City', 90),
  ('Location', 90),
  ('Customer ID', 100),
  ('Reg. Mob No', 120),
  ('Reg. Email', 130),
  ('User Name', 100),
  ('Password', 130),
  ('URLs', 110),
  ('Remarks', 80),
  ('Plan Name', 80),
  ('Payment', 75),
  ('Billing cycle & Due', 130),
  ('Next Due On', 110),
  ('Last Payment', 110),
  ('Payment Details', 120),
];

class AccountSubscriptionTable extends StatefulWidget {
  final AccountSubscriptionController controller;

  const AccountSubscriptionTable({super.key, required this.controller});

  @override
  State<AccountSubscriptionTable> createState() => _AccountSubscriptionTableState();
}

class _AccountSubscriptionTableState extends State<AccountSubscriptionTable> {
  final RxSet<int> _expandedRows = <int>{}.obs;
  final RxSet<int> _visiblePasswords = <int>{}.obs;
  final ScrollController _verticalController = ScrollController();
  final ScrollController _headerHorizontalController = ScrollController();
  final ScrollController _bodyHorizontalController = ScrollController();
  final ScrollController _bottomBarController = ScrollController();
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _headerHorizontalController.addListener(_syncFromHeader);
    _bodyHorizontalController.addListener(_syncFromBody);
    _bottomBarController.addListener(_syncFromBottomBar);
  }

  void _syncFromHeader() {
    if (_isSyncing) return;
    _isSyncing = true;
    if (_bodyHorizontalController.hasClients) {
      _bodyHorizontalController.jumpTo(_headerHorizontalController.offset);
    }
    if (_bottomBarController.hasClients) {
      _bottomBarController.jumpTo(_headerHorizontalController.offset);
    }
    _isSyncing = false;
  }

  void _syncFromBody() {
    if (_isSyncing) return;
    _isSyncing = true;
    if (_headerHorizontalController.hasClients) {
      _headerHorizontalController.jumpTo(_bodyHorizontalController.offset);
    }
    if (_bottomBarController.hasClients) {
      _bottomBarController.jumpTo(_bodyHorizontalController.offset);
    }
    _isSyncing = false;
  }

  void _syncFromBottomBar() {
    if (_isSyncing) return;
    _isSyncing = true;
    if (_bodyHorizontalController.hasClients) {
      _bodyHorizontalController.jumpTo(_bottomBarController.offset);
    }
    if (_headerHorizontalController.hasClients) {
      _headerHorizontalController.jumpTo(_bottomBarController.offset);
    }
    _isSyncing = false;
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _headerHorizontalController.dispose();
    _bodyHorizontalController.dispose();
    _bottomBarController.dispose();
    super.dispose();
  }

  void _toggleRow(int id) {
    if (_expandedRows.contains(id)) {
      _expandedRows.remove(id);
    } else {
      _expandedRows.add(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final userPermissions = Get.find<AuthRepository>().rxUserPermissions;
      bool canEdit = userPermissions.contains('Account_subscription_Edit');
      bool canDelete = userPermissions.contains('Account_subscription_Delete');
      final showAction = canEdit || canDelete;

      final activeColumns = _kColumns;

      final columnWidths = <int, TableColumnWidth>{
        for (int i = 0; i < activeColumns.length; i++) i: FixedColumnWidth(activeColumns[i].$2.w),
      };

      final double totalTableWidth = activeColumns.fold(0.0, (sum, col) => sum + col.$2.w);

      final isLoadingInitial =
          widget.controller.isLoading.value &&
          widget.controller.subscriptions.isEmpty;
      final showEmpty = !isLoadingInitial && widget.controller.subscriptions.isEmpty;

      if (showEmpty) {
        return RefreshIndicator(
          onRefresh: () async => widget.controller.resetFiltersAndRefresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: 400.h,
                child: Center(
                  child: Text(
                    'No records found.',
                    style: AppTextStyle.style_14_400(color: AppColors.grey600),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: SingleChildScrollView(
              controller: _headerHorizontalController,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder.symmetric(
                  inside: BorderSide(color: Colors.grey.shade300),
                ),
                columnWidths: columnWidths,
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFC5D5F0)),
                    children: activeColumns
                        .map((c) => InfoDirectoryHeaderCell(text: c.$1))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => widget.controller.resetFiltersAndRefresh(),
              notificationPredicate: (notification) => notification.depth == 1,
              child: Scrollbar(
                controller: _verticalController,
                thumbVisibility: true,
                interactive: true,
                thickness: 8.0,
                radius: const Radius.circular(4),
                child: SingleChildScrollView(
                  controller: _bodyHorizontalController,
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: totalTableWidth + 2.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        left: BorderSide(color: AppColors.borderColor),
                        right: BorderSide(color: AppColors.borderColor),
                        bottom: BorderSide(color: AppColors.borderColor),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Obx(() {
                            final isLoadingInitial =
                                widget.controller.isLoading.value &&
                                widget.controller.subscriptions.isEmpty;

                            final listCount = isLoadingInitial
                                ? 20
                                : widget.controller.subscriptions.length;

                            return Skeletonizer(
                              enabled: isLoadingInitial,
                              child: ListView.builder(
                                controller: _verticalController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: listCount,
                                itemBuilder: (context, index) {
                                  final sub = isLoadingInitial
                                      ? AccountSubscriptionModel(
                                          id: index,
                                          account: 'Loading',
                                          accountName: 'Loading Account Name',
                                          company: 'Loading Company Name',
                                          brand: 'Loading',
                                          service: 'Loading',
                                          unit: 'Loading',
                                          city: 'Loading',
                                          location: 'Loading',
                                          customerID: 'Loading',
                                          mobileNo: 'Loading',
                                          email: 'Loading',
                                          username: 'Loading',
                                          password: 'Loading',
                                          urls: 'Loading',
                                          remarks: 'Loading',
                                          planName: 'Loading',
                                          payment: '1',
                                          billingCycleDue: 'Loading',
                                          nextDue: 'Loading',
                                          lastPayment: 'Loading',
                                          paymentDetails: 'Loading',
                                          createdAt: 'Loading',
                                          updatedAt: 'Loading',
                                        )
                                      : widget.controller.subscriptions[index];

                                  return Obx(() {
                                    final isExpanded = _expandedRows.contains(sub.id);
                                    void toggleRow() => _toggleRow(sub.id);

                                    Widget buildCell(Widget child, double width) {
                                      return Container(
                                        width: width,
                                        alignment: isExpanded ? Alignment.topLeft : Alignment.centerLeft,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            right: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                        ),
                                        child: child,
                                      );
                                    }

                                    return Container(
                                      key: ValueKey('row_${sub.id}'),
                                      height: isExpanded ? null : 25.h,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                      ),
                                      child: IntrinsicHeight(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          if (showAction)
                                            buildCell(
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 4.w,
                                                  vertical: 2.h,
                                                ),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  alignment: Alignment.center,
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      if (canEdit)
                                                        InkWell(
                                                          onTap: () async {
                                                            final result = await Get.toNamed(
                                                              AppRoutes.createAccountSubscription,
                                                              arguments: sub,
                                                            );
                                                            if (result == true) {
                                                              widget.controller.fetchSubscriptions();
                                                            }
                                                          },
                                                          child: Container(
                                                            padding: const EdgeInsets.all(4),
                                                            decoration: BoxDecoration(
                                                              border: Border.all(color: Colors.grey),
                                                              borderRadius: BorderRadius.circular(4),
                                                            ),
                                                            child: const Icon(Icons.edit, size: 16),
                                                          ),
                                                        ),
                                                      if (canEdit && canDelete) SizedBox(width: 4.w),
                                                      if (canDelete)
                                                        InkWell(
                                                          onTap: () {
                                                            _showDeleteDialog(context, sub.id);
                                                          },
                                                          child: Container(
                                                            padding: const EdgeInsets.all(4),
                                                            decoration: BoxDecoration(
                                                              border: Border.all(color: Colors.grey),
                                                              borderRadius: BorderRadius.circular(4),
                                                            ),
                                                            child: const Icon(Icons.delete_outline, size: 16),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              _kColumns.firstWhere((c) => c.$1 == 'Action').$2.w,
                                            ),
                                          
                                          buildCell(InfoDirectoryDataCell(text: sub.accountName, isExpanded: isExpanded, onTap: toggleRow), _kColumns.firstWhere((c) => c.$1 == 'Account').$2.w),
                                          buildCell(InfoDirectoryDataCell(text: sub.company, isExpanded: isExpanded, onTap: toggleRow), _kColumns.firstWhere((c) => c.$1 == 'Company').$2.w),
                                          buildCell(InfoDirectoryDataCell(text: sub.brand, isExpanded: isExpanded, onTap: toggleRow), _kColumns.firstWhere((c) => c.$1 == 'Brand').$2.w),
                                          buildCell(InfoDirectoryDataCell(text: sub.service, isExpanded: isExpanded, onTap: toggleRow), _kColumns.firstWhere((c) => c.$1 == 'Service').$2.w),
                                          buildCell(InfoDirectoryDataCell(text: sub.unit, isExpanded: isExpanded, onTap: toggleRow), _kColumns.firstWhere((c) => c.$1 == 'Unit').$2.w),
                                          buildCell(InfoDirectoryDataCell(text: sub.city, isExpanded: isExpanded, onTap: toggleRow), _kColumns.firstWhere((c) => c.$1 == 'City').$2.w),
                                          buildCell(InfoDirectoryDataCell(text: sub.location, isExpanded: isExpanded, onTap: toggleRow), _kColumns.firstWhere((c) => c.$1 == 'Location').$2.w),
                                          buildCell(InfoDirectoryDataCell(text: sub.customerID, isExpanded: isExpanded, onTap: toggleRow), _kColumns.firstWhere((c) => c.$1 == 'Customer ID').$2.w),
                                          buildCell(InfoDirectoryMobileCell(text: sub.mobileNo, isExpanded: isExpanded, onTap: toggleRow), _kColumns.firstWhere((c) => c.$1 == 'Reg. Mob No').$2.w),
                                          buildCell(InfoDirectoryDataCell(text: sub.email, isExpanded: isExpanded, onTap: toggleRow), _kColumns.firstWhere((c) => c.$1 == 'Reg. Email').$2.w),
                                          buildCell(InfoDirectoryDataCell(text: sub.username, isExpanded: isExpanded, onTap: toggleRow), _kColumns.firstWhere((c) => c.$1 == 'User Name').$2.w),
                                            buildCell(_PasswordCell(text: sub.password, isExpanded: isExpanded, isVisible: _visiblePasswords.contains(sub.id), onToggle: () {
                                              if (_visiblePasswords.contains(sub.id)) _visiblePasswords.remove(sub.id);
                                              else _visiblePasswords.add(sub.id);
                                            }, onTap: toggleRow), _kColumns.firstWhere((c) => c.$1 == 'Password').$2.w),
                                          buildCell(InfoDirectoryWeblinkCell(text: sub.urls ?? '', isExpanded: isExpanded, onTap: toggleRow), _kColumns.firstWhere((c) => c.$1 == 'URLs').$2.w),
                                          buildCell(InfoDirectoryDataCell(text: sub.remarks ?? '', isExpanded: isExpanded, onTap: toggleRow), _kColumns.firstWhere((c) => c.$1 == 'Remarks').$2.w),
                                          buildCell(InfoDirectoryDataCell(text: sub.planName, isExpanded: isExpanded, onTap: toggleRow), _kColumns.firstWhere((c) => c.$1 == 'Plan Name').$2.w),
                                          buildCell(InfoDirectoryDataCell(text: sub.payment == '1' ? 'Yes' : 'No', isExpanded: isExpanded, onTap: toggleRow), _kColumns.firstWhere((c) => c.$1 == 'Payment').$2.w),
                                          buildCell(InfoDirectoryDataCell(text: sub.billingCycleDue, isExpanded: isExpanded, onTap: toggleRow), _kColumns.firstWhere((c) => c.$1 == 'Billing cycle & Due').$2.w),
                                          buildCell(InfoDirectoryDataCell(text: AppDateUtils.formatToOrdinalDate(sub.nextDue), isExpanded: isExpanded, onTap: toggleRow), _kColumns.firstWhere((c) => c.$1 == 'Next Due On').$2.w),
                                          buildCell(InfoDirectoryDataCell(text: AppDateUtils.formatToOrdinalDate(sub.lastPayment), isExpanded: isExpanded, onTap: toggleRow), _kColumns.firstWhere((c) => c.$1 == 'Last Payment').$2.w),
                                          buildCell(InfoDirectoryDataCell(text: sub.paymentDetails ?? '', isExpanded: isExpanded, onTap: toggleRow), _kColumns.firstWhere((c) => c.$1 == 'Payment Details').$2.w),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                                },
                              ),
                            );
                          }),
                        ),
                        if (widget.controller.isLoading.value &&
                            widget.controller.subscriptions.isNotEmpty)
                          Positioned.fill(
                            child: ColoredBox(
                              color: Colors.white.withValues(alpha: 0.5),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Pagination Bottom Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.borderColor),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Showing ${(widget.controller.currentPage.value - 1) * widget.controller.perPage.value + 1} to '
                      '${(widget.controller.currentPage.value * widget.controller.perPage.value).clamp(0, widget.controller.totalRecords.value)} '
                      'of ${widget.controller.totalRecords.value} entries',
                      style: AppTextStyle.style_12_400(color: AppColors.grey600),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPageBtn(
                          '',
                          widget.controller.currentPage.value > 1
                              ? () => widget.controller
                                  .goToPage(widget.controller.currentPage.value - 1)
                              : null,
                          icon: Icons.chevron_left,
                        ),
                        SizedBox(width: 4.w),
                        _buildPageBtn(
                          widget.controller.currentPage.value.toString(),
                          null,
                          isActive: true,
                        ),
                        SizedBox(width: 4.w),
                        _buildPageBtn(
                          '',
                          widget.controller.currentPage.value <
                                  widget.controller.lastPage.value
                              ? () => widget.controller
                                  .goToPage(widget.controller.currentPage.value + 1)
                              : null,
                          icon: Icons.chevron_right,
                        ),
                      ],
                    ),
                  ],
                ),
          ),
        ],
      );
    });
  }

  void _showDeleteDialog(BuildContext context, int id) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 28,
            ),
            SizedBox(width: 8.w),
            Text(
              'Delete Subscription',
              style: AppTextStyle.style_16_700(
                color: AppColors.black,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this subscription? This action cannot be undone.',
          style: AppTextStyle.style_14_400(
            color: AppColors.grey900,
          ),
        ),
        actionsPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyle.style_14_600(
                color: AppColors.black,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.controller.deleteSubscription(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'Delete',
              style: AppTextStyle.style_14_600(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageBtn(String text, VoidCallback? onTap, {bool isActive = false, IconData? icon}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF16A3B8)
              : (onTap == null ? Colors.grey.shade200 : Colors.white),
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: icon != null
            ? Icon(
                icon,
                size: 16.sp,
                color: onTap == null ? Colors.grey.shade500 : AppColors.black,
              )
            : Text(
                text,
                style: AppTextStyle.style_12_400(
                  color: isActive
                      ? Colors.white
                      : (onTap == null ? Colors.grey.shade500 : AppColors.black),
                ),
              ),
      ),
    );
  }
}

class _PasswordCell extends StatelessWidget {
  final String? text;
  final bool isExpanded;
  final bool isVisible;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const _PasswordCell({
    super.key,
    required this.text,
    required this.isExpanded,
    required this.isVisible,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String safeText = text ?? '';
    if (safeText.isEmpty || safeText == '-') {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          child: Text(
            safeText.isEmpty ? '-' : safeText,
            style: AppTextStyle.style_12_400(color: AppColors.grey900),
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Text(
                isVisible ? safeText : '********',
                style: AppTextStyle.style_12_400(color: AppColors.grey900),
                maxLines: isExpanded ? null : 1,
                overflow: isExpanded ? null : TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 4.h),
              child: Icon(isVisible ? Icons.visibility_off : Icons.visibility, size: 16.sp, color: Colors.grey.shade600),
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: safeText));
              AppCommonToastMessage.show(message: 'Password copied', type: ToastType.success);
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 4.h),
              child: Icon(Icons.copy, size: 16.sp, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}

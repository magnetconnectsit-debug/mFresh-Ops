import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_webview.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/info_directory_controller.dart';
import 'package:mfresh_ops/data/models/info_directory/contact_model.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';

class InfoDirectoryHeaderCell extends StatelessWidget {
  final String text;

  const InfoDirectoryHeaderCell({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Text(
        text,
        style: AppTextStyle.style_11_600(color: AppColors.grey900),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class InfoDirectoryMobileCell extends StatelessWidget {
  final String text;
  final bool isExpanded;
  final VoidCallback onTap;

  const InfoDirectoryMobileCell({
    super.key,
    required this.text,
    required this.isExpanded,
    required this.onTap,
  });

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty || text == '-') {
      return InfoDirectoryDataCell(
        text: text,
        isExpanded: isExpanded,
        onTap: onTap,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: AppTextStyle.style_12_400(color: AppColors.grey900),
              maxLines: isExpanded ? null : 1,
              overflow: isExpanded ? null : TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: () => _makePhoneCall(text),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 4.h),
              child: Icon(Icons.call, size: 16.sp, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoDirectoryDataCell extends StatelessWidget {
  final String text;
  final bool isExpanded;
  final VoidCallback onTap;

  const InfoDirectoryDataCell({
    super.key,
    required this.text,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        child: Text(
          text,
          style: AppTextStyle.style_12_400(color: AppColors.grey900),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class InfoDirectoryWeblinkCell extends StatelessWidget {
  final String text;
  final bool isExpanded;
  final VoidCallback onTap;

  const InfoDirectoryWeblinkCell({
    super.key,
    required this.text,
    required this.isExpanded,
    required this.onTap,
  });

  Future<void> _openWeblink(String url) async {
    if (url.isEmpty || url == '-') return;
    String finalUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      finalUrl = 'https://$url';
    }
    Get.to(() => AppCommonWebView(url: finalUrl, title: 'Weblink'));
  }

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty || text == '-') {
      return InfoDirectoryDataCell(
        text: text,
        isExpanded: isExpanded,
        onTap: onTap,
      );
    }

    return GestureDetector(
      onTap: () => _openWeblink(text),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        child: Text(
          text,
          style: AppTextStyle.style_12_400(color: AppColors.grey900),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

const List<(String, double)> _kColumns = [
  ('Action', 65),
  ('Name', 135),
  ('Contact Type', 95),
  ('Brand', 120),
  ('Company', 130),
  ('Mobile 1', 115),
  ('Mobile 2', 115),
  ('Services', 190),
  ('Description', 200),
  ('Worked On', 140),
  ('Location', 130),
  ('Department', 130),
  ('Designation', 130),
  ('Email', 170),
  ('Weblinks', 130),
  ('Gstin', 125),
  ('Address', 150),
];

class InfoDirectoryTable extends StatefulWidget {
  final InfoDirectoryController controller;

  const InfoDirectoryTable({super.key, required this.controller});

  @override
  State<InfoDirectoryTable> createState() => _InfoDirectoryTableState();
}

class _InfoDirectoryTableState extends State<InfoDirectoryTable> {
  final RxSet<String> _expandedRows = <String>{}.obs;
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

  void _toggleRow(String id) {
    if (_expandedRows.contains(id)) {
      _expandedRows.remove(id);
    } else {
      _expandedRows.add(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final authRepo = Get.find<AuthRepository>();
      final userPermissions = authRepo.rxUserPermissions;
      final canEdit = userPermissions.contains('contact_edit');
      final canDelete = userPermissions.contains('contact_delete');
      final showAction = canEdit || canDelete;

      final activeColumns = showAction 
          ? _kColumns 
          : _kColumns.where((col) => col.$1 != 'Action').toList();

      final columnWidths = <int, TableColumnWidth>{
        for (int i = 0; i < activeColumns.length; i++) i: FixedColumnWidth(activeColumns[i].$2.w),
      };

      final double totalTableWidth = activeColumns.fold(0.0, (sum, col) => sum + col.$2.w);

      final isLoadingInitial =
          widget.controller.isLoading.value &&
          widget.controller.contacts.isEmpty;
      final showEmpty = !isLoadingInitial && widget.controller.contacts.isEmpty;

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
                    'No contacts found.',
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
                                widget.controller.contacts.isEmpty;

                            final listCount = isLoadingInitial
                                ? 20
                                : widget.controller.contacts.length;

                            return Skeletonizer(
                              enabled: isLoadingInitial,
                              child: ListView.builder(
                                controller: _verticalController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: listCount,
                                itemBuilder: (context, index) {
                                  final contact = isLoadingInitial
                                      ? ContactModel(
                                          id: index.toString(),
                                          name: 'Loading Name...',
                                          contactType: 'Loading...',
                                          brand: 'Loading...',
                                          company: 'Loading...',
                                        )
                                      : widget.controller.contacts[index];

                                  return Obx(() {
                                    final isExpanded = _expandedRows.contains(
                                      contact.id,
                                    );
                                    void toggleRow() => _toggleRow(contact.id);

                                    Widget buildCell(
                                      Widget child,
                                      double width,
                                    ) {
                                      return Container(
                                        width: width,
                                        alignment: Alignment.centerLeft,
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
                                      height: isExpanded ? null : 25.h,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
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
                                                        final result =
                                                            await Get.toNamed(
                                                              AppRoutes
                                                                  .createContact,
                                                              arguments: contact,
                                                            );
                                                        if (result == true) {
                                                          widget.controller
                                                              .fetchContacts(
                                                                showFullScreenLoader:
                                                                    false,
                                                              );
                                                        }
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: Colors.grey,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                4,
                                                              ),
                                                        ),
                                                        child: const Icon(
                                                          Icons.edit,
                                                          size: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  if (canEdit && canDelete) SizedBox(width: 4.w),
                                                  if (canDelete)
                                                    InkWell(
                                                      onTap: () {
                                                        Get.dialog(
                                                          AlertDialog(
                                                            backgroundColor:
                                                                Colors.white,
                                                            surfaceTintColor:
                                                                Colors
                                                                    .transparent,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12.r,
                                                                  ),
                                                            ),
                                                            title: Row(
                                                              children: [
                                                                const Icon(
                                                                  Icons
                                                                      .warning_amber_rounded,
                                                                  color:
                                                                      Colors.red,
                                                                  size: 28,
                                                                ),
                                                                SizedBox(
                                                                  width: 8.w,
                                                                ),
                                                                Text(
                                                                  'Delete Contact',
                                                                  style: AppTextStyle.style_16_700(
                                                                    color:
                                                                        AppColors
                                                                            .black,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            content: Text(
                                                              'Are you sure you want to delete this contact? This action cannot be undone.',
                                                              style:
                                                                  AppTextStyle.style_14_400(
                                                                    color: AppColors
                                                                        .grey900,
                                                                  ),
                                                            ),
                                                            actionsPadding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      16.w,
                                                                  vertical: 12.h,
                                                                ),
                                                            actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Get.back(),
                                                              child: Text(
                                                                'Cancel',
                                                                style: AppTextStyle.style_14_600(
                                                                  color:
                                                                      AppColors
                                                                          .black,
                                                                ),
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Get.back();
                                                                widget
                                                                    .controller
                                                                    .deleteContact(
                                                                      contact
                                                                          .id,
                                                                    );
                                                              },
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors.red,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        6.r,
                                                                      ),
                                                                ),
                                                                elevation: 0,
                                                              ),
                                                              child: Text(
                                                                'Delete',
                                                                style: AppTextStyle.style_14_600(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Colors.grey,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.delete,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                ),
                                              ),
                                            ),
                                            _kColumns[0].$2.w,
                                          ),
                                          buildCell(
                                            InfoDirectoryDataCell(
                                              text: contact.name,
                                              isExpanded: isExpanded,
                                              onTap: toggleRow,
                                            ),
                                            _kColumns[1].$2.w,
                                          ),
                                          buildCell(
                                            InfoDirectoryDataCell(
                                              text: contact.contactType,
                                              isExpanded: isExpanded,
                                              onTap: toggleRow,
                                            ),
                                            _kColumns[2].$2.w,
                                          ),
                                          buildCell(
                                            InfoDirectoryDataCell(
                                              text: contact.brand,
                                              isExpanded: isExpanded,
                                              onTap: toggleRow,
                                            ),
                                            _kColumns[3].$2.w,
                                          ),
                                          buildCell(
                                            InfoDirectoryDataCell(
                                              text: contact.company,
                                              isExpanded: isExpanded,
                                              onTap: toggleRow,
                                            ),
                                            _kColumns[4].$2.w,
                                          ),
                                          buildCell(
                                            InfoDirectoryMobileCell(
                                              text: contact.mobile1,
                                              isExpanded: isExpanded,
                                              onTap: toggleRow,
                                            ),
                                            _kColumns[5].$2.w,
                                          ),
                                          buildCell(
                                            InfoDirectoryMobileCell(
                                              text: contact.mobile2,
                                              isExpanded: isExpanded,
                                              onTap: toggleRow,
                                            ),
                                            _kColumns[6].$2.w,
                                          ),
                                          buildCell(
                                            InfoDirectoryDataCell(
                                              text: contact.services,
                                              isExpanded: isExpanded,
                                              onTap: toggleRow,
                                            ),
                                            _kColumns[7].$2.w,
                                          ),
                                          buildCell(
                                            InfoDirectoryDataCell(
                                              text: contact.description,
                                              isExpanded: isExpanded,
                                              onTap: toggleRow,
                                            ),
                                            _kColumns[8].$2.w,
                                          ),
                                          buildCell(
                                            InfoDirectoryDataCell(
                                              text: contact.workedOn,
                                              isExpanded: isExpanded,
                                              onTap: toggleRow,
                                            ),
                                            _kColumns[9].$2.w,
                                          ),
                                          buildCell(
                                            InfoDirectoryDataCell(
                                              text: contact.location,
                                              isExpanded: isExpanded,
                                              onTap: toggleRow,
                                            ),
                                            _kColumns[10].$2.w,
                                          ),
                                          buildCell(
                                            InfoDirectoryDataCell(
                                              text: contact.department,
                                              isExpanded: isExpanded,
                                              onTap: toggleRow,
                                            ),
                                            _kColumns[11].$2.w,
                                          ),
                                          buildCell(
                                            InfoDirectoryDataCell(
                                              text: contact.designation,
                                              isExpanded: isExpanded,
                                              onTap: toggleRow,
                                            ),
                                            _kColumns[12].$2.w,
                                          ),
                                          buildCell(
                                            InfoDirectoryDataCell(
                                              text: contact.email,
                                              isExpanded: isExpanded,
                                              onTap: toggleRow,
                                            ),
                                            _kColumns[13].$2.w,
                                          ),
                                          buildCell(
                                            InfoDirectoryWeblinkCell(
                                              text: contact.weblinks,
                                              isExpanded: isExpanded,
                                              onTap: toggleRow,
                                            ),
                                            _kColumns[14].$2.w,
                                          ),
                                          buildCell(
                                            InfoDirectoryDataCell(
                                              text: contact.gstin,
                                              isExpanded: isExpanded,
                                              onTap: toggleRow,
                                            ),
                                            _kColumns[15].$2.w,
                                          ),
                                          buildCell(
                                            InfoDirectoryDataCell(
                                              text: contact.address,
                                              isExpanded: isExpanded,
                                              onTap: toggleRow,
                                            ),
                                            _kColumns[16].$2.w,
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                                },
                              ),
                            );
                          }),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            ),
          ),
          Scrollbar(
            controller: _bottomBarController,
            thumbVisibility: true,
            interactive: true,
            thickness: 8.0,
            radius: const Radius.circular(4),
            child: SingleChildScrollView(
              controller: _bottomBarController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(width: totalTableWidth, height: 16),
            ),
          ),
        ],
      );
    });
  }
}

class InfoDirectoryPaginationButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const InfoDirectoryPaginationButton({
    super.key,
    required this.text,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        margin: EdgeInsets.only(left: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade600 : const Color(0xFFF1F5F9),
          border: Border.all(
            color: isActive ? Colors.blue.shade600 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          text,
          style: AppTextStyle.style_12_500(
            color: isActive ? Colors.white : Colors.blue.shade600,
          ),
        ),
      ),
    );
  }
}

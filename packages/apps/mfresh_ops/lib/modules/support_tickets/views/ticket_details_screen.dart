// region Imports
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/ticket_details_controller.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'widgets/ticket_details_header.dart';
import 'widgets/ticket_details_info_card.dart';
import 'widgets/ticket_details_timeline.dart';
// endregion

// region TicketDetailsScreen
class TicketDetailsScreen extends GetView<TicketDetailsController> {
  // region Constructor
  const TicketDetailsScreen({super.key});
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        hasBackButton: true,
        topHeader: const CommonShortcutHeader(),
        title: Text(
          "Ticket Details",
          style: AppTextStyle.style_15_600(color: AppColors.primaryOrange),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final ticket = controller.ticketDetail.value;

          // Initial load when ticket details haven't been fetched yet
          if (ticket == null && controller.isLoading.value) {
            return const Center(child: CustomAppLoader());
          }

          if (ticket == null) {
            return Center(
              child: Text(
                "No Ticket Found",
                style: AppTextStyle.style_12_400(color: AppColors.grey400),
              ),
            );
          }

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () => controller.fetchTicketDetails(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TicketDetailsHeader(ticket: ticket, controller: controller),
                          const SizedBox(height: 12),
                          TicketDetailsInfoCard(ticket: ticket, controller: controller),
                          const SizedBox(height: 12),
                          TicketDetailsTimeline(ticket: ticket, controller: controller),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (controller.isLoading.value)
                Positioned.fill(
                  child: Container(
                    color: AppColors.black.withValues(alpha: 0.35),
                    child: const Center(
                      child: CustomAppLoader(),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
  // endregion
}
// endregion

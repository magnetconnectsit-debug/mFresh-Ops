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

class TicketDetailsScreen extends GetView<TicketDetailsController> {
  const TicketDetailsScreen({super.key});

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
          if (controller.isLoading.value) {
            return const Center(child: CustomAppLoader());
          }

          final ticket = controller.ticketDetail.value;
          if (ticket == null) {
            return Center(
              child: Text(
                "No Ticket Found",
                style: AppTextStyle.style_12_400(color: AppColors.grey400),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchTicketDetails(),
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
          );
        }),
      ),
    );
  }
}

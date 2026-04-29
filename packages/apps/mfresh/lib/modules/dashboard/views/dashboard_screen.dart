import 'package:core/widgets/app_common_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:mfresh/modules/home/views/home_screen.dart';
import 'package:mfresh/modules/profile/views/profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    final List<Widget> pages = [
      const HomeScreen(),
      const Center(child: Text('Booking')), // Placeholder for Booking
      const Center(child: Text('Services')), // Placeholder for Services
      const ProfileScreen(), // Profile
    ];

    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: pages,
          )),
      bottomNavigationBar: Obx(
        () => AppCommonBottomNavBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.onTabTapped,
          items: [
            AppBottomNavItem(
              icon: Icons.home,
              label: 'Home',
            ),
            AppBottomNavItem(
              icon: Icons.calendar_month,
              label: 'Booking',
            ),
            AppBottomNavItem(
              icon: Icons.design_services,
              label: 'Services',
            ),
            AppBottomNavItem(
              icon: Icons.person,
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

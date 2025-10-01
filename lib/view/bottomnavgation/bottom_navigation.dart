import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../controller/bottomnavigation/bottom_navigation_controller.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_images.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BottomNavigationController());
    // Use fixed sizes for better control
    const double bottomBarHeight = 70.0; // Fixed height
    const double iconSize = 24.0; // Standard icon size
    const double fontSize = 12.0; // Standard font size
    const double verticalPadding = 8.0; // Reduced padding
    const double spacing = 4.0; // Reduced spacing

    return Container(
      height: bottomBarHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            assetPath: AppImages.homeIcon,
            label: 'Home',
            controller: controller,
            iconSize: iconSize,
            fontSize: fontSize,
            verticalPadding: verticalPadding,
            horizontalPadding:
                verticalPadding, // Match vertical for consistency
            spacing: spacing,
          ),
          _buildNavItem(
            index: 1,
            assetPath: AppImages.crownIcon,
            label: 'Packages',
            controller: controller,
            iconSize: iconSize,
            fontSize: fontSize,
            verticalPadding: verticalPadding,
            horizontalPadding: verticalPadding,
            spacing: spacing,
          ),
          _buildNavItem(
            index: 2,
            assetPath: AppImages.leadsIcon,
            label: 'Leads',
            controller: controller,
            iconSize: iconSize,
            fontSize: fontSize,
            verticalPadding: verticalPadding,
            horizontalPadding: verticalPadding,
            spacing: spacing,
          ),
          _buildNavItem(
            index: 3,
            assetPath: AppImages.videoIcon,
            label: 'Videos',
            controller: controller,
            iconSize: iconSize,
            fontSize: fontSize,
            verticalPadding: verticalPadding,
            horizontalPadding: verticalPadding,
            spacing: spacing,
          ),
          _buildNavItem(
            index: 4,
            assetPath: AppImages.profileIcon,
            label: 'Profile',
            controller: controller,
            iconSize: iconSize,
            fontSize: fontSize,
            verticalPadding: verticalPadding,
            horizontalPadding: verticalPadding,
            spacing: spacing,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String assetPath,
    required String label,
    required BottomNavigationController controller,
    required double iconSize,
    required double fontSize,
    required double verticalPadding,
    required double horizontalPadding,
    required double spacing,
  }) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.selectedIndex.value == index;
        final iconColor = isSelected ? AppColors.primary : Colors.grey;
        final textColor = isSelected ? AppColors.primary : Colors.grey;
        final fontWeight = isSelected ? FontWeight.w600 : FontWeight.normal;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => controller.changeTab(index),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal: horizontalPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  assetPath,
                  width: iconSize,
                  height: iconSize,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  semanticsLabel: label,
                ),
                SizedBox(height: spacing),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

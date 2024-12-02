import 'package:enrollease/utils/bottom_nav_images.dart';

class BottomNavIcons {
  final String assetPath; // Path to the image asset
  final int notificationCount; // Add notification count

  const BottomNavIcons({
    required this.assetPath,
    this.notificationCount = 0, // Default to 0 notifications
  });
}

const bottomNavIcons = [
  BottomNavIcons(assetPath: LocalImageAssets.homeIcon),
  BottomNavIcons(assetPath: LocalImageAssets.enrollIcon),
  BottomNavIcons(assetPath: LocalImageAssets.feesIcon),
  BottomNavIcons(
    assetPath: LocalImageAssets.notificationIcon,
    notificationCount: 3, // Example notification count
  ),
  BottomNavIcons(assetPath: LocalImageAssets.profileIcon),
];

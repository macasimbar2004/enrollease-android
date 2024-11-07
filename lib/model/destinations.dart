import 'package:enrollease/utils/bottom_nav_images.dart';

class BottomNavIcons {
  final String assetPath; // Path to the image asset

  const BottomNavIcons({required this.assetPath});
}

const bottomNavIcons = [
  BottomNavIcons(assetPath: LocalImageAssets.homeIcon),
  BottomNavIcons(assetPath: LocalImageAssets.enrollIcon),
  BottomNavIcons(assetPath: LocalImageAssets.feesIcon),
  BottomNavIcons(assetPath: LocalImageAssets.notificationIcon),
  BottomNavIcons(assetPath: LocalImageAssets.profileIcon),
];

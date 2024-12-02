import 'package:enrollease/model/app_size.dart';
import 'package:flutter/material.dart';

class BottomNavWidget extends StatelessWidget {
  const BottomNavWidget({
    super.key,
    required this.assetPath,
    required this.index,
    required this.currentIndex,
    required this.onPressed,
    this.notificationCount = 0, // Add notification count
  });

  final String assetPath; // Image asset path
  final int index;
  final int currentIndex;
  final Function(int) onPressed;
  final int notificationCount; // Notification count

  @override
  Widget build(BuildContext context) {
    AppSizes().init(context);
    return InkWell(
      onTap: () => onPressed(index),
      child: Container(
        height: AppSizes.blockSizeHorizontal * 13,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (currentIndex == index)
              Container(
                width: AppSizes.blockSizeHorizontal * 10,
                height: AppSizes.blockSizeHorizontal * 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.7),
                      spreadRadius: 4,
                      blurRadius: 15,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            AnimatedOpacity(
              opacity: (currentIndex == index) ? 1 : 0.8,
              duration: const Duration(milliseconds: 300),
              child: Image.asset(
                assetPath,
                color: currentIndex == index ? Colors.black87 : Colors.black54,
                width: AppSizes.blockSizeHorizontal * 8,
                height: AppSizes.blockSizeHorizontal * 8,
              ),
            ),
            // Notification counter
            if (notificationCount > 0 &&
                index == 3) // Show only for notifications
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      notificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

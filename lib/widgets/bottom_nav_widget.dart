import 'package:enrollease/model/app_size.dart';
import 'package:flutter/material.dart';

class BottomNavWidget extends StatelessWidget {
  const BottomNavWidget({
    super.key,
    required this.assetPath,
    required this.index,
    required this.currentIndex,
    required this.onPressed,
  });

  final String assetPath; // Change icon to assetPath
  final int index;
  final int currentIndex;
  final Function(int) onPressed;

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
            // Shadow effect
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

            // Image asset with opacity animation
            AnimatedOpacity(
              opacity: (currentIndex == index) ? 1 : 0.8,
              duration: const Duration(milliseconds: 300),
              child: Image.asset(
                assetPath, // Load the image asset
                color: currentIndex == index
                    ? Colors.black87
                    : Colors.black54, // Tint for selected/unselected
                width: AppSizes.blockSizeHorizontal * 8,
                height: AppSizes.blockSizeHorizontal * 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

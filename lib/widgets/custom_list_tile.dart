import 'package:enrollease/utils/logos.dart';
import 'package:flutter/material.dart';

class ExpandableListTile extends StatelessWidget {
  final String imageUrl;
  final String title;
  final Color? bgCustomColor;

  const ExpandableListTile({super.key, required this.imageUrl, required this.title, this.bgCustomColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular image with fallback
          ClipOval(
            child: Container(
              color: Colors.white,
              child: Image.network(
                imageUrl,
                width: 50, // Set image size
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Display fallback asset on error
                  return Image.asset(
                    CustomLogos.adventistLogo,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  );
                },
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16), // Add spacing between image and title
          // Expanded title that adjusts its height dynamically
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: bgCustomColor ?? Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ScaleTap extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;
  final int milliseconds;
  const ScaleTap({required this.width, required this.height, required this.child, this.milliseconds = 100, super.key});

  @override
  State<ScaleTap> createState() => _AnimatedTapState();
}

class _AnimatedTapState extends State<ScaleTap> {
  bool isTapped = false;

  void toggleTap() => setState(() {
        isTapped = !isTapped;
      });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) async {
        toggleTap();
      },
      onTapUp: (details) {
        toggleTap();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: widget.milliseconds),
        width: isTapped ? widget.width + 10 : widget.width,
        height: isTapped ? widget.height + 10 : widget.height,
        child: widget.child,
      ),
    );
  }
}

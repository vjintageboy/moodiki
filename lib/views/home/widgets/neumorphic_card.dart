import 'package:flutter/material.dart';

/// Reusable neumorphic card widget with soft shadows
/// Follows Material Wellness App design system
class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double borderRadius;
  final bool isPressed;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderRadius = 16,
    this.isPressed = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? const Color(0xFFF8FAFC);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: isPressed
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(2, 2),
                    blurRadius: 8,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.9),
                    offset: const Offset(-5, -5),
                    blurRadius: 15,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    offset: const Offset(5, 5),
                    blurRadius: 15,
                  ),
                ],
        ),
        child: child,
      ),
    );
  }
}

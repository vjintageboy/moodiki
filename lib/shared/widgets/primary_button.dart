import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? height;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height ?? 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: (isLoading || onPressed == null)
                ? [
                    AppColors.osPrimary.withValues(alpha: 0.5),
                    AppColors.osPrimaryDim.withValues(alpha: 0.5),
                  ]
                : [AppColors.osPrimary, AppColors.osPrimaryDim],
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: (isLoading || onPressed == null)
              ? []
              : [
                  BoxShadow(
                    color: AppColors.osOnSurface.withValues(alpha: 0.06),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: (isLoading || onPressed == null) ? null : onPressed,
            borderRadius: BorderRadius.circular(999),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: AppColors.osOnPrimary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          text,
                          style: GoogleFonts.manrope(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.osOnPrimary,
                            letterSpacing: 0.3,
                          ),
                        ),
                        if (icon != null) ...[
                          const SizedBox(width: 8),
                          Icon(icon, size: 20, color: AppColors.osOnPrimary),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

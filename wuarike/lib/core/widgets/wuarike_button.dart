import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum WuarikeButtonVariant { primary, secondary, outline }

class WuarikeButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final WuarikeButtonVariant variant;
  final Widget? icon;
  final double? width;

  const WuarikeButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = WuarikeButtonVariant.primary,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = switch (variant) {
      WuarikeButtonVariant.primary => AppColors.primary,
      WuarikeButtonVariant.secondary => AppColors.secondary,
      WuarikeButtonVariant.outline => Colors.transparent,
    };

    final fgColor = variant == WuarikeButtonVariant.outline
        ? AppColors.primary
        : AppColors.white;

    final border = variant == WuarikeButtonVariant.outline
        ? const BorderSide(color: AppColors.primary, width: 1.5)
        : BorderSide.none;

    return SizedBox(
      width: width ?? double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          side: border,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: variant == WuarikeButtonVariant.outline ? 0 : 2,
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: fgColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(label, style: AppTextStyles.button.copyWith(color: fgColor)),
                ],
              ),
      ),
    );
  }
}

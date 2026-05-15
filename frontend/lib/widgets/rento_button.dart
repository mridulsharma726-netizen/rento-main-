import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum RentoButtonVariant { primary, secondary, danger, ghost }

class RentoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final RentoButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;
  final double? height;

  const RentoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = RentoButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              Text(label),
            ],
          );

    switch (variant) {
      case RentoButtonVariant.primary:
        return SizedBox(
          height: height ?? 52,
          width: fullWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            child: child,
          ),
        );

      case RentoButtonVariant.secondary:
        return SizedBox(
          height: height ?? 52,
          width: fullWidth ? double.infinity : null,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            child: child,
          ),
        );

      case RentoButtonVariant.danger:
        return SizedBox(
          height: height ?? 52,
          width: fullWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: child,
          ),
        );

      case RentoButtonVariant.ghost:
        return SizedBox(
          height: height ?? 52,
          width: fullWidth ? double.infinity : null,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            child: child,
          ),
        );
    }
  }
}

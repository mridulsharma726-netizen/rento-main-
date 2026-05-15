import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class RentoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? color;
  final bool hasBorder;

  const RentoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderRadius = 12,
    this.color,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: AppColors.accentSubtle,
        highlightColor: AppColors.accentSubtle,
        child: Container(
          padding: padding,
          decoration: hasBorder
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(color: AppColors.border),
                )
              : null,
          child: child,
        ),
      ),
    );
  }
}

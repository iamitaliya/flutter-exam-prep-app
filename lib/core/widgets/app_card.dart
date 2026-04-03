import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: borderColor ?? AppColors.border,
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
          child: child,
        ),
      ),
    );
  }
}

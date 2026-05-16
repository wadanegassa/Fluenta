import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';

enum FluentaButtonVariant { primary, outlined, text, danger }

class FluentaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final FluentaButtonVariant variant;
  final bool isLoading;
  final IconData? icon;

  const FluentaButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = FluentaButtonVariant.primary,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    switch (variant) {
      case FluentaButtonVariant.primary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          child: _buildContent(AppColors.textOnDark),
        );
      case FluentaButtonVariant.outlined:
        return OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            ),
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.labelLarge.copyWith(fontSize: 15),
          ),
          child: _buildContent(AppColors.primary),
        );
      case FluentaButtonVariant.text:
        return TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: TextButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.labelLarge.copyWith(fontSize: 15),
          ),
          child: _buildContent(AppColors.primary),
        );
      case FluentaButtonVariant.danger:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.textOnDark,
          ),
          child: _buildContent(AppColors.textOnDark),
        );
    }
  }

  Widget _buildContent(Color color) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(text),
      ],
    );
  }
}

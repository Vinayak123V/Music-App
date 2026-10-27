import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';

class SaffronButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final double? width;

  const SaffronButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    final style = ElevatedButton.styleFrom(
      backgroundColor: isOutlined ? Colors.transparent : AppColors.saffronPrimary,
      foregroundColor: isOutlined ? AppColors.saffronDark : Colors.white,
      elevation: isOutlined ? 0 : 1,
      side: isOutlined ? const BorderSide(color: AppColors.saffronPrimary, width: 1.5) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    );

    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: style,
        onPressed: isLoading ? null : onPressed,
        child: buttonChild,
      ),
    );
  }
}

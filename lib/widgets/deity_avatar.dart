import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../data/models/deity_model.dart';

class DeityAvatar extends StatelessWidget {
  final DeityModel deity;
  final double radius;
  final VoidCallback? onTap;
  final bool isSelected;

  const DeityAvatar({
    super.key,
    required this.deity,
    this.radius = 32,
    this.onTap,
    this.isSelected = false,
  });

  String _getDeitySymbol(String id) {
    switch (id.toLowerCase()) {
      case 'shiva':
        return '🔱';
      case 'krishna':
        return '🦚';
      case 'rama':
        return '🏹';
      case 'hanuman':
        return '🕉️';
      case 'ganesha':
        return '🐘';
      case 'durga':
        return '🦁';
      case 'lakshmi':
        return '🪷';
      case 'saraswati':
        return '🪕';
      default:
        return '🕉️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final symbol = _getDeitySymbol(deity.id);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius + 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.saffronPrimary : AppColors.creamCard,
              border: Border.all(
                color: isSelected ? AppColors.saffronPrimary : AppColors.goldAccent.withOpacity(0.6),
                width: isSelected ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.saffronPrimary.withOpacity(0.3)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                symbol,
                style: TextStyle(fontSize: radius * 0.9),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: radius * 2.4,
            child: Text(
              deity.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.saffronDark : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';

class DevotionalImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? fallback;
  final String symbol;

  const DevotionalImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallback,
    this.symbol = '🕉️',
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(12);

    Widget fallbackWidget = fallback ??
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.saffronContainer,
                AppColors.creamCard,
              ],
            ),
            borderRadius: effectiveRadius,
            border: Border.all(color: AppColors.goldAccent.withOpacity(0.3), width: 1),
          ),
          child: Center(
            child: Text(
              symbol,
              style: TextStyle(
                fontSize: (height != null ? height! * 0.42 : 28.0).clamp(16.0, 64.0).toDouble(),
              ),
            ),
          ),
        );

    if (imageUrl == null || imageUrl!.isEmpty) {
      return ClipRRect(
        borderRadius: effectiveRadius,
        child: fallbackWidget,
      );
    }

    // On Flutter Web, use Image.network to avoid CanvasKit XHR CORS / EncodingError issues
    if (kIsWeb) {
      return ClipRRect(
        borderRadius: effectiveRadius,
        child: Image.network(
          imageUrl!,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => fallbackWidget,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: width,
              height: height,
              color: AppColors.saffronContainer.withOpacity(0.2),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.saffronLight),
                ),
              ),
            );
          },
        ),
      );
    }

    // On Mobile (Android / iOS), use CachedNetworkImage for persistent disk caching
    return ClipRRect(
      borderRadius: effectiveRadius,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: AppColors.saffronContainer.withOpacity(0.2),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.saffronLight),
            ),
          ),
        ),
        errorWidget: (context, url, error) => fallbackWidget,
      ),
    );
  }
}

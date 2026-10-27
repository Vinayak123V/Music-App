import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import 'router/app_router.dart';
import 'theme/devotional_theme.dart';

class BhaktiMusicApp extends ConsumerWidget {
  const BhaktiMusicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: DevotionalTheme.lightTheme,
      routerConfig: router,
    );
  }
}

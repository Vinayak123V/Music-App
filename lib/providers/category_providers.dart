import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_config.dart';
import '../data/models/category_model.dart';
import '../data/models/deity_model.dart';
import '../data/repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  FirebaseFirestore? firestore;
  if (AppConfig.isFirebaseInitialized) {
    try {
      firestore = FirebaseFirestore.instance;
    } catch (_) {}
  }
  return FirestoreCategoryRepository(firestore: firestore);
});

final categoriesListProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getCategories(enabledOnly: true);
});

final allCategoriesForAdminProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getCategories(enabledOnly: false);
});

final deitiesListProvider = FutureProvider<List<DeityModel>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getDeities();
});

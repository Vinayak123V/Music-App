import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_constants.dart';
import '../models/category_model.dart';
import '../models/deity_model.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getCategories({bool enabledOnly = true});
  Future<List<DeityModel>> getDeities();
  Future<CategoryModel?> getCategoryById(String id);
  Future<DeityModel?> getDeityById(String id);
  Future<void> saveCategory(CategoryModel category);
  Future<void> toggleCategoryEnabled(String categoryId, bool enabled);
}

class FirestoreCategoryRepository implements CategoryRepository {
  final FirebaseFirestore? _firestore;

  FirestoreCategoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>>? get _categoriesCollection =>
      _firestore?.collection('categories');

  CollectionReference<Map<String, dynamic>>? get _deitiesCollection =>
      _firestore?.collection('deities');

  static final List<CategoryModel> _defaultCategories =
      AppConstants.defaultCategories.map((m) => CategoryModel.fromMap(m)).toList();

  static final List<DeityModel> _defaultDeities =
      AppConstants.defaultDeities.map((m) => DeityModel.fromMap(m)).toList();

  @override
  Future<List<CategoryModel>> getCategories({bool enabledOnly = true}) async {
    if (AppConfig.isFirebaseInitialized && _categoriesCollection != null) {
      try {
        Query<Map<String, dynamic>> q = _categoriesCollection!.orderBy('sortOrder');
        if (enabledOnly) {
          q = q.where('enabled', isEqualTo: true);
        }
        final snap = await q.get();
        if (snap.docs.isNotEmpty) {
          return snap.docs
              .map((d) => CategoryModel.fromMap(d.data(), d.id))
              .toList();
        }
      } catch (_) {}
    }
    if (enabledOnly) {
      return _defaultCategories.where((c) => c.enabled).toList();
    }
    return List.from(_defaultCategories);
  }

  @override
  Future<List<DeityModel>> getDeities() async {
    if (AppConfig.isFirebaseInitialized && _deitiesCollection != null) {
      try {
        final snap = await _deitiesCollection!.orderBy('sortOrder').get();
        if (snap.docs.isNotEmpty) {
          return snap.docs
              .map((d) => DeityModel.fromMap(d.data(), d.id))
              .toList();
        }
      } catch (_) {}
    }
    return List.from(_defaultDeities);
  }

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    final list = await getCategories(enabledOnly: false);
    try {
      return list.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<DeityModel?> getDeityById(String id) async {
    final list = await getDeities();
    try {
      return list.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveCategory(CategoryModel category) async {
    if (AppConfig.isFirebaseInitialized && _categoriesCollection != null) {
      await _categoriesCollection!.doc(category.id).set(category.toMap());
    }
    final index = _defaultCategories.indexWhere((c) => c.id == category.id);
    if (index >= 0) {
      _defaultCategories[index] = category;
    } else {
      _defaultCategories.add(category);
    }
  }

  @override
  Future<void> toggleCategoryEnabled(String categoryId, bool enabled) async {
    if (AppConfig.isFirebaseInitialized && _categoriesCollection != null) {
      await _categoriesCollection!.doc(categoryId).update({'enabled': enabled});
    }
    final index = _defaultCategories.indexWhere((c) => c.id == categoryId);
    if (index >= 0) {
      _defaultCategories[index] = _defaultCategories[index].copyWith(enabled: enabled);
    }
  }
}

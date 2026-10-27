import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../data/models/category_model.dart';
import '../../providers/category_providers.dart';
import '../../widgets/saffron_button.dart';

class AdminCategoriesTab extends ConsumerWidget {
  const AdminCategoriesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoriesForAdminProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category Management',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Enable, disable, or add devotional genre categories.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                SaffronButton(
                  label: 'Add Category',
                  icon: Icons.add_rounded,
                  onPressed: () => _showAddEditCategoryDialog(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: categoriesAsync.when(
                data: (categories) {
                  return Card(
                    child: ListView.separated(
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.saffronContainer,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(cat.description ?? cat.slug),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: cat.enabled,
                                activeColor: AppColors.successGreen,
                                onChanged: (value) async {
                                  await ref.read(categoryRepositoryProvider).toggleCategoryEnabled(cat.id, value);
                                  ref.invalidate(allCategoriesForAdminProvider);
                                  ref.invalidate(categoriesListProvider);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _showAddEditCategoryDialog(context, ref, category: cat),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffronPrimary)),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditCategoryDialog(BuildContext context, WidgetRef ref, {CategoryModel? category}) {
    final nameCtrl = TextEditingController(text: category?.name ?? '');
    final slugCtrl = TextEditingController(text: category?.slug ?? '');
    final descCtrl = TextEditingController(text: category?.description ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(category != null ? 'Edit Category' : 'Create Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Category Name (e.g. Stotrams)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: slugCtrl,
              decoration: const InputDecoration(labelText: 'Slug identifier (e.g. stotrams)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newCat = CategoryModel(
                id: category?.id ?? slugCtrl.text.trim().toLowerCase(),
                name: nameCtrl.text.trim(),
                slug: slugCtrl.text.trim().toLowerCase(),
                type: 'devotional',
                description: descCtrl.text.trim(),
                sortOrder: category?.sortOrder ?? 10,
                enabled: category?.enabled ?? true,
              );
              await ref.read(categoryRepositoryProvider).saveCategory(newCat);
              ref.invalidate(allCategoriesForAdminProvider);
              ref.invalidate(categoriesListProvider);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

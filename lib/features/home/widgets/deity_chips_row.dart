import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/deity_model.dart';
import '../../../providers/category_providers.dart';
import '../../../widgets/deity_avatar.dart';

class DeityChipsRow extends ConsumerWidget {
  final String? selectedDeityId;
  final ValueChanged<String?> onSelectDeity;

  const DeityChipsRow({
    super.key,
    required this.selectedDeityId,
    required this.onSelectDeity,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deitiesAsync = ref.watch(deitiesListProvider);

    return deitiesAsync.when(
      data: (deities) {
        return SizedBox(
          height: 94,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: deities.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final deity = deities[index];
              final isSelected = selectedDeityId == deity.id;
              return DeityAvatar(
                deity: deity,
                radius: 28,
                isSelected: isSelected,
                onTap: () {
                  if (isSelected) {
                    onSelectDeity(null);
                  } else {
                    onSelectDeity(deity.id);
                  }
                },
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(height: 94),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../transaction/presentation/ui/transaction_form.dart';
import '../../domain/entity/category.dart';
import '../viewmodel/category_viewmodel.dart';
import 'category_localization_helper.dart';

class CategoryGrid extends StatefulWidget {
  const CategoryGrid({super.key});

  @override
  State<CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<CategoryGrid> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<CategoryViewModel>().loadCategories());
  }

  /// Hiển thị icon
  Widget _buildIcon(String iconStr) {
    final codePoint = int.tryParse(iconStr);
    if (codePoint != null) {
      return Icon(
        IconData(codePoint, fontFamily: 'MaterialIcons'),
        size: 32,
        color: Colors.blue[700],
      );
    } else {
      return Text(iconStr, style: const TextStyle(fontSize: 32));
    }
  }

  /// Dialog thêm category
  void _showAddDialog(CategoryViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;

    String name = '';
    IconData? selectedIcon;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.category_add_title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: l10n.category_field_label),
                onChanged: (v) => name = v,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    selectedIcon == null ? l10n.category_not_chosen_icon : l10n.category_chosen_icon,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  if (selectedIcon != null)
                    Icon(selectedIcon, color: Colors.blue),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final icon = await showDialog<IconData>(
                        context: context,
                        builder: (_) => const IconPickerDialog(),
                      );
                      if (icon != null) setState(() => selectedIcon = icon);
                    },
                    child: Text(l10n.category_choose_icon),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.category_cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (name.isNotEmpty && selectedIcon != null) {
                  final newCategory = Category(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    icon: selectedIcon!.codePoint.toString(),
                  );
                  await viewModel.addCategory(newCategory);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog xác nhận xóa
  void _showDeleteDialog(Category category, CategoryViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.category_delete_title),
        content: Text(l10n.category_delete_message(category.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.category_cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await viewModel.deleteCategory(category.id);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.category_delete_confirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CategoryViewModel>();

    // Dịch
    final translatedCategories =
    translateDefaultCategories(context, viewModel.categories);

    // Thêm nút add ở cuối
    final displayCategories = [...translatedCategories, null];

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: displayCategories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final category = displayCategories[index];

        // Nút add
        if (category == null) {
          return GestureDetector(
            onTap: () => _showAddDialog(viewModel),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.add, size: 32),
            ),
          );
        }

        // Hiển thị category
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TransactionForm(category: category),
              ),
            );
          },
          onLongPress: () => _showDeleteDialog(category, viewModel),
          borderRadius: BorderRadius.circular(12),
          child: Material(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(category.icon),
                const SizedBox(height: 8),
                Text(category.name, textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      },
    );
  }
}

class IconPickerDialog extends StatefulWidget {
  const IconPickerDialog({super.key});

  @override
  State<IconPickerDialog> createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<IconPickerDialog> {
  final List<IconData> icons = [
    // Food & Drink
    Icons.fastfood,
    Icons.local_cafe,
    Icons.local_pizza,
    Icons.icecream,
    Icons.local_bar,

    // Entertainment
    Icons.movie,
    Icons.music_note,
    Icons.videogame_asset,
    Icons.tv,
    Icons.palette,

    // Travel
    Icons.flight,
    Icons.train,
    Icons.directions_car,
    Icons.hotel,
    Icons.map,

    // Daily
    Icons.home,
    Icons.shopping_cart,
    Icons.store,
    Icons.cleaning_services,
    Icons.lightbulb,

    // Work & Education
    Icons.work,
    Icons.school,
    Icons.computer,
    Icons.science,
    Icons.calculate,

    // Personal
    Icons.favorite,
    Icons.pets,
    Icons.health_and_safety,
    Icons.sports_soccer,
    Icons.fitness_center,
  ];

  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.category_choose_icon),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: icons.length,
          itemBuilder: (context, index) {
            final icon = icons[index];
            final isSelected = selectedIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() => selectedIndex = index);
                Future.delayed(const Duration(milliseconds: 150), () {
                  Navigator.pop(context, icon);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[300] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: Colors.blue, width: 2)
                      : null,
                ),
                child: Center(
                  child: AnimatedScale(
                    scale: isSelected ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      icon,
                      size: 28,
                      color: isSelected ? Colors.white : Colors.blue[800],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
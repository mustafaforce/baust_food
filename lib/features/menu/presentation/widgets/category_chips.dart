import 'package:flutter/material.dart';
import '../../data/models/models.dart';

class CategoryChips extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;

  const CategoryChips({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: selectedCategoryId == null,
              onSelected: (_) => onCategorySelected(null),
            ),
          ),
          ...categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category.name),
                selected: selectedCategoryId == category.id,
                onSelected: (_) => onCategorySelected(category.id),
              ),
            );
          }),
        ],
      ),
    );
  }
}
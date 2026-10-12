import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/category_model.dart';
import '../../../providers/category_provider.dart';
import 'add_category_dialog.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddCategoryDialog(bool isExpense) {
    showDialog(
      context: context,
      builder: (_) => AddCategoryDialog(isExpense: isExpense),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.textMutedDark,
          tabs: const [
            Tab(text: 'Expense Categories'),
            Tab(text: 'Income Categories'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'category_management_fab',
        onPressed: () {
          _openAddCategoryDialog(_tabController.index == 0);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Category'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList(
            categories: categoryProvider.expenseCategories,
            isExpense: true,
          ),
          _buildCategoryList(
            categories: categoryProvider.incomeCategories,
            isExpense: false,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList({
    required List<CategoryModel> categories,
    required bool isExpense,
  }) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.category_outlined, size: 54, color: AppColors.textMutedDark),
            const SizedBox(height: 12),
            const Text(
              'No categories available',
              style: TextStyle(color: AppColors.textPrimaryDark, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _openAddCategoryDialog(isExpense),
              child: const Text('Add First Category'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cat.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cat.color.withValues(alpha: 0.5)),
              ),
              child: Icon(cat.icon, color: cat.color, size: 22),
            ),
            title: Text(
              cat.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryDark,
              ),
            ),
            subtitle: Text(
              cat.isDefault ? 'Default Category' : 'Custom Category',
              style: TextStyle(
                fontSize: 12,
                color: cat.isDefault ? AppColors.textMutedDark : AppColors.secondary,
              ),
            ),
            trailing: cat.isDefault
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceCard,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Locked',
                      style: TextStyle(fontSize: 11, color: AppColors.textMutedDark),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.expense),
                    tooltip: 'Delete custom category',
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.darkSurface,
                          title: const Text('Delete Category?'),
                          content: Text(
                            'Are you sure you want to delete "${cat.name}"?',
                            style: const TextStyle(color: AppColors.textSecondaryDark),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondaryDark)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        if (!context.mounted) return;
                        context.read<CategoryProvider>().deleteCategory(cat.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Category "${cat.name}" deleted')),
                        );
                      }
                    },
                  ),
          ),
        );
      },
    );
  }
}

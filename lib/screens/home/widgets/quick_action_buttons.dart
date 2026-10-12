import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class QuickActionButtons extends StatelessWidget {
  final VoidCallback onAddExpense;
  final VoidCallback onAddIncome;
  final VoidCallback onOpenAnalytics;
  final VoidCallback onManageCategories;

  const QuickActionButtons({
    super.key,
    required this.onAddExpense,
    required this.onAddIncome,
    required this.onOpenAnalytics,
    required this.onManageCategories,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildActionItem(
          icon: Icons.remove_circle_outline_rounded,
          color: AppColors.expense,
          label: 'Expense',
          onTap: onAddExpense,
        ),
        const SizedBox(width: 10),
        _buildActionItem(
          icon: Icons.add_circle_outline_rounded,
          color: AppColors.income,
          label: 'Income',
          onTap: onAddIncome,
        ),
        const SizedBox(width: 10),
        _buildActionItem(
          icon: Icons.pie_chart_outline_rounded,
          color: AppColors.secondary,
          label: 'Analytics',
          onTap: onOpenAnalytics,
        ),
        const SizedBox(width: 10),
        _buildActionItem(
          icon: Icons.category_outlined,
          color: AppColors.accent,
          label: 'Categories',
          onTap: onManageCategories,
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkBorder, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

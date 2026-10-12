import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class BudgetProgressCard extends StatelessWidget {
  final double monthlyLimit;
  final double currentSpent;
  final VoidCallback onEditBudget;

  const BudgetProgressCard({
    super.key,
    required this.monthlyLimit,
    required this.currentSpent,
    required this.onEditBudget,
  });

  @override
  Widget build(BuildContext context) {
    final double percent = monthlyLimit > 0
        ? (currentSpent / monthlyLimit).clamp(0.0, 1.0)
        : 0.0;
    final double remaining = monthlyLimit - currentSpent;
    final bool isOver = currentSpent > monthlyLimit;
    final bool isWarning = percent >= 0.8 && !isOver;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (monthlyLimit <= 0) {
      statusColor = AppColors.secondary;
      statusText = 'No Limit Set';
      statusIcon = Icons.info_outline_rounded;
    } else if (isOver) {
      statusColor = AppColors.expense;
      statusText = 'Budget Exceeded!';
      statusIcon = Icons.warning_amber_rounded;
    } else if (isWarning) {
      statusColor = AppColors.warning;
      statusText = '80% Spent';
      statusIcon = Icons.info_outline_rounded;
    } else {
      statusColor = AppColors.income;
      statusText = 'On Track';
      statusIcon = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOver
              ? AppColors.expense.withValues(alpha: 0.5)
              : AppColors.darkBorder,
          width: isOver ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Monthly Budget',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onEditBudget,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined, size: 14, color: AppColors.primaryLight),
                      const SizedBox(width: 4),
                      Text(
                        'Set Limit',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                CurrencyFormatter.format(currentSpent),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              Text(
                monthlyLimit > 0
                    ? 'Limit: ${CurrencyFormatter.format(monthlyLimit)}'
                    : 'Limit: Not set',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: AppColors.darkSurfaceCard,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
              Text(
                monthlyLimit <= 0
                    ? 'Tap Set Limit to start'
                    : isOver
                        ? 'Exceeded by ${CurrencyFormatter.format(currentSpent - monthlyLimit)}'
                        : 'Remaining: ${CurrencyFormatter.format(remaining)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isOver && monthlyLimit > 0 ? AppColors.expense : AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

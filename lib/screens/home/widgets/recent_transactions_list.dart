import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/transaction_model.dart';
import '../../transactions/widgets/transaction_item_tile.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final VoidCallback onSeeAll;
  final Function(TransactionModel) onEditTransaction;
  final Function(String) onDeleteTransaction;

  const RecentTransactionsList({
    super.key,
    required this.transactions,
    required this.onSeeAll,
    required this.onEditTransaction,
    required this.onDeleteTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryDark,
              ),
            ),
            if (transactions.isNotEmpty)
              TextButton(
                onPressed: onSeeAll,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('See All', style: TextStyle(color: AppColors.primaryLight, fontSize: 13)),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primaryLight),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (transactions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: AppColors.textMutedDark.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 12),
                const Text(
                  'No transactions recorded yet',
                  style: TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap the + button to record your first expense or income',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMutedDark, fontSize: 13),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length > 5 ? 5 : transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return TransactionItemTile(
                transaction: tx,
                onTap: () => onEditTransaction(tx),
                onDelete: () => onDeleteTransaction(tx.id),
              );
            },
          ),
      ],
    );
  }
}

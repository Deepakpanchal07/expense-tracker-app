import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/transaction_model.dart';
import '../../../providers/expense_provider.dart';
import '../add_edit_expense/add_edit_expense_screen.dart';
import 'widgets/transaction_filter_sheet.dart';
import 'widgets/transaction_item_tile.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TransactionFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final transactions = expenseProvider.filteredTransactions;
    final hasActiveFilter = expenseProvider.categoryFilter != null ||
        expenseProvider.dateRangeFilter != null ||
        expenseProvider.sortBy != 'date_desc';

    // Calculate total of currently filtered transactions
    final double filteredTotal = transactions.fold(
      0.0,
      (sum, item) => item.isExpense ? sum - item.amount : sum + item.amount,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense History'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Filter & Sort',
                onPressed: _openFilterSheet,
              ),
              if (hasActiveFilter)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => expenseProvider.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search by title, note, method...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMutedDark),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              expenseProvider.setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                // Type Filter Chips (All / Expenses / Income)
                Row(
                  children: [
                    _buildTypeChip(
                      label: 'All',
                      isSelected: expenseProvider.typeFilter == null,
                      onTap: () => expenseProvider.setTypeFilter(null),
                    ),
                    const SizedBox(width: 8),
                    _buildTypeChip(
                      label: 'Expenses',
                      isSelected: expenseProvider.typeFilter == TransactionType.expense,
                      onTap: () => expenseProvider.setTypeFilter(TransactionType.expense),
                      activeColor: AppColors.expense,
                    ),
                    const SizedBox(width: 8),
                    _buildTypeChip(
                      label: 'Income',
                      isSelected: expenseProvider.typeFilter == TransactionType.income,
                      onTap: () => expenseProvider.setTypeFilter(TransactionType.income),
                      activeColor: AppColors.income,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Summary Subheader
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${transactions.length} ${transactions.length == 1 ? 'Record' : 'Records'}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMutedDark,
                  ),
                ),
                Text(
                  'Net: ${filteredTotal >= 0 ? '+' : ''}${CurrencyFormatter.format(filteredTotal)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: filteredTotal >= 0 ? AppColors.income : AppColors.expense,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.darkBorder),

          // Transactions List
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 56,
                            color: AppColors.textMutedDark.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No transactions found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Try clearing your search query or adjusting your filters',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textMutedDark, fontSize: 13),
                          ),
                          if (hasActiveFilter || _searchController.text.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: () {
                                _searchController.clear();
                                expenseProvider.resetFilters();
                              },
                              child: const Text('Reset All Filters'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return TransactionItemTile(
                        transaction: tx,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditExpenseScreen(transactionToEdit: tx),
                            ),
                          );
                        },
                        onDelete: () {
                          expenseProvider.deleteTransaction(tx.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Transaction deleted'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color activeColor = AppColors.primary,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.2)
                : AppColors.darkSurfaceCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? activeColor : AppColors.darkBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? activeColor : AppColors.textSecondaryDark,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/transaction_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/expense_provider.dart';
import '../add_edit_expense/add_edit_expense_screen.dart';
import '../auth/login_screen.dart';
import 'widgets/balance_card.dart';
import 'widgets/budget_progress_card.dart';
import 'widgets/quick_action_buttons.dart';
import 'widgets/recent_transactions_list.dart';
import 'widgets/set_budget_dialog.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const HomeScreen({
    super.key,
    required this.onNavigateToTab,
  });

  void _showProfileSheet(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.darkBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    auth.currentUser?.name.isNotEmpty == true
                        ? auth.currentUser!.name[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  auth.currentUser?.name ?? 'User',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
                ),
                const SizedBox(height: 4),
                Text(
                  auth.currentUser?.email ?? '',
                  style: const TextStyle(fontSize: 13, color: AppColors.textMutedDark),
                ),
                const SizedBox(height: 18),
                ListTile(
                  leading: const Icon(Icons.storage_rounded, color: AppColors.income),
                  title: const Text('Database', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('MongoDB via Node.js (Active)', style: TextStyle(fontSize: 12, color: AppColors.textMutedDark)),
                  tileColor: AppColors.darkSurfaceCard,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await auth.logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (r) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign Out'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final authProvider = context.watch<AuthProvider>();

    final userName = authProvider.currentUser?.name ?? '';
    final greeting = userName.isNotEmpty ? 'Hello, ${userName.split(' ').first} 👋' : DateFormatter.formatMonthYear(DateTime.now()).toUpperCase();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await expenseProvider.loadTransactions();
            await budgetProvider.loadMonthlyBudget();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: AppColors.primaryLight,
                          ),
                        ),
                        Row(
                          children: [
                            const Text(
                              'Expense Tracker',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.income.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.income.withValues(alpha: 0.4)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.storage_rounded, size: 10, color: AppColors.income),
                                  SizedBox(width: 3),
                                  Text(
                                    'MongoDB',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.income,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.darkSurfaceCard,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.darkBorder),
                            ),
                            child: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.textSecondaryDark),
                          ),
                          onPressed: () {
                            expenseProvider.loadTransactions();
                            budgetProvider.loadMonthlyBudget();
                          },
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.5)),
                            ),
                            child: const Icon(Icons.person_rounded, size: 18, color: AppColors.primaryLight),
                          ),
                          onPressed: () => _showProfileSheet(context, authProvider),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Main Balance Overview Card
                BalanceCard(
                  balance: expenseProvider.totalBalance,
                  totalIncome: expenseProvider.totalIncome,
                  totalExpense: expenseProvider.totalExpense,
                ),
                const SizedBox(height: 18),

                // Budget Progress Card
                BudgetProgressCard(
                  monthlyLimit: budgetProvider.monthlyLimit,
                  currentSpent: expenseProvider.currentMonthExpense,
                  onEditBudget: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => SetBudgetDialog(
                        currentLimit: budgetProvider.monthlyLimit,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),

                // Quick Action Shortcuts
                QuickActionButtons(
                  onAddExpense: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddEditExpenseScreen(
                          initialType: TransactionType.expense,
                        ),
                      ),
                    );
                  },
                  onAddIncome: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddEditExpenseScreen(
                          initialType: TransactionType.income,
                        ),
                      ),
                    );
                  },
                  onOpenAnalytics: () => onNavigateToTab(2), // Tab 2: Analytics
                  onManageCategories: () => onNavigateToTab(3), // Tab 3: Categories
                ),
                const SizedBox(height: 24),

                // Recent Transactions List
                RecentTransactionsList(
                  transactions: expenseProvider.allTransactions,
                  onSeeAll: () => onNavigateToTab(1), // Tab 1: History
                  onEditTransaction: (tx) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditExpenseScreen(transactionToEdit: tx),
                      ),
                    );
                  },
                  onDeleteTransaction: (id) {
                    expenseProvider.deleteTransaction(id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transaction deleted successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

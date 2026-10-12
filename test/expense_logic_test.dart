import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/category_model.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/providers/expense_provider.dart';

void main() {
  group('Expense Tracker Core Models & Data Handling', () {
    test('CategoryModel correctly serializes to and from Map', () {
      final category = CategoryModel(
        id: 'cat_test_1',
        name: 'Dining Out',
        iconCode: Icons.restaurant.codePoint,
        colorValue: Colors.redAccent.toARGB32(),
        isExpense: true,
        isDefault: false,
      );

      final map = category.toMap();
      expect(map['id'], 'cat_test_1');
      expect(map['name'], 'Dining Out');
      expect(map['is_expense'], 1);
      expect(map['is_default'], 0);

      final revived = CategoryModel.fromMap(map);
      expect(revived.id, category.id);
      expect(revived.name, category.name);
      expect(revived.iconCode, category.iconCode);
      expect(revived.isExpense, true);
    });

    test('TransactionModel handles Expense and Income types correctly', () {
      final txExpense = TransactionModel(
        id: 'tx_1',
        title: 'Lunch',
        amount: 250.0,
        date: DateTime(2026, 10, 10, 13, 0),
        categoryId: 'cat_food',
        categoryName: 'Food',
        categoryIconCode: Icons.lunch_dining.codePoint,
        categoryColorValue: Colors.orange.toARGB32(),
        type: TransactionType.expense,
        paymentMethod: 'UPI',
      );

      expect(txExpense.isExpense, true);
      expect(txExpense.isIncome, false);

      final map = txExpense.toMap();
      expect(map['type'], 'expense');
      expect(map['amount'], 250.0);

      final fromMap = TransactionModel.fromMap(map);
      expect(fromMap.title, 'Lunch');
      expect(fromMap.amount, 250.0);
      expect(fromMap.type, TransactionType.expense);
    });

    test('Financial calculations, search filtering, and state updates', () async {
      final provider = ExpenseProvider();
      await provider.loadTransactions();

      expect(provider.allTransactions.length, 0);
      expect(provider.totalIncome, 0.0);
      expect(provider.totalExpense, 0.0);

      final initialCount = 0;
      final initialIncome = 0.0;
      final initialExpense = 0.0;

      final testDate = DateTime(2026, 12, 1); // Future distinct month
      final t1 = TransactionModel(
        id: 'test_tx_income',
        title: 'Special Year-End Bonus',
        amount: 15000.0,
        date: testDate,
        categoryId: 'cat_bonus',
        categoryName: 'Bonus',
        categoryIconCode: Icons.card_giftcard.codePoint,
        categoryColorValue: Colors.purple.toARGB32(),
        type: TransactionType.income,
      );

      final t2 = TransactionModel(
        id: 'test_tx_expense',
        title: 'Holiday Electronics Purchase',
        amount: 5000.0,
        date: testDate,
        categoryId: 'cat_shopping',
        categoryName: 'Shopping',
        categoryIconCode: Icons.shopping_bag.codePoint,
        categoryColorValue: Colors.blue.toARGB32(),
        type: TransactionType.expense,
      );

      await provider.addTransaction(t1);
      await provider.addTransaction(t2);

      expect(provider.allTransactions.length, initialCount + 2);
      expect(provider.totalIncome, initialIncome + 15000.0);
      expect(provider.totalExpense, initialExpense + 5000.0);

      // Search functionality
      provider.setSearchQuery('Electronics');
      expect(provider.filteredTransactions.length, 1);
      expect(provider.filteredTransactions.first.title, 'Holiday Electronics Purchase');

      // Month specific category breakdown
      final breakdown = provider.getCategoryBreakdown(12, 2026);
      expect(breakdown.length, 1);
      expect(breakdown.first.categoryName, 'Shopping');
      expect(breakdown.first.amount, 5000.0);
      expect(breakdown.first.percentage, 100.0);

      // Clean up test transactions
      await provider.deleteTransaction('test_tx_income');
      await provider.deleteTransaction('test_tx_expense');
      expect(provider.allTransactions.length, initialCount);
    });
  });
}

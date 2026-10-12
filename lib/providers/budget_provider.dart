import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class BudgetProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  double _monthlyLimit = 0.0;
  bool _isLoading = false;

  double get monthlyLimit => _monthlyLimit;
  bool get isLoading => _isLoading;

  Future<void> loadMonthlyBudget({int? month, int? year}) async {
    final now = DateTime.now();
    final targetMonth = month ?? now.month;
    final targetYear = year ?? now.year;

    _isLoading = true;
    notifyListeners();

    try {
      _monthlyLimit = await _db.getMonthlyBudget(targetMonth, targetYear);
    } catch (e) {
      debugPrint('Error loading budget: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMonthlyBudget(double newLimit, {int? month, int? year}) async {
    final now = DateTime.now();
    final targetMonth = month ?? now.month;
    final targetYear = year ?? now.year;

    _monthlyLimit = newLimit;
    notifyListeners();

    try {
      await _db.setMonthlyBudget(targetMonth, targetYear, newLimit);
    } catch (e) {
      debugPrint('Error saving budget: $e');
    }
  }

  double calculateSpentPercentage(double spent) {
    if (_monthlyLimit <= 0) return 0.0;
    return (spent / _monthlyLimit).clamp(0.0, 1.0);
  }

  bool isOverBudget(double spent) {
    return spent > _monthlyLimit && _monthlyLimit > 0;
  }

  bool isNearLimit(double spent) {
    return spent >= (_monthlyLimit * 0.8) && !isOverBudget(spent);
  }
}

import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/transaction_model.dart';

class CategoryExpenseSummary {
  final String categoryId;
  final String categoryName;
  final int iconCode;
  final int colorValue;
  final double amount;
  final double percentage;

  CategoryExpenseSummary({
    required this.categoryId,
    required this.categoryName,
    required this.iconCode,
    required this.colorValue,
    required this.amount,
    required this.percentage,
  });

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);
}

class DailyExpenseSummary {
  final DateTime date;
  final double amount;
  final String dayName;

  DailyExpenseSummary({
    required this.date,
    required this.amount,
    required this.dayName,
  });
}

class ExpenseProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  // Filter & Search states
  String _searchQuery = '';
  TransactionType? _typeFilter; // null means 'All'
  String? _categoryFilter;
  DateTimeRange? _dateRangeFilter;
  String _sortBy = 'date_desc'; // 'date_desc', 'date_asc', 'amount_desc', 'amount_asc'

  List<TransactionModel> get allTransactions => _transactions;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  TransactionType? get typeFilter => _typeFilter;
  String? get categoryFilter => _categoryFilter;
  DateTimeRange? get dateRangeFilter => _dateRangeFilter;
  String get sortBy => _sortBy;

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    try {
      _transactions = await _db.getTransactions();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _db.insertTransaction(transaction);
    await loadTransactions();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _db.updateTransaction(transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await _db.deleteTransaction(id);
    await loadTransactions();
  }

  // Filter Setters
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setTypeFilter(TransactionType? type) {
    _typeFilter = type;
    notifyListeners();
  }

  void setCategoryFilter(String? categoryId) {
    _categoryFilter = categoryId;
    notifyListeners();
  }

  void setDateRangeFilter(DateTimeRange? range) {
    _dateRangeFilter = range;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _typeFilter = null;
    _categoryFilter = null;
    _dateRangeFilter = null;
    _sortBy = 'date_desc';
    notifyListeners();
  }

  // Filtered transactions for the History screen
  List<TransactionModel> get filteredTransactions {
    List<TransactionModel> list = List.from(_transactions);

    // Search query
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((t) {
        return t.title.toLowerCase().contains(q) ||
            t.categoryName.toLowerCase().contains(q) ||
            t.paymentMethod.toLowerCase().contains(q) ||
            (t.notes?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    // Type filter
    if (_typeFilter != null) {
      list = list.where((t) => t.type == _typeFilter).toList();
    }

    // Category filter
    if (_categoryFilter != null && _categoryFilter!.isNotEmpty) {
      list = list.where((t) => t.categoryId == _categoryFilter).toList();
    }

    // Date range filter
    if (_dateRangeFilter != null) {
      list = list.where((t) {
        final d = DateTime(t.date.year, t.date.month, t.date.day);
        final start = DateTime(_dateRangeFilter!.start.year, _dateRangeFilter!.start.month, _dateRangeFilter!.start.day);
        final end = DateTime(_dateRangeFilter!.end.year, _dateRangeFilter!.end.month, _dateRangeFilter!.end.day);
        return (d.isAtSameMomentAs(start) || d.isAfter(start)) &&
               (d.isAtSameMomentAs(end) || d.isBefore(end.add(const Duration(days: 1))));
      }).toList();
    }

    // Sorting
    switch (_sortBy) {
      case 'date_asc':
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'amount_desc':
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'amount_asc':
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'date_desc':
      default:
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
    }

    return list;
  }

  // Overall Financial Calculations
  double get totalIncome {
    return _transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalBalance => totalIncome - totalExpense;

  // Monthly Calculations
  double getMonthlyExpense(int month, int year) {
    return _transactions
        .where((t) => t.isExpense && t.date.month == month && t.date.year == year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getMonthlyIncome(int month, int year) {
    return _transactions
        .where((t) => t.isIncome && t.date.month == month && t.date.year == year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get currentMonthExpense {
    final now = DateTime.now();
    return getMonthlyExpense(now.month, now.year);
  }

  double get currentMonthIncome {
    final now = DateTime.now();
    return getMonthlyIncome(now.month, now.year);
  }

  // Category Expense Breakdown for Charts & Summaries
  List<CategoryExpenseSummary> getCategoryBreakdown(int month, int year) {
    final monthlyExpenses = _transactions.where(
      (t) => t.isExpense && t.date.month == month && t.date.year == year,
    );

    final total = monthlyExpenses.fold(0.0, (sum, t) => sum + t.amount);
    if (total == 0) return [];

    final Map<String, List<TransactionModel>> grouped = {};
    for (final t in monthlyExpenses) {
      grouped.putIfAbsent(t.categoryId, () => []).add(t);
    }

    final List<CategoryExpenseSummary> summaries = [];
    grouped.forEach((catId, list) {
      final subtotal = list.fold(0.0, (sum, t) => sum + t.amount);
      final first = list.first;
      summaries.add(
        CategoryExpenseSummary(
          categoryId: catId,
          categoryName: first.categoryName,
          iconCode: first.categoryIconCode,
          colorValue: first.categoryColorValue,
          amount: subtotal,
          percentage: (subtotal / total) * 100,
        ),
      );
    });

    summaries.sort((a, b) => b.amount.compareTo(a.amount));
    return summaries;
  }

  // Last 7 days expense breakdown for bar chart
  List<DailyExpenseSummary> getLast7DaysExpenses() {
    final now = DateTime.now();
    final List<DailyExpenseSummary> dailyList = [];

    const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final totalForDay = _transactions.where((t) {
        return t.isExpense &&
            t.date.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(dayEnd.add(const Duration(seconds: 1)));
      }).fold(0.0, (sum, t) => sum + t.amount);

      final dayName = weekDays[date.weekday - 1];

      dailyList.add(DailyExpenseSummary(
        date: date,
        amount: totalForDay,
        dayName: dayName,
      ));
    }

    return dailyList;
  }
}

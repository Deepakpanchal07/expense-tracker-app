import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../services/api_service.dart';
import 'seed_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  final ApiService _api = ApiService.instance;

  // In-memory fallback for web environment
  final List<TransactionModel> _webTransactions = [];
  final List<CategoryModel> _webCategories = [];
  final Map<String, double> _webBudgets = {};

  bool isBackendAvailable = false;

  DatabaseHelper._init();

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDB('expense_tracker.db');
    return _database;
  }

  Future<Database> _initDB(String filePath) async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon_code INTEGER NOT NULL,
        color_value INTEGER NOT NULL,
        is_expense INTEGER NOT NULL,
        is_default INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category_id TEXT NOT NULL,
        category_name TEXT NOT NULL,
        category_icon_code INTEGER NOT NULL,
        category_color_value INTEGER NOT NULL,
        type TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        monthly_limit REAL NOT NULL,
        PRIMARY KEY (month, year)
      )
    ''');

    // Only seed categories. Transactions start completely empty (0 data).
    final batch = db.batch();
    for (final cat in SeedData.defaultCategories) {
      batch.insert('categories', cat.toMap());
    }
    await batch.commit(noResult: true);
  }

  // --- Category Operations (MongoDB + Local Sync) ---

  Future<List<CategoryModel>> getCategories() async {
    try {
      final remoteCategories = await _api.getCategories();
      if (remoteCategories.isNotEmpty) {
        isBackendAvailable = true;
        for (final cat in remoteCategories) {
          await _saveCategoryLocal(cat);
        }
        return remoteCategories;
      }
    } catch (e) {
      debugPrint('MongoDB fetch error, falling back to local: $e');
      isBackendAvailable = false;
    }

    return await _getLocalCategories();
  }

  Future<List<CategoryModel>> _getLocalCategories() async {
    if (kIsWeb) {
      if (_webCategories.isEmpty) {
        await _loadWebCategories();
      }
      return List.unmodifiable(_webCategories);
    }

    final db = await database;
    final result = await db!.query('categories', orderBy: 'name ASC');
    if (result.isEmpty) {
      for (final cat in SeedData.defaultCategories) {
        await _saveCategoryLocal(cat);
      }
      return SeedData.defaultCategories;
    }
    return result.map((json) => CategoryModel.fromMap(json)).toList();
  }

  Future<void> _saveCategoryLocal(CategoryModel category) async {
    if (kIsWeb) {
      _webCategories.removeWhere((c) => c.id == category.id);
      _webCategories.add(category);
      await _saveWebCategories();
      return;
    }

    final db = await database;
    await db!.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertCategory(CategoryModel category) async {
    try {
      await _api.createCategory(category);
      isBackendAvailable = true;
    } catch (e) {
      debugPrint('Failed to push category to MongoDB: $e');
    }
    await _saveCategoryLocal(category);
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _api.updateCategory(category);
      isBackendAvailable = true;
    } catch (e) {
      debugPrint('Failed to update category in MongoDB: $e');
    }

    if (kIsWeb) {
      final index = _webCategories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _webCategories[index] = category;
        await _saveWebCategories();
      }
      return;
    }

    final db = await database;
    await db!.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _api.deleteCategory(id);
      isBackendAvailable = true;
    } catch (e) {
      debugPrint('Failed to delete category in MongoDB: $e');
    }

    if (kIsWeb) {
      _webCategories.removeWhere((c) => c.id == id);
      await _saveWebCategories();
      return;
    }

    final db = await database;
    await db!.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Transaction Operations (MongoDB + Local Sync) ---

  Future<List<TransactionModel>> getTransactions() async {
    // 1. Try to fetch from Node.js + MongoDB API
    try {
      final remoteTransactions = await _api.getTransactions();
      isBackendAvailable = true;
      // Mirror remote transactions to local cache
      await _syncLocalTransactions(remoteTransactions);
      return remoteTransactions;
    } catch (e) {
      debugPrint('MongoDB fetch error, falling back to local: $e');
      isBackendAvailable = false;
    }

    // 2. Fallback to local storage if API is offline
    return await _getLocalTransactions();
  }

  Future<void> _syncLocalTransactions(List<TransactionModel> transactions) async {
    if (kIsWeb) {
      _webTransactions.clear();
      _webTransactions.addAll(transactions);
      await _saveWebTransactions();
      return;
    }

    final db = await database;
    if (db != null) {
      await db.delete('transactions');
      final batch = db.batch();
      for (final tx in transactions) {
        batch.insert('transactions', tx.toMap());
      }
      await batch.commit(noResult: true);
    }
  }

  Future<List<TransactionModel>> _getLocalTransactions() async {
    if (kIsWeb) {
      if (_webTransactions.isEmpty) {
        await _loadWebTransactions();
      }
      return List.unmodifiable(_webTransactions);
    }

    final db = await database;
    final result = await db!.query('transactions', orderBy: 'date DESC');
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<void> _saveTransactionLocal(TransactionModel transaction) async {
    if (kIsWeb) {
      _webTransactions.removeWhere((t) => t.id == transaction.id);
      _webTransactions.insert(0, transaction);
      await _saveWebTransactions();
      return;
    }

    final db = await database;
    await db!.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertTransaction(TransactionModel transaction) async {
    try {
      await _api.createTransaction(transaction);
      isBackendAvailable = true;
    } catch (e) {
      debugPrint('Failed to push transaction to MongoDB: $e');
    }
    await _saveTransactionLocal(transaction);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _api.updateTransaction(transaction);
      isBackendAvailable = true;
    } catch (e) {
      debugPrint('Failed to update transaction in MongoDB: $e');
    }

    if (kIsWeb) {
      final index = _webTransactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _webTransactions[index] = transaction;
        await _saveWebTransactions();
      }
      return;
    }

    final db = await database;
    await db!.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _api.deleteTransaction(id);
      isBackendAvailable = true;
    } catch (e) {
      debugPrint('Failed to delete transaction in MongoDB: $e');
    }

    if (kIsWeb) {
      _webTransactions.removeWhere((t) => t.id == id);
      await _saveWebTransactions();
      return;
    }

    final db = await database;
    await db!.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Budget Operations (MongoDB + Local Sync) ---

  Future<double> getMonthlyBudget(int month, int year) async {
    try {
      final remoteBudget = await _api.getBudget(month, year);
      isBackendAvailable = true;
      return remoteBudget;
    } catch (_) {
      isBackendAvailable = false;
    }

    if (kIsWeb) {
      final key = '$month-$year';
      return _webBudgets[key] ?? 0.0;
    }

    final db = await database;
    final result = await db!.query(
      'budgets',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );

    if (result.isNotEmpty) {
      return (result.first['monthly_limit'] as num).toDouble();
    }
    return 0.0; // Starts at 0.0 until user sets one
  }

  Future<void> setMonthlyBudget(int month, int year, double limit) async {
    try {
      await _api.saveBudget(month, year, limit);
      isBackendAvailable = true;
    } catch (_) {
      isBackendAvailable = false;
    }

    if (kIsWeb) {
      final key = '$month-$year';
      _webBudgets[key] = limit;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('budget_$key', limit);
      return;
    }

    final db = await database;
    await db!.insert(
      'budgets',
      {
        'month': month,
        'year': year,
        'monthly_limit': limit,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Helper to wipe old cached local demo transactions
  Future<void> purgeLocalTransactions() async {
    _webTransactions.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_transactions');
    if (!kIsWeb) {
      final db = await database;
      await db?.delete('transactions');
    }
  }

  // --- Web Persistence Helpers (using SharedPreferences) ---

  Future<void> _loadWebCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('saved_categories');
    if (data != null && data.isNotEmpty) {
      final List decoded = jsonDecode(data);
      _webCategories.clear();
      _webCategories.addAll(decoded.map((e) => CategoryModel.fromMap(e)));
    } else {
      _webCategories.clear();
      _webCategories.addAll(SeedData.defaultCategories);
      await _saveWebCategories();
    }
  }

  Future<void> _saveWebCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _webCategories.map((c) => c.toMap()).toList();
    await prefs.setString('saved_categories', jsonEncode(jsonList));
  }

  Future<void> _loadWebTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('saved_transactions');
    _webTransactions.clear();
    if (data != null && data.isNotEmpty) {
      final List decoded = jsonDecode(data);
      _webTransactions.addAll(decoded.map((e) => TransactionModel.fromMap(e)));
    }
  }

  Future<void> _saveWebTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _webTransactions.map((t) => t.toMap()).toList();
    await prefs.setString('saved_transactions', jsonEncode(jsonList));
  }
}

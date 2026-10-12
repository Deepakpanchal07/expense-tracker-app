import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

class ApiService {
  static final ApiService instance = ApiService._init();
  ApiService._init();

  // Dynamic base URL detection
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:5000/api';
    } else if (Platform.isAndroid) {
      // 10.0.2.2 points to host machine from Android Emulator
      return 'http://10.0.2.2:5000/api';
    } else {
      // Windows Desktop, iOS, macOS, Linux
      return 'http://127.0.0.1:5000/api';
    }
  }

  String _baseUrl = defaultBaseUrl;
  String get baseUrl => _baseUrl;

  String? authToken;

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (authToken != null && authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  void setBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? '${url}api' : url;
  }

  final Duration _timeout = const Duration(seconds: 4);

  // Health check
  Future<bool> checkServerHealth() async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/health')).timeout(_timeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // --- Authentication API ---

  Future<UserModel> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    ).timeout(_timeout);

    final data = jsonDecode(response.body);
    if (response.statusCode == 201 && data['success'] == true) {
      authToken = data['token'];
      return UserModel(
        id: data['user']['id'],
        name: data['user']['name'],
        email: data['user']['email'],
        token: authToken,
      );
    } else {
      throw Exception(data['message'] ?? 'Failed to register');
    }
  }

  Future<UserModel> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    ).timeout(_timeout);

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      authToken = data['token'];
      return UserModel(
        id: data['user']['id'],
        name: data['user']['name'],
        email: data['user']['email'],
        token: authToken,
      );
    } else {
      throw Exception(data['message'] ?? 'Failed to login');
    }
  }

  Future<UserModel?> getMe() async {
    if (authToken == null) return null;
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/auth/me'), headers: _headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel(
          id: data['user']['id'],
          name: data['user']['name'],
          email: data['user']['email'],
          token: authToken,
        );
      }
    } catch (_) {}
    return null;
  }

  // --- Categories API ---

  Future<List<CategoryModel>> getCategories() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/categories'), headers: _headers)
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) {
        return CategoryModel(
          id: json['id'] as String,
          name: json['name'] as String,
          iconCode: json['icon_code'] as int,
          colorValue: json['color_value'] as int,
          isExpense: json['is_expense'] == true,
          isDefault: json['is_default'] == true,
        );
      }).toList();
    } else {
      throw Exception('Failed to load categories from MongoDB backend: ${response.statusCode}');
    }
  }

  Future<CategoryModel> createCategory(CategoryModel category) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/categories'),
      headers: _headers,
      body: jsonEncode({
        'id': category.id,
        'name': category.name,
        'icon_code': category.iconCode,
        'color_value': category.colorValue,
        'is_expense': category.isExpense,
        'is_default': category.isDefault,
      }),
    ).timeout(_timeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return category;
    } else {
      throw Exception('Failed to create category: ${response.body}');
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/categories/${category.id}'),
      headers: _headers,
      body: jsonEncode({
        'name': category.name,
        'icon_code': category.iconCode,
        'color_value': category.colorValue,
        'is_expense': category.isExpense,
      }),
    ).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to update category: ${response.body}');
    }
  }

  Future<void> deleteCategory(String id) async {
    final response = await http
        .delete(Uri.parse('$_baseUrl/categories/$id'), headers: _headers)
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete category: ${response.body}');
    }
  }

  // --- Transactions API ---

  Future<List<TransactionModel>> getTransactions() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/transactions'), headers: _headers)
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) {
        return TransactionModel(
          id: json['id'] as String,
          title: json['title'] as String,
          amount: (json['amount'] as num).toDouble(),
          date: DateTime.parse(json['date'] as String).toLocal(),
          categoryId: json['category_id'] as String,
          categoryName: json['category_name'] as String,
          categoryIconCode: json['category_icon_code'] as int,
          categoryColorValue: json['category_color_value'] as int,
          type: json['type'] == 'expense' ? TransactionType.expense : TransactionType.income,
          paymentMethod: (json['payment_method'] as String?) ?? 'Cash',
          notes: (json['notes'] as String?)?.isEmpty == true ? null : json['notes'] as String?,
        );
      }).toList();
    } else {
      throw Exception('Failed to load transactions: ${response.statusCode}');
    }
  }

  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/transactions'),
      headers: _headers,
      body: jsonEncode({
        'id': transaction.id,
        'title': transaction.title,
        'amount': transaction.amount,
        'date': transaction.date.toIso8601String(),
        'category_id': transaction.categoryId,
        'category_name': transaction.categoryName,
        'category_icon_code': transaction.categoryIconCode,
        'category_color_value': transaction.categoryColorValue,
        'type': transaction.isExpense ? 'expense' : 'income',
        'payment_method': transaction.paymentMethod,
        'notes': transaction.notes ?? '',
      }),
    ).timeout(_timeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return transaction;
    } else {
      throw Exception('Failed to create transaction: ${response.body}');
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/transactions/${transaction.id}'),
      headers: _headers,
      body: jsonEncode({
        'title': transaction.title,
        'amount': transaction.amount,
        'date': transaction.date.toIso8601String(),
        'category_id': transaction.categoryId,
        'category_name': transaction.categoryName,
        'category_icon_code': transaction.categoryIconCode,
        'category_color_value': transaction.categoryColorValue,
        'type': transaction.isExpense ? 'expense' : 'income',
        'payment_method': transaction.paymentMethod,
        'notes': transaction.notes ?? '',
      }),
    ).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to update transaction: ${response.body}');
    }
  }

  Future<void> deleteTransaction(String id) async {
    final response = await http
        .delete(Uri.parse('$_baseUrl/transactions/$id'), headers: _headers)
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete transaction: ${response.body}');
    }
  }

  // --- Budget API ---

  Future<double> getBudget(int month, int year) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/budgets/$month/$year'), headers: _headers)
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['monthly_limit'] as num).toDouble();
    }
    return 30000.0;
  }

  Future<void> saveBudget(int month, int year, double limit) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/budgets'),
      headers: _headers,
      body: jsonEncode({
        'month': month,
        'year': year,
        'monthly_limit': limit,
      }),
    ).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to save budget: ${response.body}');
    }
  }
}

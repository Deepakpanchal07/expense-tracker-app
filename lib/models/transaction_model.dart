import 'package:flutter/material.dart';

enum TransactionType { expense, income }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String categoryName;
  final int categoryIconCode;
  final int categoryColorValue;
  final TransactionType type;
  final String paymentMethod;
  final String? notes;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIconCode,
    required this.categoryColorValue,
    required this.type,
    this.paymentMethod = 'Cash',
    this.notes,
  });

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;

  IconData get categoryIcon => IconData(categoryIconCode, fontFamily: 'MaterialIcons');
  Color get categoryColor => Color(categoryColorValue);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category_id': categoryId,
      'category_name': categoryName,
      'category_icon_code': categoryIconCode,
      'category_color_value': categoryColorValue,
      'type': type == TransactionType.expense ? 'expense' : 'income',
      'payment_method': paymentMethod,
      'notes': notes ?? '',
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      categoryId: map['category_id'] as String,
      categoryName: map['category_name'] as String,
      categoryIconCode: map['category_icon_code'] as int,
      categoryColorValue: map['category_color_value'] as int,
      type: map['type'] == 'expense' ? TransactionType.expense : TransactionType.income,
      paymentMethod: (map['payment_method'] as String?) ?? 'Cash',
      notes: (map['notes'] as String?)?.isEmpty == true ? null : map['notes'] as String?,
    );
  }

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? categoryId,
    String? categoryName,
    int? categoryIconCode,
    int? categoryColorValue,
    TransactionType? type,
    String? paymentMethod,
    String? notes,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIconCode: categoryIconCode ?? this.categoryIconCode,
      categoryColorValue: categoryColorValue ?? this.categoryColorValue,
      type: type ?? this.type,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
    );
  }
}

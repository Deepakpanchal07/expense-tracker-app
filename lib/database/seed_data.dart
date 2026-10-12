import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class SeedData {
  static final List<CategoryModel> defaultCategories = [
    // Expense Categories
    CategoryModel(
      id: 'cat_food',
      name: 'Food & Dining',
      iconCode: Icons.restaurant_rounded.codePoint,
      colorValue: const Color(0xFFFF6B6B).toARGB32(),
      isExpense: true,
      isDefault: true,
    ),
    CategoryModel(
      id: 'cat_groceries',
      name: 'Groceries',
      iconCode: Icons.shopping_cart_rounded.codePoint,
      colorValue: const Color(0xFFFA8231).toARGB32(),
      isExpense: true,
      isDefault: true,
    ),
    CategoryModel(
      id: 'cat_transport',
      name: 'Transport & Fuel',
      iconCode: Icons.directions_car_rounded.codePoint,
      colorValue: const Color(0xFF45AAF2).toARGB32(),
      isExpense: true,
      isDefault: true,
    ),
    CategoryModel(
      id: 'cat_shopping',
      name: 'Shopping',
      iconCode: Icons.shopping_bag_rounded.codePoint,
      colorValue: const Color(0xFFA55EEA).toARGB32(),
      isExpense: true,
      isDefault: true,
    ),
    CategoryModel(
      id: 'cat_housing',
      name: 'Housing & Rent',
      iconCode: Icons.home_rounded.codePoint,
      colorValue: const Color(0xFF26DE81).toARGB32(),
      isExpense: true,
      isDefault: true,
    ),
    CategoryModel(
      id: 'cat_entertainment',
      name: 'Entertainment',
      iconCode: Icons.movie_rounded.codePoint,
      colorValue: const Color(0xFFFD9644).toARGB32(),
      isExpense: true,
      isDefault: true,
    ),
    CategoryModel(
      id: 'cat_bills',
      name: 'Bills & Utilities',
      iconCode: Icons.receipt_long_rounded.codePoint,
      colorValue: const Color(0xFF2BCBBA).toARGB32(),
      isExpense: true,
      isDefault: true,
    ),
    CategoryModel(
      id: 'cat_health',
      name: 'Healthcare',
      iconCode: Icons.local_hospital_rounded.codePoint,
      colorValue: const Color(0xFFFC5C65).toARGB32(),
      isExpense: true,
      isDefault: true,
    ),
    CategoryModel(
      id: 'cat_education',
      name: 'Education',
      iconCode: Icons.school_rounded.codePoint,
      colorValue: const Color(0xFF4B7BEC).toARGB32(),
      isExpense: true,
      isDefault: true,
    ),
    CategoryModel(
      id: 'cat_other_exp',
      name: 'General / Other',
      iconCode: Icons.more_horiz_rounded.codePoint,
      colorValue: const Color(0xFF778CA3).toARGB32(),
      isExpense: true,
      isDefault: true,
    ),

    // Income Categories
    CategoryModel(
      id: 'cat_salary',
      name: 'Monthly Salary',
      iconCode: Icons.account_balance_wallet_rounded.codePoint,
      colorValue: const Color(0xFF20BF6B).toARGB32(),
      isExpense: false,
      isDefault: true,
    ),
    CategoryModel(
      id: 'cat_freelance',
      name: 'Freelance & Projects',
      iconCode: Icons.laptop_chromebook_rounded.codePoint,
      colorValue: const Color(0xFF0FB9B1).toARGB32(),
      isExpense: false,
      isDefault: true,
    ),
    CategoryModel(
      id: 'cat_investment',
      name: 'Investments & Stocks',
      iconCode: Icons.trending_up_rounded.codePoint,
      colorValue: const Color(0xFF2D98DA).toARGB32(),
      isExpense: false,
      isDefault: true,
    ),
    CategoryModel(
      id: 'cat_bonus',
      name: 'Gifts & Bonus',
      iconCode: Icons.card_giftcard_rounded.codePoint,
      colorValue: const Color(0xFFFF9FF3).toARGB32(),
      isExpense: false,
      isDefault: true,
    ),
  ];

  static List<TransactionModel> getInitialTransactions() {
    // Starting with clean zero data as requested
    return [];
  }
}

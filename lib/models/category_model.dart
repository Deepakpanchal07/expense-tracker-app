import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final int iconCode;
  final int colorValue;
  final bool isExpense;
  final bool isDefault;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    this.isExpense = true,
    this.isDefault = false,
  });

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_code': iconCode,
      'color_value': colorValue,
      'is_expense': isExpense ? 1 : 0,
      'is_default': isDefault ? 1 : 0,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      iconCode: map['icon_code'] as int,
      colorValue: map['color_value'] as int,
      isExpense: (map['is_expense'] as int) == 1,
      isDefault: (map['is_default'] as int) == 1,
    );
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    int? iconCode,
    int? colorValue,
    bool? isExpense,
    bool? isDefault,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      isExpense: isExpense ?? this.isExpense,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

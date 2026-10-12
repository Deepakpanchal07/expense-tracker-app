import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/category_model.dart';
import '../../../providers/category_provider.dart';

class AddCategoryDialog extends StatefulWidget {
  final bool isExpense;

  const AddCategoryDialog({super.key, this.isExpense = true});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  late bool _isExpense;
  late int _selectedIconCode;
  late int _selectedColorValue;

  final List<IconData> _availableIcons = [
    Icons.restaurant_rounded,
    Icons.shopping_cart_rounded,
    Icons.shopping_bag_rounded,
    Icons.directions_car_rounded,
    Icons.flight_takeoff_rounded,
    Icons.home_rounded,
    Icons.movie_rounded,
    Icons.local_hospital_rounded,
    Icons.school_rounded,
    Icons.fitness_center_rounded,
    Icons.pets_rounded,
    Icons.coffee_rounded,
    Icons.receipt_long_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.laptop_chromebook_rounded,
    Icons.trending_up_rounded,
    Icons.business_center_rounded,
    Icons.card_giftcard_rounded,
    Icons.attach_money_rounded,
    Icons.more_horiz_rounded,
  ];

  final List<Color> _availableColors = [
    const Color(0xFFFF6B6B),
    const Color(0xFFFA8231),
    const Color(0xFF26DE81),
    const Color(0xFF2BCBBA),
    const Color(0xFF45AAF2),
    const Color(0xFF4B7BEC),
    const Color(0xFFA55EEA),
    const Color(0xFFFF9FF3),
    const Color(0xFF10AC84),
    const Color(0xFFE17055),
    const Color(0xFF6C5CE7),
    const Color(0xFF778CA3),
  ];

  @override
  void initState() {
    super.initState();
    _isExpense = widget.isExpense;
    _selectedIconCode = _availableIcons.first.codePoint;
    _selectedColorValue = _availableColors.first.toARGB32();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    if (!_formKey.currentState!.validate()) return;

    final newCategory = CategoryModel(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      iconCode: _selectedIconCode,
      colorValue: _selectedColorValue,
      isExpense: _isExpense,
      isDefault: false,
    );

    context.read<CategoryProvider>().addCategory(newCategory);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Category "${newCategory.name}" added')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Create Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMutedDark),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Category Type selector
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Expense')),
                        selected: _isExpense,
                        selectedColor: AppColors.expense.withValues(alpha: 0.3),
                        labelStyle: TextStyle(
                          color: _isExpense ? AppColors.expense : AppColors.textSecondaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _isExpense = true);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Income')),
                        selected: !_isExpense,
                        selectedColor: AppColors.income.withValues(alpha: 0.3),
                        labelStyle: TextStyle(
                          color: !_isExpense ? AppColors.income : AppColors.textSecondaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _isExpense = false);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Name Input
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'e.g. Subscriptions, Gaming, Coffee',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter category name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Icon Picker
                const Text(
                  'Select Icon',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _availableIcons.map((icon) {
                    final isSelected = _selectedIconCode == icon.codePoint;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedIconCode = icon.codePoint);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(_selectedColorValue).withValues(alpha: 0.25)
                              : AppColors.darkSurfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Color(_selectedColorValue) : AppColors.darkBorder,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          icon,
                          size: 20,
                          color: isSelected ? Color(_selectedColorValue) : AppColors.textSecondaryDark,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Color Picker
                const Text(
                  'Select Color',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _availableColors.map((color) {
                    final isSelected = _selectedColorValue == color.toARGB32();
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedColorValue = color.toARGB32());
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8)]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 18, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _saveCategory,
                    child: const Text('Save Category'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

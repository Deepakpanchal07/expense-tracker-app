import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/expense_provider.dart';

class TransactionFilterSheet extends StatefulWidget {
  const TransactionFilterSheet({super.key});

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  String? _selectedCategory;
  DateTimeRange? _selectedRange;
  late String _sortBy;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ExpenseProvider>();
    _selectedCategory = provider.categoryFilter;
    _selectedRange = provider.dateRangeFilter;
    _sortBy = provider.sortBy;
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.darkSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter & Sort',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                    _selectedRange = null;
                    _sortBy = 'date_desc';
                  });
                },
                child: const Text('Reset All', style: TextStyle(color: AppColors.expense)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sort By Options
          const Text(
            'Sort By',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSortChip('Date: Newest First', 'date_desc'),
              _buildSortChip('Date: Oldest First', 'date_asc'),
              _buildSortChip('Amount: High to Low', 'amount_desc'),
              _buildSortChip('Amount: Low to High', 'amount_asc'),
            ],
          ),
          const SizedBox(height: 18),

          // Date Range Filter
          const Text(
            'Date Range',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDateRange,
                  icon: const Icon(Icons.date_range_rounded, size: 18),
                  label: Text(
                    _selectedRange == null
                        ? 'Select Date Range'
                        : '${DateFormatter.formatShortDate(_selectedRange!.start)} - ${DateFormatter.formatShortDate(_selectedRange!.end)}',
                  ),
                ),
              ),
              if (_selectedRange != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textMutedDark),
                  onPressed: () => setState(() => _selectedRange = null),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),

          // Category Filter
          const Text(
            'Category',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = _selectedCategory == null;
                  return ChoiceChip(
                    label: const Text('All Categories'),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedCategory = null),
                  );
                }
                final cat = categories[index - 1];
                final isSelected = _selectedCategory == cat.id;
                return ChoiceChip(
                  label: Text(cat.name),
                  selected: isSelected,
                  onSelected: (val) => setState(() => _selectedCategory = val ? cat.id : null),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Apply button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                final provider = context.read<ExpenseProvider>();
                provider.setCategoryFilter(_selectedCategory);
                provider.setDateRangeFilter(_selectedRange);
                provider.setSortBy(_sortBy);
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ),
          const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _sortBy = value);
      },
    );
  }
}

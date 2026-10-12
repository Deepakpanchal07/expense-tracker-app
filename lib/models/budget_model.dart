class BudgetModel {
  final int month;
  final int year;
  final double monthlyLimit;

  BudgetModel({
    required this.month,
    required this.year,
    required this.monthlyLimit,
  });

  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'year': year,
      'monthly_limit': monthlyLimit,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      month: map['month'] as int,
      year: map['year'] as int,
      monthlyLimit: (map['monthly_limit'] as num).toDouble(),
    );
  }
}

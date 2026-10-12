import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/expense_provider.dart';

class SpendingBarChart extends StatelessWidget {
  final List<DailyExpenseSummary> dailyExpenses;

  const SpendingBarChart({super.key, required this.dailyExpenses});

  @override
  Widget build(BuildContext context) {
    if (dailyExpenses.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: const Text('No weekly data', style: TextStyle(color: AppColors.textMutedDark)),
      );
    }

    final maxVal = dailyExpenses.map((e) => e.amount).fold(0.0, (a, b) => a > b ? a : b);
    final double maxY = maxVal <= 0 ? 1000 : maxVal * 1.25;

    return AspectRatio(
      aspectRatio: 1.6,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.darkSurfaceCard,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final day = dailyExpenses[group.x.toInt()];
                return BarTooltipItem(
                  '${day.dayName}\n',
                  const TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold, fontSize: 13),
                  children: [
                    TextSpan(
                      text: CurrencyFormatter.format(rod.toY),
                      style: const TextStyle(color: AppColors.expense, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  if (value == 0 || value == maxY) return const SizedBox.shrink();
                  return Text(
                    CurrencyFormatter.formatCompact(value),
                    style: const TextStyle(color: AppColors.textMutedDark, fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < dailyExpenses.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        dailyExpenses[index].dayName,
                        style: const TextStyle(
                          color: AppColors.textSecondaryDark,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) => const FlLine(
              color: AppColors.darkBorder,
              strokeWidth: 0.8,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(dailyExpenses.length, (index) {
            final item = dailyExpenses[index];
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: item.amount,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 14,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: AppColors.darkSurfaceCard,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

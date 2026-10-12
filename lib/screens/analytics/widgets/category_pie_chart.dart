import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/expense_provider.dart';

class CategoryPieChart extends StatefulWidget {
  final List<CategoryExpenseSummary> summaries;

  const CategoryPieChart({super.key, required this.summaries});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.summaries.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const Text(
          'No expense data to analyze for this period',
          style: TextStyle(color: AppColors.textMutedDark),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 3,
              centerSpaceRadius: 46,
              sections: _buildSections(),
            ),
          ),
          // Center Text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _touchedIndex >= 0 && _touchedIndex < widget.summaries.length
                    ? '${widget.summaries[_touchedIndex].percentage.toStringAsFixed(1)}%'
                    : '${widget.summaries.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              Text(
                _touchedIndex >= 0 && _touchedIndex < widget.summaries.length
                    ? widget.summaries[_touchedIndex].categoryName
                    : 'Categories',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMutedDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return List.generate(widget.summaries.length, (i) {
      final isTouched = i == _touchedIndex;
      final radius = isTouched ? 48.0 : 40.0;
      final summary = widget.summaries[i];

      return PieChartSectionData(
        color: summary.color,
        value: summary.amount,
        title: isTouched ? '${summary.percentage.toStringAsFixed(0)}%' : '',
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/main.dart';

void main() {
  testWidgets('Expense tracker app initial pump smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTrackerApp());
    expect(find.byType(ExpenseTrackerApp), findsOneWidget);
  });
}

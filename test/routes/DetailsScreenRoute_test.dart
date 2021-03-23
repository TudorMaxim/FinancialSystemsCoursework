import 'dart:math';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:financial_systems_coursework/routes/DetailsScreenRoute.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<Stock> stocks = [];
  String period = '12d';
  int stocksCnt = 100;
  DateTime startDate = DateTime.now().subtract(Duration(days: stocksCnt - 12));

  setUp(() async {
    Random random = new Random();
    for (int i = 0; i < stocksCnt; i++) {
      stocks.add(Stock(
        ticker: 'MSFT',
        timestamp: startDate.add(Duration(days: i - 12)).millisecondsSinceEpoch,
        currentMarketPrice: random.nextInt(91).toDouble() + 10,
      ));
    }
  });

  group('Test Details Screen', () {
    testWidgets('Test Strings', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: DetailsScreen(
          period: period,
          stocks: stocks,
          startDate: startDate,
      )));
      await tester.pump(Duration(seconds: 2));
      expect(find.text('Date: '), findsOneWidget);
      expect(find.text('Time: '), findsOneWidget);
    });

    testWidgets('Test Widgets Presence', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: DetailsScreen(
          period: period,
          stocks: stocks,
          startDate: startDate,
      )));
      await tester.pump(Duration(seconds: 2));
      expect(find.byKey(DetailsScreenKeys.popupMenu), findsOneWidget);
      expect(find.byKey(DetailsScreenKeys.chart), findsOneWidget);
    });
  });
}

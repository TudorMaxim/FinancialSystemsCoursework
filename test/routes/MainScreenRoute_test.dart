import 'package:financial_systems_coursework/routes/MainScreenRoute.dart';
import 'package:financial_systems_coursework/widgets/DateRangeSelector.dart';
import 'package:financial_systems_coursework/widgets/SelectForm.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

void main() {
  group('Test basic things', () {
    testWidgets('Test Strings', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MainScreenRoute(),
      ));
      await tester.pump(Duration(seconds: 2));

      expect(find.text('Select Stock'), findsOneWidget);
      expect(find.text('Pick Date Range'), findsOneWidget);
      expect(find.text('Load Data'), findsOneWidget);
      expect(find.text('Period'), findsOneWidget);
      expect(find.text('Ticker'), findsOneWidget);
    });

    testWidgets('Test Widgets Presence', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MainScreenRoute(),
      ));
      await tester.pump(Duration(seconds: 2));
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(SelectForm), findsNWidgets(2));
      expect(find.byType(DateRangeSelector), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}

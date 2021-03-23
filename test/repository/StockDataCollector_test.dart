import 'dart:io';

import 'package:financial_systems_coursework/repository/StockDataCollector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'StockDataCollector_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  /// Test createURL
  test('Craft URL correctly', () {
    String expected =
        'https://query1.finance.yahoo.com/v8/finance/chart/AAPL?symbol=AAPL&period1=1612437713&period2=1614856913&interval=1d';
    String actual = new StockDataCollector()
        .createURL('AAPL', '1612437713', '1614856913')
        .toString();

    expect(actual, expected);
  });

  /// Test getPricesAsJSON
  test('Check JSON response from web', () async {
    http.Response expectedResponse = http.Response(
        File('test_resources/AAPL_test_response.json').readAsStringSync(), 200);

    final mockClient = MockClient();
    when(mockClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => expectedResponse);
    StockDataCollector().httpClientForTesting = mockClient;

    /// Craft expected
    String actual = await StockDataCollector()
        .getPricesAsJSON('AAPL', '1612437713', '1614856913');

    expect(actual, expectedResponse.body);
  });
}

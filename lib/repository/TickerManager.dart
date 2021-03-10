import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

class TickerManager {
  static final TickerManager _instance = TickerManager._init();

  TickerManager._init();

  factory TickerManager() {
    return _instance;
  }

  Future<List<String>> get tickers async {
    final String _tickerString =
        await rootBundle.loadString('assets/tickers.csv');
    final List<List<dynamic>> _csvData =
        CsvToListConverter().convert(_tickerString);
    final List<String> res =
        _csvData.first.map((e) => e.toString().replaceFirst(',', '')).toList();
    return res;
  }

  List<String> filterSuggestions(String pattern, List<String> tickers) {
    return tickers
        .where((t) => t.trim().startsWith(pattern.trim().toUpperCase()))
        .toList();
  }
}

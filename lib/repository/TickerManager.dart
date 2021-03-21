import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

class TickerManager {
  static final TickerManager _instance = TickerManager._init();

  static final String _tickersLocation = 'assets/tickers.csv';

  TickerManager._init();

  factory TickerManager() {
    return _instance;
  }

  String _processTicker(String t) {
    return t.replaceAll(',', '').trim();
  }

  List<String> _flattenTickers(List<List<dynamic>> tickers) {
    // tickers is of the form [[A, ','], [B, ','], [C, ','] ...]
    if (tickers.first.length == 2) {
      return tickers.map((l) => _processTicker(l.first.toString())).toList();
      // tickers is of the form [[A, B, C, ...]]
    } else {
      return tickers.first.map((s) => _processTicker(s)).toList();
    }
  }

  Future<List<String>> get tickers async {
    final String _tickerString = await rootBundle.loadString(_tickersLocation);
    final List<List<dynamic>> _csvData =
        CsvToListConverter().convert(_tickerString);
    return _flattenTickers(_csvData);
  }

  List<String> filterSuggestions(String pattern, List<String> tickers) {
    return tickers
        .where((t) => t.trim().startsWith(pattern.trim().toUpperCase()))
        .toList();
  }
}

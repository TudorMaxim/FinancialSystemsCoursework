import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

class SymbolManager {
  static final SymbolManager _instance = SymbolManager._init();

  SymbolManager._init();

  factory SymbolManager() {
    return _instance;
  }

  String _processSymbol(String t) {
    return t.replaceAll(',', '').trim();
  }

  List<String> _flattenSymbols(List<List<dynamic>> tickers) {
    // tickers is of the form [[A, ','], [B, ','], [C, ','] ...]
    if (tickers.first.length == 2) {
      return tickers.map((l) => _processSymbol(l.first.toString())).toList();
      // tickers is of the form [[A, B, C, ...]]
    } else {
      return tickers.first.map((s) => _processSymbol(s)).toList();
    }
  }

  Future<List<String>> get symbols async {
    final String _tickerString =
        await rootBundle.loadString('assets/tickers.csv');
    final List<List<dynamic>> _csvData =
        CsvToListConverter().convert(_tickerString);
    return _flattenSymbols(_csvData);
  }

  List<String> filterSuggestions(String pattern, List<String> tickers) {
    return tickers
        .where((t) => t.trim().startsWith(pattern.trim().toUpperCase()))
        .toList();
  }
}

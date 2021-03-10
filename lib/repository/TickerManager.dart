import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

class TickerManager {
  static final TickerManager _instance = TickerManager._init();

  TickerManager._init();

  factory TickerManager() {
    return _instance;
  }

  List<String> flattenTickers(List<List<dynamic>> tickers) {
    List<String> res = [];
    tickers.forEach((innerL) {
      innerL.forEach((element) {
        if(element is String) {
          res.add(element);
        } else {
          throw('Error - A non string entity was parsed in the tickers csv');
        }
      });
    });
    return res;
  }

  Future<List<String>> get tickers async {
    final String _tickerString =
        await rootBundle.loadString('assets/tickers.csv');
    final List<List<dynamic>> _csvData =
        CsvToListConverter().convert(_tickerString);
    return flattenTickers(_csvData);
  }

  List<String> filterSuggestions(String pattern, List<String> tickers) {
    return tickers
        .where((t) => t.trim().startsWith(pattern.trim().toUpperCase()))
        .toList();
  }
}

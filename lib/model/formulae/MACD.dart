import 'package:financial_systems_coursework/model/Point.dart';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:financial_systems_coursework/model/formulae/Formulae.dart';
import 'package:flutter/cupertino.dart';

import 'EMA.dart';

class MACD implements Formulae {
  @override
  List<Point> compute(List<Stock> stocks, int period) {
    if (stocks.isEmpty) return [];
    //calculate multiplier for example 10 days would be 0.1818...
    // double shortMultiplier = 2 / (12 + 1); // fast EMA
    // double longMultiplier = 2 / (26 + 1); // slow EMA
    //store the first EMA value as the day's currentMarketPrice
    List<Point> indicators = [Point(stocks.first.currentMarketPrice, stocks.first.timestamp),
    ];

    List<Point> shortEMA = new EMA().compute(stocks, 12);
    List<Point> longEMA = new EMA().compute(stocks, 26);
    for (int i = 11; i < stocks.length; i++) {
      //multiplier dependent on the number of stocks
      double macdValue = shortEMA[i].value - longEMA[i].value;
      // debugPrint("MACD: " + (macdValue).toString());
      indicators.add(Point((macdValue), stocks[i].timestamp));
    }
    indicators.removeAt(0);
    return indicators;
  }
}

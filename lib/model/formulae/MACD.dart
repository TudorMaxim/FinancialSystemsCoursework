import 'package:financial_systems_coursework/model/Point.dart';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:financial_systems_coursework/model/formulae/Formulae.dart';
import 'package:flutter/cupertino.dart';
import 'EMA.dart';

class MACD implements Formulae {
  @override
  List<Point> compute(List<Stock> stocks, int period) {
    if (stocks.length < period) {
      throw new ErrorDescription("Period must be smalled than the number of stocks");
    }

    if (stocks.isEmpty) return [];

    List<Point> indicators = [Point(stocks.first.currentMarketPrice, stocks.first.timestamp),
    ];

    int shortEMAPeriod = 12;
    int longEMAPeriod = 26;

    List<Point> shortEMA = new EMA().compute(stocks, shortEMAPeriod);
    List<Point> longEMA = new EMA().compute(stocks, longEMAPeriod);
    for (int i = 0; i < stocks.length; i++) {
      double macdValue = shortEMA[i].value - longEMA[i].value;
      indicators.add(Point(macdValue, stocks[i].timestamp));
    }
    indicators.removeAt(0);
    return indicators;
  }
}

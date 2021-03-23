import 'package:financial_systems_coursework/model/Point.dart';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:financial_systems_coursework/model/formulae/Formulae.dart';
import 'package:flutter/cupertino.dart';
import 'EMA.dart';

class MACD implements Formulae {
  @override
  List<Point> compute(List<Stock> stocks, int period, int startIndex) {
    if (stocks.length < period) {
      throw new ErrorDescription(Formulae.periodError);
    }

    if (stocks.isEmpty) return [];

    List<Point> indicators = [
      Point(stocks.first.currentMarketPrice, stocks.first.timestamp),
    ];

    int shortEMAPeriod = 12;
    int longEMAPeriod = 26;

    List<Point> shortEMA =
        new EMA().compute(stocks, shortEMAPeriod, startIndex);
    List<Point> longEMA = new EMA().compute(stocks, longEMAPeriod, startIndex);
    for (int i = 0; i < stocks.length - startIndex; i++) {
      double macdValue = shortEMA[i].value - longEMA[i].value;
      indicators.add(Point(macdValue, stocks[startIndex + i].timestamp));
    }
    indicators.removeAt(0);
    return indicators;
  }
}

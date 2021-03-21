import 'package:financial_systems_coursework/model/Point.dart';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:financial_systems_coursework/model/formulae/Formulae.dart';
import 'package:flutter/cupertino.dart';

class SMA implements Formulae {
  @override
  List<Point> compute(List<Stock> stocks, int period, int startIndex) {
    if (stocks.length < period) {
      throw new ErrorDescription(Formulae.periodError);
    }

    List<Point> indicators = new List.filled(stocks.length,
        Point(stocks.first.currentMarketPrice, stocks.first.timestamp),
        growable: true);

    for (int i = startIndex; i <= stocks.length - 1; i++) {
      double sum = 0;
      for (int j = i - period; j < i; j++) {
        sum += stocks[j].currentMarketPrice;
      }
      double currentSMA = sum / period;

      indicators[i] = Point(currentSMA, stocks[i - 1].timestamp);
    }
    return indicators.sublist(startIndex);
  }
}

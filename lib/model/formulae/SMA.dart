import 'package:financial_systems_coursework/model/Point.dart';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:financial_systems_coursework/model/formulae/Formulae.dart';
import 'package:flutter/cupertino.dart';

class SMA implements Formulae {
  @override
  List<Point> compute(List<Stock> stocks, int period) {
    if (stocks.length < period) {
      throw new ErrorDescription("Period must be smalled than the number of stocks");
    }

    List<Point> indicators = new List.filled(stocks.length, Point(stocks.first.currentMarketPrice, stocks.first.timestamp), growable: true);

    for (int i = 0; i <= stocks.length - period; i++) {
      double sum = 0;
      for (int j = i; j < i + period; j++) {
        sum += stocks[j].currentMarketPrice;
      }
      double currentSMA = sum / period;

      indicators[i + period - 1] = Point(currentSMA, stocks[i + period - 1].timestamp);
    }
    return indicators;
  }
}

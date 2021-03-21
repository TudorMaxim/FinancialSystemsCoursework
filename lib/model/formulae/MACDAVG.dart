import 'package:financial_systems_coursework/model/Point.dart';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:financial_systems_coursework/model/formulae/Formulae.dart';
import 'package:financial_systems_coursework/model/formulae/MACD.dart';
import 'package:flutter/cupertino.dart';

import 'EMA.dart';

class MACDAVG implements Formulae {
  @override
  List<Point> compute(List<Stock> stocks, int period, int startIndex) {
    if (stocks.length < period) {
      throw new ErrorDescription(
          "Period must be smalled than the number of stocks");
    }

    if (stocks.isEmpty) return [];

    MACD macd = new MACD();
    List<Point> macdPoints = macd.compute(stocks, period, startIndex);
    List<Point> indicators = [
      Point(macdPoints.first.value, macdPoints.first.timestamp),
    ];

    List<Stock> macdStocks =
        this.pointsToStocks(macdPoints, stocks.first.ticker);
    List<Point> signalEma = new EMA().compute(macdStocks, 9, startIndex);

    for (int i = 0; i < signalEma.length; i++) {
      indicators.add(Point(
          (macdPoints[i].value - signalEma[i].value), macdPoints[i].timestamp));
    }
    indicators.removeAt(0);
    return indicators;
  }

  List<Stock> pointsToStocks(List<Point> points, String ticker) {
    List<Stock> stocks = List.empty(growable: true);
    for (int i = 0; i < points.length; i++) {
      stocks.add(Stock(
          ticker: ticker,
          timestamp: points[i].timestamp,
          currentMarketPrice: points[i].value));
    }

    return stocks;
  }
}

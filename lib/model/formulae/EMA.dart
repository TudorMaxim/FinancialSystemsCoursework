import 'package:financial_systems_coursework/model/Point.dart';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:financial_systems_coursework/model/formulae/Formulae.dart';
import 'package:flutter/cupertino.dart';

import 'SMA.dart';

class EMA implements Formulae {
  @override
  List<Point> compute(List<Stock> stocks, int period) {
    debugPrint("PERIOD: " + period.toString());
    if (stocks.isEmpty) return [];
    // int period = 50;
    //calculate multiplier for example 10 days would be 0.1818...
    double multiplier = 2 / (period + 1);
    // store the first EMA value as the day's currentMarketPrice
    List<Point> indicators = [
      Point(stocks.first.currentMarketPrice, stocks.first.timestamp),
    ];
    for (int i = 1; i < stocks.length; i++) {
      //https://school.stockcharts.com/doku.php?id=technical_indicators:moving_averages for manual calculation
      //multiplier dependent on the number of stocks
      double currentEMA = ((stocks[i].currentMarketPrice - indicators[i - 1].value) * multiplier) + indicators[i - 1].value;
      indicators.add(Point(currentEMA, stocks[i].timestamp));
    }
    return indicators;

    // List<Point> emaPrices =  new List.filled(stocks.length, Point(stocks.first.currentMarketPrice, stocks.first.timestamp), growable: true);
    //
    // for (int i = (period - 1); i < stocks.length; i++) {
    //   List<Stock> periodSlice = [];
    //   for (int j = 0; j < i + 1; j ++) {
    //     debugPrint("CURRENT INDEX J: " + j.toString());
    //     periodSlice.add(stocks[j]);
    //   }
    //   List<Point> smaPrices = new SMA().compute(periodSlice);
    //   double emaPrice;
    //   if (i == (period - 1)) {
    //     emaPrice = smaPrices[i].value;
    //     emaPrices.add(Point(emaPrice, stocks[i].timestamp));
    //   } else  if (i > (period - 1)) {
    //     emaPrices[i] = Point((stocks[i].currentMarketPrice - emaPrices[i - 1].value) * multiplier + emaPrices[i - 1].value, stocks[i].timestamp);
    //     // emaPrice = (stocks[i].currentMarketPrice - emaPrices[i - 1].value) * multiplier + emaPrices[i - 1].value;
    //     // emaPrices.add(Point(emaPrice, stocks[i].timestamp));
    //   }
    // }
    //
    // return emaPrices;

  }
}
import 'package:financial_systems_coursework/model/Point.dart';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:financial_systems_coursework/model/formulae/Formulae.dart';
import 'package:financial_systems_coursework/model/formulae/MACD.dart';

import 'EMA.dart';

class MACDAVG implements Formulae {
  // TODO: Implement formula
  @override
  List<Point> compute(List<Stock> stocks, int period) {
    if (stocks.isEmpty) return [];

    MACD macd =  new MACD();
    // int period = 26;
    List<Point> macdPoints = macd.compute(stocks, period);
    //calculate multiplier for example 10 days would be 0.1818...
    double signalMultiplier = 2 / (9 + 1);
    //store the first EMA value as the day's currentMarketPrice
    List<Point> indicators = [Point(macdPoints.first.value, macdPoints.first.timestamp),
    ];

    List<Stock> macdStocks = this.pointsToStocks(macdPoints, stocks.first.symbol);

    List<Point> signalEma = new EMA().compute(macdStocks, 9);

    for (int i = 0; i < macdPoints.length; i++) {
      //multiplier dependent on the number of stocks
      // double ema = ((macdPoints[i].value - macdPoints[i - 1].value) * signalMultiplier) + macdPoints[i - 1].value;
      indicators.add(Point((macdPoints[i].value - signalEma[i].value), macdPoints[i].timestamp));
    }
    indicators.removeAt(0);
    return indicators;
  }

  List<Stock> pointsToStocks(List<Point> points, String symbol) {
    List<Stock> stocks = List.empty(growable: true);
    for (int i = 0; i < points.length; i ++) {
      stocks.add(Stock(symbol, points[i].timestamp, points[i].value));
    }

    return stocks;
  }
}

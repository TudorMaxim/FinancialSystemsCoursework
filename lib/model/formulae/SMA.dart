import 'package:financial_systems_coursework/model/Point.dart';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:financial_systems_coursework/model/formulae/Formulae.dart';

class SMA implements Formulae {
  @override
  List<Point> compute(List<Stock> stocks) {
    if (stocks.isEmpty) return [];
    List<Point> indicators = [
      Point(stocks.first.currentMarketPrice, stocks.first.timestamp),
    ];
    for (int i = 1; i < stocks.length; i++) {
      double currentSMA = ((indicators[i - 1].value * i) + stocks[i].currentMarketPrice) / (i + 1);
      indicators.add(Point(currentSMA, stocks[i].timestamp));
    }
    return indicators;
  }
}

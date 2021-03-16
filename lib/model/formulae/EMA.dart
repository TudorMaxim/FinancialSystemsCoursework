import 'package:financial_systems_coursework/model/Point.dart';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:financial_systems_coursework/model/formulae/Formulae.dart';

class EMA implements Formulae {
  @override
  List<Point> compute(List<Stock> stocks) {
    if (stocks.isEmpty) return [];
    //calculate multiplier for example 10 days would be 0.1818...
    double multiplier = 2 / (stocks.length + 1);
    //store the first EMA value as the day's currentMarketPrice
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
  }
}
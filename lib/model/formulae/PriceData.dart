import './Formulae.dart';
import '../Point.dart';
import '../Stock.dart';

class PriceData implements Formulae {
  @override
  List<Point> compute(List<Stock> stocks, int period, int startIndex) {
    return stocks.map((stock) => Point(stock.currentMarketPrice, stock.timestamp)).toList().sublist(startIndex);
  }
}

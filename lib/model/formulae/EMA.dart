import 'package:financial_systems_coursework/model/Point.dart';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:financial_systems_coursework/model/formulae/Formulae.dart';

class EMA implements Formulae {
  // TODO: Implement formula
  @override
  List<Point> compute(List<Stock> stocks) {
    return stocks.map((stock) => Point(stock.currentMarketPrice, stock.timestamp)).toList();
  }
}

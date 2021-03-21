import '../Stock.dart';
import '../Point.dart';

abstract class Formulae {
  List<Point> compute(List<Stock> stocks, int period, int startDate);
}

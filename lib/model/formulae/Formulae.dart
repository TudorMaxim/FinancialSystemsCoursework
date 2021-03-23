import '../Stock.dart';
import '../Point.dart';

abstract class Formulae {
  static final String periodError =
      'Period must be smaller than the number of stocks';

  List<Point> compute(List<Stock> stocks, int period, int startDate);
}

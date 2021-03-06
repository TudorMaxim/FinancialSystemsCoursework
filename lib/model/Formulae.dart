import 'Stock.dart';

class Formulae {
  List<Stock> stocks;

  Formulae({this.stocks});

  List<Stock> getStocks() {
    return this.stocks;
  }

  void setStocks(List<Stock> stocks) {
    this.stocks = stocks;
  }

  // TO BE IMPLEMENTED BY THISH
  List<double> SMA() {

  }

  // TO BE IMPLEMENTED BY THISH
  List<double> EMA() {

  }

  // TO BE IMPLEMENTED BY TEOFANA
  List<double> MACD() {

  }

  // TO BE IMPLEMENTED BY HORIA
  List<double> MACDAVG() {

  }
}
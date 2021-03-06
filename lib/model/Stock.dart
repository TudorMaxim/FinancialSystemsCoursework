class Stock {
  String symbol;
  int timestamp;
  double currentMarketPrice;

  Stock({this.symbol, this.timestamp, this.currentMarketPrice});

  String getSymbol() {
    return this.symbol;
  }

  int getTimeStamp() {
    return this.timestamp;
  }

  double getCurrentMarketPrice() {
    return this.currentMarketPrice;
  }

  void setSymbol(String symbol) {
    this.symbol = symbol;
  }

  void setTimestamp(int timestamp) {
    this.timestamp = timestamp;
  }

  void setCurrentMarketPrice(double currentMarketPrice) {
    this.currentMarketPrice = currentMarketPrice;
  }
}
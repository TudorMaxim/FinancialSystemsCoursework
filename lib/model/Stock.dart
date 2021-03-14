class Stock {
  String symbol;
  int timestamp;
  double currentMarketPrice;

  Stock(String symbol, int timestamp, double currentMarketPrice) {
    this.symbol = symbol;
    this.timestamp = timestamp;
    this.currentMarketPrice = currentMarketPrice;
  }

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
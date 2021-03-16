class Stock {
  String symbol;
  int timestamp;
  double currentMarketPrice;

  Stock({this.symbol, this.timestamp, this.currentMarketPrice});

  Stock.fromMap(Map<String, dynamic> map) {
    this.symbol = map['symbol'];
    this.timestamp = map['timestamp'];
    this.currentMarketPrice = map['currentMarketPrice'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'symbol': this.symbol,
      'timestamp': this.timestamp,
      'currentMarketPrice': this.currentMarketPrice
    };
    return map;
  }

  /**
   * Create stock objects from collected data.
   *
   * Take closing price of each day.
   */
  static List<Stock> jsonToStocks(String symbol, dynamic jsonObject) {
    List<int> timestamps = (jsonObject['chart']['result'][0]['timestamp']
            as List)
        .cast<int>()
        .map((timestamp) =>
            timestamp * 1000) // convert timestamps to millisecondsSinceEpoch.
        .toList();
    List<double> prices = (jsonObject['chart']['result'][0]['indicators']
            ['quote'][0]['close'] as List)
        .cast<double>()
        .toList();

    List<Stock> stockList = List.empty(growable: true);

    for (int i = 0; i < timestamps.length; ++i) {
      stockList.add(Stock(
          symbol: symbol,
          timestamp: timestamps[i],
          currentMarketPrice: prices[i]));
    }

    return stockList;
  }
}

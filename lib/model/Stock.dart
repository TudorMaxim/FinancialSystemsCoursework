class Stock {
  String ticker;
  int timestamp;
  double currentMarketPrice;

  Stock({this.ticker, this.timestamp, this.currentMarketPrice});

  Stock.fromMap(Map<String, dynamic> map) {
    this.ticker = map['ticker'];
    this.timestamp = map['timestamp'];
    this.currentMarketPrice = map['currentMarketPrice'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'ticker': this.ticker,
      'timestamp': this.timestamp,
      'currentMarketPrice': this.currentMarketPrice
    };
    return map;
  }

  @override
  String toString() {
    return '$ticker at $currentMarketPrice on $timestamp';
  }

  /**
   * Create stock objects from collected data.
   *
   * Take closing price of each day.
   */
  static List<Stock> jsonToStocks(
      String ticker, Map<String, dynamic> jsonObject) {
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
      if (prices[i] != null) {
        stockList.add(Stock(
            ticker: ticker,
            timestamp: timestamps[i],
            currentMarketPrice: prices[i]));
      }
    }

    return stockList;
  }
}

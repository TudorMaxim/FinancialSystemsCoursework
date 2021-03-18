enum StockInterval { i1h, i1d, i5d, i1wk, i1mo, i3mo }

extension IntervalMapping on StockInterval {
  String get name {
    switch (this) {
      case StockInterval.i1h:
        return '1h';
      case StockInterval.i1d:
        return '1d';
      case StockInterval.i5d:
        return '5d';
      case StockInterval.i1wk:
        return '1wk';
      case StockInterval.i1mo:
        return '1mo';
      case StockInterval.i3mo:
        return '3mo';
      default:
        return 'Invalid Interval';
    }
  }

  static List<String> stringList() {
    return ['1h', '1d', '5d', '1wk', '1mo', '3mo'];
  }

  static StockInterval fromString(String s) {
    switch (s) {
      case '1h':
        return StockInterval.i1h;
      case '1d':
        return StockInterval.i1d;
      case '5d':
        return StockInterval.i5d;
      case '1wk':
        return StockInterval.i1wk;
      case '1mo':
        return StockInterval.i1mo;
      case '3mo':
        return StockInterval.i3mo;
      default:
        return null;
    }
  }
}

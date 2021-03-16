import 'package:financial_systems_coursework/repository/StockDataCollector.dart';
import 'package:financial_systems_coursework/repository/SymbolManager.dart';
import 'package:financial_systems_coursework/screens/DetailsScreen.dart';
import 'package:financial_systems_coursework/shared/AppBaseState.dart';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:financial_systems_coursework/widgets/DateRangeSelector.dart';
import 'package:financial_systems_coursework/widgets/SelectForm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final String title;
  MainScreen({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MainScreenState();
}

class MainScreenState extends AppBaseState<MainScreen> {
  String _symbol;
  String _interval;
  List<DateTime> _dates;

  void initState() {
    super.initState();
    _symbol = '';
    _interval = '';
    _dates = _getInitRange();
  }

  List<DateTime> _getInitRange() {
    return [DateTime.now().subtract(Duration(days: 5)), DateTime.now()];
  }

  void handlePress(BuildContext context) async {
    if (!connected) {
      showAlertDialog(
          context, 'Error',
          'Could not fetch data about $_symbol!\nPlease check your internet connection!'
      );
    }
    else if (_getFABStatus()) {
      String _startStamp =
          (_dates.first.millisecondsSinceEpoch ~/ 1000).toString();
      String _endStamp =
          (_dates.last.millisecondsSinceEpoch ~/ 1000).toString();
      List<Stock> _stocks = await StockDataCollector().getPrices(
          _symbol.trim(), _startStamp, _endStamp, _interval);

      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) =>
                DetailsScreen(title: 'Stock Details', stocks: _stocks)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select the symbol, interval and a valid date range'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  _handleSymbolSubmit(String symbol) {
    this.setState(() {
      _symbol = symbol;
    });
  }

  _handleIntervalSubmit(String interval) {
    this.setState(() {
      _interval = interval;
    });
  }

  _handleDateSubmit(List<DateTime> dates) {
    this.setState(() {
      _dates = dates;
    });
  }

  bool _getFABStatus() {
    return _symbol != '' && _dates != null && _dates.length == 2 && _interval != '';
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        bottom: PreferredSize(
          child: Text(
            getConnectionString(),
            style: TextStyle(color: Colors.red),
          ),
          preferredSize: Size.fromHeight(0),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Wrap(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 3.0,
                        ),
                        borderRadius: BorderRadius.circular(6.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            SelectForm(
                              fieldName: 'Symbol',
                              values: SymbolManager().symbols,
                              handleSubmit: _handleSymbolSubmit,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 6.0),
                              child: Text('Current Symbol: $_symbol'),
                            ),
                            SelectForm(
                              fieldName: 'Interval',
                              values: Future<List<String>>.value(
                                  ['1h', '1d', '5d', '1wk', '1mo', '3mo']
                              ),
                              handleSubmit: _handleIntervalSubmit,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 6.0),
                              child: Text('Current Interval: $_interval'),
                            ),
                            DateRangeSelector(_dates, _handleDateSubmit),
                          ],
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor:
              _getFABStatus() ? Theme.of(context).primaryColor : Colors.grey,
          onPressed: () => this.handlePress(context),
          label: Text('Load Data'),
          icon: Icon(Icons.add)),
    );
  }
}

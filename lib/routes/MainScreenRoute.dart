import 'dart:core';

import 'package:financial_systems_coursework/repository/StockDataProvider.dart';
import 'package:financial_systems_coursework/repository/TickerManager.dart';
import 'package:financial_systems_coursework/routes/DetailsScreenRoute.dart';
import 'package:financial_systems_coursework/shared/AppBaseState.dart';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:financial_systems_coursework/widgets/DateRangeSelector.dart';
import 'package:financial_systems_coursework/widgets/InlineBold.dart';
import 'package:financial_systems_coursework/widgets/SelectForm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainScreenRoute extends StatefulWidget {
  static final routeName = '/';
  final String title = 'Select Stock';
  MainScreenRoute({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MainScreenRouteState();
}

class MainScreenRouteState extends AppBaseState<MainScreenRoute> {
  String _ticker;
  String _period;
  List<DateTime> _dates;

  static final String _alertTitle = 'Error';
  static final String _alertCheckInternet1 = 'Could not fetch data about ';
  static final String _alertCheckInternet2 =
      '\nPlease check your internet connection!';
  static final String _validatePeriodError =
      'Not enough stocks for the selected date range!';
  static final String _invalidInputError =
      'Please select the ticker, indicator period and a valid date range!';
  static final String _notEnoughData =
      'No data points in your selected date range!';

  static final String _tickerField = 'Ticker';
  static final String _periodField = 'Period';
  static final String _currentTicker = 'Current Ticker: ';
  static final String _indicatorPeriod = 'Indicator Period: ';
  static final String _loadData = 'Load Data';

  static final List<String> _periods = [
    '12d',
    '26d',
    '35d',
    '50d',
    '100d',
    '150d'
  ];
  static final int _periodMarginError = 42;
  static final int _initRangeDays = 5;

  void initState() {
    super.initState();
    _ticker = '';
    _period = '';
    _dates = _getInitRange();
  }

  /// Set a standard DateRange when first building the widget.
  List<DateTime> _getInitRange() {
    return [
      DateTime.now().subtract(Duration(days: _initRangeDays)),
      DateTime.now()
    ];
  }

  /// Check against invalid input,
  /// fetch StockData from DB or Yahoo!
  /// then push the DetailsScreen.
  void handleFABPress(BuildContext context) async {
    if (!connected) {
      showAlertDialog(context, _alertTitle,
          _alertCheckInternet1 + _ticker + _alertCheckInternet2);
      return;
    }
    if (!_getFABStatus()) {
      // Something went wrong, so let's see what, throw an appropiate error,
      // then return.
      if (!_validatePeriodLength()) {
        // User provided valid input, but the DateRange doesn't match our tolerances.
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_validatePeriodError),
          duration: Duration(seconds: 2),
        ));
      } else {
        // The user has provided invalid input
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_invalidInputError),
          duration: Duration(seconds: 2),
        ));
      }

      return;
    }

    // there is no data for weekend or for some days
    // hence we need to pull more data to be sure that we got enough to cover the previous period
    final DateTime startDatePeriod = _dates.first.subtract(Duration(
        days: int.parse(_period.substring(0, _period.length - 1)) +
            _periodMarginError));

    final DateTime _startMidnight =
        DateTime(_dates.first.year, _dates.first.month, _dates.first.day, 0, 1);
    final DateTime _endMidnight =
        DateTime(_dates.last.year, _dates.last.month, _dates.last.day, 23, 59);
    final DateTime _periodPullingDate = DateTime(
        startDatePeriod.year, startDatePeriod.month, startDatePeriod.day, 0, 1);

    final int _startStamp = (_periodPullingDate.millisecondsSinceEpoch ~/ 1000);
    final int _endStamp = (_endMidnight.millisecondsSinceEpoch ~/ 1000);

    List<Stock> _stocks = await StockDataProvider()
        .getPrices(_ticker.trim(), _startStamp, _endStamp);
    debugPrint('Found ${_stocks.length} stocks.');

    if (_stocks != null && _stocks.length != 0) {
      Navigator.of(context).pushNamed(DetailsScreenRoute.routeName,
          arguments: DetailsScreenArguments(_period, _stocks, _startMidnight));
    } else {
      // User input was fine but we couldn't get enough data to display graphs.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_notEnoughData),
        duration: Duration(seconds: 2),
      ));
    }
  }

  _handleTickerSubmit(String ticker) {
    this.setState(() {
      _ticker = ticker;
    });
  }

  _handlePeriodSubmit(String period) {
    this.setState(() {
      _period = period;
    });
  }

  _handleDateSubmit(List<DateTime> dates) {
    this.setState(() {
      _dates = dates;
    });
  }

  /// Return true if and only if user has provided valid input
  /// and StockData can be loaded.
  bool _getFABStatus() {
    return _ticker != '' &&
        _dates != null &&
        _dates.length == 2 &&
        _period != '' &&
        _validatePeriodLength();
  }

  bool _validatePeriodLength() {
    return _dates.last.difference(_dates.first).inDays >=
        int.parse(_period.substring(0, _period.length - 1));
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
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
              Colors.blue[800],
              Colors.lightBlue[100],
            ])),
        child: Padding(
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
                            color: Colors.blueGrey[100],
                            width: 3.0,
                          ),
                          borderRadius: BorderRadius.circular(6.0),
                          color: Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            SelectForm(
                              fieldName: _tickerField,
                              values: TickerManager().tickers,
                              handleSubmit: _handleTickerSubmit,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 10.0),
                              child: InlineBold(_currentTicker, _ticker),
                            ),
                            SelectForm(
                              fieldName: _periodField,
                              values: Future<List<String>>.value(_periods),
                              handleSubmit: _handlePeriodSubmit,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 10.0),
                              child: InlineBold(_indicatorPeriod, _period),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor:
              _getFABStatus() ? Theme.of(context).primaryColor : Colors.grey,
          onPressed: () => this.handleFABPress(context),
          label: Text(_loadData),
          icon: Icon(Icons.add)),
    );
  }
}

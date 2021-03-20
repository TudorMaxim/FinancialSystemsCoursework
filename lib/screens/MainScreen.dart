import 'dart:core';

import 'package:financial_systems_coursework/repository/StockDataProvider.dart';
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
  String _period;
  List<DateTime> _dates;

  void initState() {
    super.initState();
    _symbol = '';
    _period = '';
    _dates = _getInitRange();
  }

  List<DateTime> _getInitRange() {
    return [DateTime.now().subtract(Duration(days: 5)), DateTime.now()];
  }

  void handlePress(BuildContext context) async {
    if (!connected) {
      showAlertDialog(context, 'Error',
          'Could not fetch data about $_symbol!\nPlease check your internet connection!');
    } else if (_getFABStatus()) {
        // there is no data for weekend or for some days
        // hence we need to pull more data to be sure that we got enough to cover the previous period
        int periodMarginError = 42;
        final DateTime startDatePeriod = _dates.first.subtract(Duration(days: int.parse(_period.substring(0, _period.length - 1)) + periodMarginError));

        final DateTime _startMidnight = DateTime(
            _dates.first.year, _dates.first.month, _dates.first.day, 0, 1);
        final DateTime _endMidnight = DateTime(
            _dates.last.year, _dates.last.month, _dates.last.day, 23, 59);
        final DateTime _periodPullingDate = DateTime(
            startDatePeriod.year, startDatePeriod.month, startDatePeriod.day, 0, 1);

        final int _startStamp = (_periodPullingDate.millisecondsSinceEpoch ~/ 1000);
        final int _endStamp = (_endMidnight.millisecondsSinceEpoch ~/ 1000);

        List<Stock> _stocks = await StockDataProvider()
            .getPrices(_symbol.trim(), _startStamp, _endStamp);
        debugPrint('Found ${_stocks.length} stocks.');
        if (_stocks != null && _stocks.length != 0) {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) =>
                    DetailsScreen(title: 'Stock Details',
                        stocks: _stocks,
                        period: _period,
                        startDate: _startMidnight)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
            Text('No data points in your selected date range!'),
            duration: Duration(seconds: 2),
          ));
        }
    } else {
      if (!_validatePeriodLength()) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
          Text('Not enough stocks for the selected date range!'),
          duration: Duration(seconds: 2),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
          Text(
              'Please select the symbol, indicator period and a valid date range'),
          duration: Duration(seconds: 2),
        ));
      }
    }
  }

  _handleSymbolSubmit(String symbol) {
    this.setState(() {
      _symbol = symbol;
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

  bool _getFABStatus() {
    return _symbol != '' && _dates != null && _dates.length == 2 && _period != '' && _validatePeriodLength();
  }

  bool _validatePeriodLength() {
    return _dates.last.difference(_dates.first).inDays >= int.parse(_period.substring(0, _period.length - 1));
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
                              fieldName: 'Period',
                              values: Future<List<String>>.value(
                                  ['12d', '26d', '35d', '50d', '100d', '150d']
                              ),
                              handleSubmit: _handlePeriodSubmit,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 6.0),
                              child: Text('Indicator Period: $_period'),
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

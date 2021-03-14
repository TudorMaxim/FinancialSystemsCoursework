import 'package:financial_systems_coursework/repository/StockDataCollector.dart';
import 'package:financial_systems_coursework/screens/DetailsScreen.dart';
import 'package:financial_systems_coursework/shared/AppBaseState.dart';
import 'package:financial_systems_coursework/repository/TickerManager.dart';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class MainScreen extends StatefulWidget {
  final String title;
  MainScreen({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MainScreenState();
}

class MainScreenState extends AppBaseState<MainScreen> {
  String _ticker;
  List<DateTime> _dates;

  void initState() {
    super.initState();
    _ticker = '';
    _dates = _getInitRange();
  }

  List<DateTime> _getInitRange() {
    return [DateTime.now().subtract(Duration(days: 5)), DateTime.now()];
  }

  void handlePress(BuildContext context) async {
    if (_getFABStatus()) {
      String _startStamp =
          (_dates.first.millisecondsSinceEpoch ~/ 1000).toString();
      String _endStamp =
          (_dates.last.millisecondsSinceEpoch ~/ 1000).toString();
      List<Stock> _stocks = await StockDataCollector.getPrices(
          _ticker.trim(), _startStamp, _endStamp);
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) =>
                DetailsScreen(title: 'Stock Details', stocks: _stocks)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select ticker and valid date range'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  _handleTickerSubmit(String ticker) {
    this.setState(() {
      _ticker = ticker;
    });
  }

  _handleDateSubmit(List<DateTime> dates) {
    this.setState(() {
      _dates = dates;
    });
  }

  bool _getFABStatus() {
    return _ticker != '' && _dates != null && _dates.length == 2;
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
                          TickerSelectForm(_handleTickerSubmit),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 6.0),
                            child: Text('Current Ticker: $_ticker'),
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

class TickerSelectForm extends StatefulWidget {
  final Function _handleTickerSubmit;

  TickerSelectForm(this._handleTickerSubmit);

  @override
  _TickerSelectFormState createState() => _TickerSelectFormState();
}

class _TickerSelectFormState extends State<TickerSelectForm> {
  final TextEditingController _ctr = TextEditingController();
  String _ticker = "";

  @override
  void initState() {
    super.initState();
    _ctr.text = _ticker;
  }

  _onSuggestionSelected(String suggestion, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Ticker $suggestion selected'),
      duration: Duration(seconds: 2),
    ));
    widget._handleTickerSubmit(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    final Future<List<String>> _fs = TickerManager().tickers;
    return Center(
        child: FutureBuilder(
      future: _fs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final List<String> _tickers = snapshot.data;
          return TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
                controller: _ctr,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Ticker')),
            suggestionsCallback: (pattern) =>
                TickerManager().filterSuggestions(pattern, _tickers),
            itemBuilder: (context, suggestion) => ListTile(
              title: Text(suggestion),
            ),
            onSuggestionSelected: (suggestion) {
              _ticker = suggestion;
              _ctr.text = suggestion;
              _onSuggestionSelected(suggestion, context);
            },
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    ));
  }
}

class DateRangeSelector extends StatefulWidget {
  final Function _handleDateSubmit;
  final List<DateTime> _initDates;

  DateRangeSelector(this._initDates, this._handleDateSubmit);

  @override
  _DateRangeSelectorState createState() =>
      _DateRangeSelectorState(_initDates, _handleDateSubmit);
}

class _DateRangeSelectorState extends State<DateRangeSelector> {
  final Function _handleDateSubmit;
  List<DateTime> _dates;
  bool _err = false;

  _DateRangeSelectorState(this._dates, this._handleDateSubmit);

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    final PickerDateRange _r = args.value;
    if (_r.startDate != null && _r.endDate != null) {
      this.setState(() {
        _dates = [_r.startDate, _r.endDate];
      });
    }
  }

  void _handleDateAlertSubmit(BuildContext context) {
    Navigator.of(context).pop();
    if (_dates != null && _dates.first != null && _dates.last != null) {
      if (_dates.last
              .difference(_dates.first)
              .compareTo(Duration(days: 365 * 2)) ==
          1) {
        debugPrint('Range larger than 2 years selected!');
        this.setState(() {
          _err = true;
          _handleDateSubmit(null);
        });
      } else {
        this.setState(() {
          _handleDateSubmit(_dates);
          _err = false;
        });
      }
    } else {
      debugPrint('Incorrect dates selected');
      this.setState(() {
        _err = true;
        _handleDateSubmit(null);
      });
    }
  }

  void _onShowDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Pick date range'),
            content: Container(
              width: MediaQuery.of(context).size.width - 10,
              height: MediaQuery.of(context).size.height / 2,
              child: SfDateRangePicker(
                selectionMode: DateRangePickerSelectionMode.range,
                onSelectionChanged: _onSelectionChanged,
                minDate: DateTime.now().subtract(Duration(days: 365 * 5)),
                maxDate: DateTime.now(),
                initialSelectedRange:
                    PickerDateRange(_dates.first, _dates.last),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('CANCEL')),
              TextButton(
                  onPressed: () => _handleDateAlertSubmit(context),
                  child: Text('OK'))
            ],
            elevation: 24.0,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final int _durr = _dates.last.difference(_dates.first).inDays;
    return Container(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => _onShowDialog(context),
            child: Text('Pick Date Range'),
          ),
          VerticalDivider(
            width: 12.0,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Text('Start: ${DateFormat.yMd().format(_dates.first)}'),
          ),
          VerticalDivider(
            width: 12.0,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Text('End: ${DateFormat.yMd().format(_dates.last)}'),
          ),
          VerticalDivider(
            width: 12.0,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Text('$_durr days currently selected'),
          ),
          VerticalDivider(
            width: 12.0,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Text(
              _err
                  ? 'Please select a valid date range!\n(less then two years)'
                  : '',
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}

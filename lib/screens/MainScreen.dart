import 'package:financial_systems_coursework/repository/StockDataCollector.dart';
import 'package:financial_systems_coursework/screens/DetailsScreen.dart';
import 'package:financial_systems_coursework/shared/AppBaseState.dart';
import 'package:financial_systems_coursework/repository/TickerManager.dart';
import 'package:financial_systems_coursework/model/Stock.dart';

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

  void handlePress(BuildContext context) async {
    if(_ticker != null && _dates != null) {
      String _startStamp = (_dates.first.millisecondsSinceEpoch ~/ 1000).toString();
      String _endStamp = (_dates.last.millisecondsSinceEpoch ~/ 1000).toString();
      debugPrint('$_startStamp - $_endStamp');
      List<Stock> _stocks = await StockDataCollector.getPrices(_ticker.trim(), _startStamp, _endStamp);
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) =>
                DetailsScreen(
                  title: 'Stock Details',
                  stocks: _stocks
                )),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select ticker and date range'),
          duration: Duration(seconds: 2),));
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
        child: Column(
          children: [
            TickerSelectForm(_handleTickerSubmit),
            Divider(height: 12.0,),
            DateRangeSelector(_handleDateSubmit),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => this.handlePress(context),
          label: Text('Load Data'),
          icon: Icon(Icons.add)),
    );
  }
}

class TickerSelectForm extends StatelessWidget {
  final Function _handleTickerSubmit;

  TickerSelectForm(this._handleTickerSubmit);

  _onSuggestionSelected(String suggestion, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Ticker $suggestion selected'),
      duration: Duration(seconds: 2),
    ));
    _handleTickerSubmit(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    final Future<List<String>> _fs = TickerManager().tickers;
    return Center(
        // TODO: add stock fetching form
        child: FutureBuilder(
      future: _fs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final List<String> _tickers = snapshot.data;
          return TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Ticker'
                )
            ),
            suggestionsCallback: (pattern) =>
                TickerManager().filterSuggestions(pattern, _tickers),
            itemBuilder: (context, suggestion) => ListTile(
              title: Text(suggestion),
            ),
            onSuggestionSelected: (suggestion) =>
                _onSuggestionSelected(suggestion, context),
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
  DateRangeSelector(this._handleDateSubmit);

  @override
  _DateRangeSelectorState createState() => _DateRangeSelectorState(_handleDateSubmit);
}

class _DateRangeSelectorState extends State<DateRangeSelector> {
  final Function _handleDateSubmit;
  List<DateTime> _dates;

  _DateRangeSelectorState(this._handleDateSubmit);

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    final PickerDateRange _r = args.value;
    this.setState(() {
      _dates = [_r.startDate, _r.endDate];
    });
  }

  void _handleDateAlertSubmit(BuildContext context) {
    Navigator.of(context).pop();
    if (_dates != null && _dates.first != null && _dates.last != null) {
      _handleDateSubmit(_dates);
    } else {
      debugPrint('Incorrect dates selected');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
      Text('Please select a valid date range!')));
    }
  }

  PickerDateRange _getInitRange() {
    if(_dates != null && _dates.first != null && _dates.last != null) {
      return PickerDateRange(_dates.first, _dates.last);
    } else {
      return PickerDateRange(DateTime.now().subtract(Duration(days: 5)),
          DateTime.now());
    }
  }

  void _onShowDialog(BuildContext context) {
    showDialog(context: context, builder: (context) {
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
            initialSelectedRange: _getInitRange(),
          ),
        ) ,
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(),
              child: Text('CANCEL')),
          TextButton(onPressed: () => _handleDateAlertSubmit(context),
              child: Text('OK'))
        ],
        elevation: 24.0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(onPressed: () => _onShowDialog(context),
          child: Text('Pick Date Range'),
      ),

    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'package:financial_systems_coursework/widgets/InlineBold.dart';

class DateRangeSelector extends StatefulWidget {
  final Function _handleDateSubmit;
  final List<DateTime> _initDates;

  DateRangeSelector(this._initDates, this._handleDateSubmit);

  @override
  _DateRangeSelectorState createState() =>
      _DateRangeSelectorState(_initDates, _handleDateSubmit);
}

class _DateRangeSelectorState extends State<DateRangeSelector> {
  static final String _pickerTitle = 'Pick Date Range';
  static final String _ok = 'OK';
  static final String _cancel = 'CANCEL';
  static final String _start = 'Start: ';
  static final String _end = 'End: ';
  static final String _daysSelected = 'Days Selcted: ';
  static final String _selectErrorMessage =
      'Please select a valid date range!\n(less then two years)';

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
            title: Text(_pickerTitle),
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
                  child: Text(_cancel)),
              TextButton(
                  onPressed: () => _handleDateAlertSubmit(context),
                  child: Text(_ok))
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
            child: Text(_pickerTitle),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: InlineBold(_start, DateFormat.yMd().format(_dates.first)),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: InlineBold(_end, DateFormat.yMd().format(_dates.last)),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: InlineBold(_daysSelected, '$_durr'),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Text(
              _err ? _selectErrorMessage : '',
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}

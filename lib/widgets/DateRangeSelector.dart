import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

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

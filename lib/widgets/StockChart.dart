import 'package:financial_systems_coursework/model/Point.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class StockChart extends StatefulWidget {
  final List<charts.Series<Point, DateTime>> seriesList;
  final String ticker;
  final bool animate;

  StockChart({Key key, this.seriesList, this.ticker, this.animate})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => StockChartState();

  static charts.Series<Point, DateTime> generateSeries(
    String id,
    List<Point> data,
  ) =>
      charts.Series<Point, DateTime>(
        id: id,
        domainFn: (Point p, _) =>
            DateTime.fromMillisecondsSinceEpoch(p.timestamp).toUtc(),
        measureFn: (Point p, _) => p.value,
        data: data,
      );
}

class StockChartState extends State<StockChart> {
  Map<String, String> _info = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> latestInfo = _getLatestInfo();
    if (!listEquals(_getSortedKeys(_info), _getSortedKeys(latestInfo))) {
      setState(() {
        _info = latestInfo;
      });
    }

    return Stack(
      children: [
        charts.TimeSeriesChart(
          widget.seriesList,
          animate: false,
          dateTimeFactory: const charts.LocalDateTimeFactory(),
          primaryMeasureAxis: charts.NumericAxisSpec(
            tickProviderSpec:
                charts.BasicNumericTickProviderSpec(zeroBound: false),
            tickFormatterSpec:
                charts.BasicNumericTickFormatterSpec((value) => '\$$value'),
          ),
          behaviors: [
            charts.PanAndZoomBehavior(),
            charts.SeriesLegend(position: charts.BehaviorPosition.bottom),
            charts.LinePointHighlighter(
                symbolRenderer:
                    charts.CircleSymbolRenderer() // add this line in behaviours
                ),
            charts.ChartTitle(
              widget.ticker,
              behaviorPosition: charts.BehaviorPosition.top,
              titleOutsideJustification: charts.OutsideJustification.start,
              innerPadding: 40,
              titleStyleSpec: charts.TextStyleSpec(
                color: charts.MaterialPalette.blue.shadeDefault,
                fontSize: 40,
                fontWeight: 'bold',
              ),
            ),
          ],
          selectionModels: [
            charts.SelectionModelConfig(
              type: charts.SelectionModelType.info,
              changedListener: _onSelectionChange,
            ),
          ],
        ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            padding: EdgeInsets.only(right: 20),
            height: 70,
            width: 200,
            child: ListView(
              children: _getSelectedValues(),
            ),
          ),
        )
      ],
    );
  }

  List<String> _getSortedKeys(Map<String, String> info) {
    List<String> keys = info.keys.where((key) => key != null).toList();
    keys.sort();
    return keys;
  }

  void _onSelectionChange(charts.SelectionModel model) {
    if (model.selectedDatum.isEmpty) return;
    Map<String, String> info = {};

    DateTime time = DateTime.fromMillisecondsSinceEpoch(
        model.selectedDatum.first.datum.timestamp);
    info['Date'] = DateFormat('dd-MMM-yyyy').format(time);
    info['Time'] = DateFormat('hh:mm a').format(time);
    model.selectedDatum.forEach((pair) {
      String key = pair.series.displayName;
      info[key] = '\$' + pair.datum.value.toStringAsFixed(2);
    });
    setState(() {
      _info = info;
    });
  }

  Map<String, String> _getLatestInfo() {
    Map<String, String> info = {};
    widget.seriesList.forEach((series) {
      List<Point> points = series.data;
      String key = series.id;
      if (points.isNotEmpty) {
        DateTime time =
            DateTime.fromMillisecondsSinceEpoch(points.last.timestamp);
        info['Date'] = DateFormat('dd-MMM-yyyy').format(time);
        info['Time'] = DateFormat('hh:mm a').format(time);
        info[key] = '\$' + points.last.value.toStringAsFixed(2);
      }
    });
    return info;
  }

  List<Widget> _getSelectedValues() {
    if (_info == null) return [];
    return _info.entries
        .map((entry) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(entry.key + ': ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue
                    ),
                  ),
                ),
                Expanded(
                  child: Text(entry.value,
                    textAlign: TextAlign.right,
                    style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                ),
              ],
            ))
        .toList();
  }
}

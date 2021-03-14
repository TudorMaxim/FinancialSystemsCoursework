import 'package:financial_systems_coursework/model/Point.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class StockChart extends StatefulWidget {
  final List<charts.Series> seriesList;
  Map<String, String> info;
  final String symbol;
  final bool animate;

  StockChart({this.seriesList, this.symbol, this.info, this.animate});

  @override
  State<StatefulWidget> createState() => StockChartState();

  static charts.Series<Point, DateTime> generateSeries(
      String id,
      List<Point> data,
      ) => charts.Series<Point, DateTime>(
    id: id,
    domainFn: (Point p, _) => DateTime.fromMillisecondsSinceEpoch(p.timestamp).toUtc(),
    measureFn: (Point p, _) => p.value,
    data: data,
  );
}

class StockChartState extends State<StockChart> {
  Map<String, String> _info = {};

  @override
  void initState() {
    super.initState();
    _info = widget.info;
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      charts.TimeSeriesChart(
        widget.seriesList,
        animate: false,
        dateTimeFactory: const charts.LocalDateTimeFactory(),
        defaultRenderer: new charts.LineRendererConfig(includePoints: false),
        primaryMeasureAxis: charts.NumericAxisSpec(
          tickProviderSpec: charts.BasicNumericTickProviderSpec(zeroBound: false),
          tickFormatterSpec: charts.BasicNumericTickFormatterSpec((value) => "\$$value"),
        ),
        behaviors: [
          charts.PanAndZoomBehavior(),
          charts.SeriesLegend(
              position: charts.BehaviorPosition.bottom
          ),
          charts.ChartTitle(widget.symbol,
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
            changedListener: this._onSelectionChange,
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
            children: this._getSelectedValues(),
          ),
        ),
      )
    ],
  );

    _onSelectionChange(charts.SelectionModel model) {
      if (model.selectedDatum.isEmpty) return;
      Map<String, String> info = {};
      DateTime time = DateTime.fromMillisecondsSinceEpoch(
          model.selectedDatum.first.datum.timestamp
      );
      info['Date'] = DateFormat('dd-MMM-yyyy').format(time);
      info['Time'] = DateFormat('hh:mm a').format(time);
      model.selectedDatum.forEach((pair) {
        info[pair.series.displayName] = '\$' + pair.datum.value.toStringAsFixed(2);
      });
      setState(() {
        this._info = info;
      });
    }

  List<Widget> _getSelectedValues() {
      if (this._info == null) return [];
      return this._info.entries
        .map((entry) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.key + ': ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue
                )
             ),
              Text(
                entry.value,
                textAlign: TextAlign.right,
                style: TextStyle(fontWeight: FontWeight.bold)
              ),
            ],
          )
        )
        .toList();
  }

}

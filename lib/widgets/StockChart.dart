import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:financial_systems_coursework/model/Point.dart';

class StockChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final String name;
  final bool animate;

  StockChart({this.seriesList, this.name, this.animate});

  @override
  Widget build(BuildContext context) => charts.TimeSeriesChart(
    seriesList,
    animate: false,
    dateTimeFactory: const charts.LocalDateTimeFactory(),
    defaultRenderer: new charts.LineRendererConfig(includePoints: true),
    behaviors: [
      charts.SeriesLegend(
          position: charts.BehaviorPosition.bottom
      ),
      charts.ChartTitle(this.name,
        behaviorPosition: charts.BehaviorPosition.top,
        titleOutsideJustification: charts.OutsideJustification.start,
        innerPadding: 30,
        titleStyleSpec: charts.TextStyleSpec(
          color: charts.MaterialPalette.blue.shadeDefault,
          fontSize: 30,
          fontWeight: 'bold',
        ),
      )
    ],
  );

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
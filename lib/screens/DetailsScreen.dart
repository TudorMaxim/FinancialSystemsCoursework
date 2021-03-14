import 'dart:math';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:financial_systems_coursework/model/GraphType.dart';
import 'package:financial_systems_coursework/model/Point.dart';
import 'package:financial_systems_coursework/shared/AppBaseState.dart';
import 'package:financial_systems_coursework/widgets/StockChart.dart';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DetailsScreen extends StatefulWidget {
  final String title;
  final List<Stock> stocks;
  final List<GraphType> graphTypes = [
    GraphType(name: 'USD Price Data', defaultSelected: true),
    GraphType(name: 'SMA', defaultSelected: true),
    GraphType(name: 'EMA', defaultSelected: false),
    GraphType(name: 'MACD', defaultSelected: false),
    GraphType(name: 'MACDAVG', defaultSelected: false),
  ];

  DetailsScreen({Key key, this.title, this.stocks}) : super(key: key);

  @override
  State<StatefulWidget> createState() => DetailsScreenState();
}

class DetailsScreenState extends AppBaseState<DetailsScreen> {
  Map<String, bool> selectedGraphTypes = {};

  @override
  void initState() {
    super.initState();
    setState(() {
      widget.graphTypes.forEach(
          (type) => (selectedGraphTypes[type.name] = type.defaultSelected));
    });
  }

  void handleSelectedChoices(String type) {
    List<String> selected = selectedGraphTypes.keys
        .where((type) => selectedGraphTypes[type])
        .toList();
    if (selected.length == 2 && !selected.contains(type)) {
      showAlertDialog(context, 'Error',
          'You may have only two graphs active at the same time');
    } else {
      setState(() {
        selectedGraphTypes[type] = !selectedGraphTypes[type];
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          actions: <Widget>[
            PopupMenuButton<String>(
                onSelected: handleSelectedChoices,
                itemBuilder: (BuildContext context) => widget.graphTypes
                    .map(
                      (type) => PopupMenuItem<String>(
                        value: type.name,
                        child: Container(
                          width: 120,
                          height: 50,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(0),
                            title: Text(type.name),
                            trailing: Icon(selectedGraphTypes[type.name]
                                ? Icons.check_circle
                                : Icons.check_circle_outline),
                          ),
                        ),
                      ),
                    )
                    .toList())
          ],
          bottom: PreferredSize(
            child: Text(
              getConnectionString(),
              style: TextStyle(color: Colors.red),
            ),
            preferredSize: Size.fromHeight(0),
          ),
        ),
        body: renderWithLoader(this.body()),
      );

  Widget body() => Center(
      child: Container(
        padding: EdgeInsets.all(10),
        child: StockChart(
          name: 'TSLA', // TODO: get stock name
          seriesList: this._getSeriesList(),
          animate: true,
        ),
      ));

  List<charts.Series<Point, DateTime>> _getSeriesList() {
    var mockData = [
      Point(10.0, DateTime.parse('2020-01-01').millisecondsSinceEpoch),
      Point(20.0, DateTime.parse('2020-02-01').millisecondsSinceEpoch),
      Point(15.0, DateTime.parse('2020-03-01').millisecondsSinceEpoch),
      Point(25.0, DateTime.parse('2020-04-01').millisecondsSinceEpoch),
      Point(30.0, DateTime.parse('2020-05-01').millisecondsSinceEpoch),
    ];
    List<charts.Series<Point, DateTime>> seriesList = [];
    Random random = Random();
    int maxVal = 5;
    this.selectedGraphTypes.keys.forEach((String key) {
      if (this.selectedGraphTypes[key]) {
        seriesList.add(StockChart.generateSeries(
          key,
          mockData
              .map((Point p) => Point(p.value + random.nextInt(maxVal), p.timestamp))
              .toList(),
        ));
      }
    });
    return seriesList;
  }
}

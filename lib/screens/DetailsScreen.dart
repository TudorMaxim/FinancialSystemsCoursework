import 'package:charts_flutter/flutter.dart' as charts;
import 'package:financial_systems_coursework/model/GraphType.dart';
import 'package:financial_systems_coursework/model/Point.dart';
import 'package:financial_systems_coursework/model/formulae/EMA.dart';
import 'package:financial_systems_coursework/model/formulae/MACD.dart';
import 'package:financial_systems_coursework/model/formulae/MACDAVG.dart';
import 'package:financial_systems_coursework/model/formulae/PriceData.dart';
import 'package:financial_systems_coursework/model/formulae/SMA.dart';
import 'package:financial_systems_coursework/shared/AppBaseState.dart';
import 'package:financial_systems_coursework/widgets/StockChart.dart';
import 'package:financial_systems_coursework/model/Stock.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DetailsScreenArguments {
  final String title;
  final String period;
  final List<Stock> stocks;
  final DateTime startDate;

  DetailsScreenArguments(this.title, this.period, this.stocks, this.startDate);
}

class DetailsScreenRoute extends StatelessWidget {
  static final routeName = '/details';

  @override
  Widget build(BuildContext context) {
    final DetailsScreenArguments args =
        ModalRoute.of(context).settings.arguments;

    return DetailsScreen(
      title: args.title,
      stocks: args.stocks,
      period: args.period,
      startDate: args.startDate,
    );
  }
}

class DetailsScreen extends StatefulWidget {
  final String title;
  final List<Stock> stocks;
  final String period;
  final DateTime startDate;
  final List<GraphType> graphTypes = [
    GraphType(name: 'USD Price', defaultSelected: true, formulae: PriceData()),
    GraphType(name: 'SMA', defaultSelected: true, formulae: SMA()),
    GraphType(name: 'EMA', defaultSelected: false, formulae: EMA()),
    GraphType(name: 'MACD', defaultSelected: false, formulae: MACD()),
    GraphType(name: 'MACDAVG', defaultSelected: false, formulae: MACDAVG()),
  ];

  DetailsScreen({Key key, this.title, this.stocks, this.period, this.startDate})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => DetailsScreenState();
}

class DetailsScreenState extends AppBaseState<DetailsScreen> {
  Map<String, bool> selectedGraphTypes = {};

  @override
  void initState() {
    super.initState();
    widget.graphTypes.forEach(
        (type) => (selectedGraphTypes[type.name] = type.defaultSelected));
  }

  void handleSelectedChoices(String type) {
    List<String> selected = selectedGraphTypes.keys
        .where((type) => selectedGraphTypes[type])
        .toList();
    if (selected.length == 2 && !selected.contains(type)) {
      showAlertDialog(context, 'Error',
          'You may have only two indicators visible at the same time');
    } else if (selected.length == 1 && selected.contains(type)) {
      showAlertDialog(context, 'Error',
          'You must have at least one indicator visible in the chart');
    } else {
      setState(() {
        selectedGraphTypes[type] = !selectedGraphTypes[type];
      });
    }
  }

  int computeStartingIndex() {
    int startIndex = 0;
    bool partialIndex = false;

    for (int i = 0; i <= widget.stocks.length - 1; i++) {
      if (DateTime.fromMillisecondsSinceEpoch(widget.stocks[i].timestamp)
              .toString()
              .substring(0, 10) ==
          widget.startDate.toString().substring(0, 10)) {
        startIndex = i;
      } else if (DateTime.fromMillisecondsSinceEpoch(widget.stocks[i].timestamp)
                  .toString()
                  .substring(0, 7) ==
              widget.startDate.toString().substring(0, 7) &&
          !partialIndex) {
        startIndex = i;
        partialIndex = true;
      }
    }

    return startIndex;
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
          ticker: widget.stocks.first.ticker,
          seriesList: this._getSeriesList(),
          animate: true,
        ),
      ));

  List<charts.Series<Point, DateTime>> _getSeriesList() => this
      .selectedGraphTypes
      .entries
      .where((entry) => entry.value)
      .map((entry) => StockChart.generateSeries(
          entry.key, this._mapStocksToPoints(entry.key)))
      .toList();

  List<Point> _mapStocksToPoints(String name) => widget.graphTypes
      .firstWhere((graphType) => graphType.name == name)
      .formulae
      .compute(
          widget.stocks,
          int.parse(widget.period.substring(0, widget.period.length - 1)),
          computeStartingIndex());
}

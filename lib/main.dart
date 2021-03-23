import 'package:financial_systems_coursework/routes/DetailsScreenRoute.dart';
import 'package:financial_systems_coursework/routes/MainScreenRoute.dart';
import 'package:flutter/material.dart';

void main() => runApp(StocksApp());

class StocksApp extends StatelessWidget {
  static final String _appTitle = 'Stocks App';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: MainScreenRoute.routeName,
      routes: {
        MainScreenRoute.routeName: (context) => MainScreenRoute(),
        DetailsScreenRoute.routeName: (context) => DetailsScreenRoute(),
      },
    );
  }
}

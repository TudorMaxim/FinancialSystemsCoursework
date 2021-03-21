import 'package:financial_systems_coursework/screens/DetailsScreen.dart';
import 'package:financial_systems_coursework/screens/MainScreen.dart';
import 'package:flutter/material.dart';

void main() => runApp(StocksApp());

class StocksApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stocks App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        MainScreenRoute.routeName: (context) => MainScreenRoute(
              title: 'Select Stock',
            ),
        DetailsScreenRoute.routeName: (context) => DetailsScreenRoute(),
      },
    );
  }
}

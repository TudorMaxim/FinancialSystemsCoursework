import 'package:financial_systems_coursework/screens/DetailsScreen.dart';
import 'package:financial_systems_coursework/shared/AppBaseState.dart';
import 'package:financial_systems_coursework/repository/TickerManager.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class MainScreen extends StatefulWidget {
  final String title;
  MainScreen({Key key, this.title}): super(key: key);

  @override
  State<StatefulWidget> createState() => MainScreenState();
}

class MainScreenState extends AppBaseState<MainScreen> {

  void handlePress(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailsScreen(title: 'Stock Details',)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Future<List<String>> _fs = TickerManager().tickers;
    return new Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        bottom: PreferredSize(
          child: Text(getConnectionString(), style: TextStyle(color: Colors.red),),
          preferredSize: Size.fromHeight(0),
        ),
      ),
      body: renderWithLoader(this.body(_fs)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => this.handlePress(context),
        label: Text('Load Data'),
        icon: Icon(Icons.add)
      ),
    );
  }

  _onSuggestionSelected(String suggestion, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ticker $suggestion selected'),
          duration: Duration(seconds: 2),));
  }

  Widget body(Future<List<String>> _fs) => Center( // TODO: add stock fetching form
    child: FutureBuilder(
      future: _fs,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done) {
          final List<String> _tickers = snapshot.data;
          return TypeAheadField(
              suggestionsCallback: (pattern) => TickerManager().filterSuggestions(pattern, _tickers),
              itemBuilder: (context, suggestion) =>
                ListTile(title: Text(suggestion),),
              onSuggestionSelected: (suggestion) =>
                  _onSuggestionSelected(suggestion, context),);
        } else {
          return CircularProgressIndicator();
        }
      },
    ));

}
import 'package:financial_systems_coursework/repository/TickerManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class TickerSelectForm extends StatefulWidget {
  final Function _handleTickerSubmit;

  TickerSelectForm(this._handleTickerSubmit);

  @override
  _TickerSelectFormState createState() => _TickerSelectFormState();
}

class _TickerSelectFormState extends State<TickerSelectForm> {
  final TextEditingController _ctr = TextEditingController();
  String _ticker = "";

  @override
  void initState() {
    super.initState();
    _ctr.text = _ticker;
  }

  _onSuggestionSelected(String suggestion, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Ticker $suggestion selected'),
      duration: Duration(seconds: 2),
    ));
    widget._handleTickerSubmit(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    final Future<List<String>> _fs = TickerManager().tickers;
    return Center(
        child: FutureBuilder(
          future: _fs,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final List<String> _tickers = snapshot.data;
              return TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                    controller: _ctr,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Ticker')),
                suggestionsCallback: (pattern) =>
                    TickerManager().filterSuggestions(pattern, _tickers),
                itemBuilder: (context, suggestion) => ListTile(
                  title: Text(suggestion),
                ),
                onSuggestionSelected: (suggestion) {
                  _ticker = suggestion;
                  _ctr.text = suggestion;
                  _onSuggestionSelected(suggestion, context);
                },
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ));
  }
}

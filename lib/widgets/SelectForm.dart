import 'package:financial_systems_coursework/repository/TickerManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class SelectForm extends StatefulWidget {
  final String fieldName;
  final Function handleSubmit;
  final Future<List<String>> values;

  SelectForm({this.fieldName, this.values, this.handleSubmit});

  @override
  _SelectFormState createState() => _SelectFormState();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    // TODO: implement toString
    return 'SelectForm for $fieldName';
  }
}

class _SelectFormState extends State<SelectForm> {
  final TextEditingController _ctr = TextEditingController();
  String _currentValue = '';

  @override
  void initState() {
    super.initState();
    _ctr.text = _currentValue;
  }

  _onSuggestionSelected(String suggestion, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${widget.fieldName} $suggestion selected'),
      duration: Duration(seconds: 2),
    ));
    widget.handleSubmit(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: FutureBuilder(
      future: widget.values,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final List<String> _values = snapshot.data;
          return TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
                controller: _ctr,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: widget.fieldName)),
            suggestionsCallback: (pattern) =>
                TickerManager().filterSuggestions(pattern, _values),
            itemBuilder: (context, suggestion) => ListTile(
              title: Text(suggestion),
            ),
            onSuggestionSelected: (suggestion) {
              _currentValue = suggestion;
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

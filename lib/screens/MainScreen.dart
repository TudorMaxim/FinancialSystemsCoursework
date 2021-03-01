import 'package:financial_systems_coursework/screens/DetailsScreen.dart';
import 'package:financial_systems_coursework/shared/AppBaseState.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    return new Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        bottom: PreferredSize(
          child: Text(getConnectionString(), style: TextStyle(color: Colors.red),),
          preferredSize: null,
        ),
      ),
      body: renderWithLoader(this.body()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => this.handlePress(context),
        label: Text('Load Data'),
        icon: Icon(Icons.add)
      ),
    );
  }

  Widget body() => Center( // TODO: add stock fetching form
    child: Text("This is the main screen", style: TextStyle(fontSize: 24),),
  );

}
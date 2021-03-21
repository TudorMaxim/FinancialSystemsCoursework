import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IAppState {
  var connectivityListener;
  bool connected = false;
  bool isFetching = false;
}

class AppBaseState<T extends StatefulWidget> extends State<T> with IAppState {
  static final String _close = 'Close';

  @override
  void initState() {
    super.initState();
    this.setupConnectionListener();
  }

  @override
  Widget build(BuildContext context) => null;

  String getConnectionString() => (this.connected ? '' : 'You are offline!');

  setupConnectionListener() async {
    bool conn = await checkConnection();
    setState(() {
      connected = conn;
    });
    connectivityListener =
        Connectivity().onConnectivityChanged.listen((result) async {
      bool connected = result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi;
      if (connected != this.connected) {
        setState(() {
          this.connected = connected;
        });
      }
    });
  }

  checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  Widget renderWithLoader(Widget body) {
    return Visibility(
      visible: this.isFetching,
      child: Center(
        child: CircularProgressIndicator(),
      ),
      replacement: body,
    );
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(title),
          content: new Text(message),
          actions: <Widget>[
            new TextButton(
              child: new Text(_close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

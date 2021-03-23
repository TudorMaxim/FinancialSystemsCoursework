import 'package:flutter/material.dart';

class InlineBold extends StatelessWidget {
  final String normal;
  final String bold;

  InlineBold(this.normal, this.bold);

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.black,
            ),
            children: [
          TextSpan(text: normal),
          TextSpan(text: bold, style: TextStyle(fontWeight: FontWeight.bold)),
        ]));
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IOSBackButton extends StatelessWidget {
  const IOSBackButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_left,
              // size: 14,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }));
  }
}

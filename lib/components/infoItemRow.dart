import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:axiawallet_ui/utils/format.dart';

class InfoItemRow extends StatelessWidget {
  InfoItemRow(
    this.label,
    this.content, {
    this.colorPrimary = false,
    this.color,
  });
  final String label;
  final String content;
  final Color color;
  final bool colorPrimary;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          label,
          style: TextStyle(fontSize: 14),
        ),
        Expanded(
          child: Text(
            Fmt.capitalizeFirst(content),
            textAlign: TextAlign.right,
            style: color != null || colorPrimary
                ? TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: color ?? Theme.of(context).primaryColor,
                  )
                : Theme.of(context).textTheme.headline4,
          ),
        ),
      ],
    );
  }
}

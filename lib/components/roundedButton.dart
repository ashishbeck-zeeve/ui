import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton({
    this.text,
    this.textColor,
    this.textSize = 18,
    this.onPressed,
    this.icon,
    this.color,
    this.borderRadius = 12,
    this.submitting = false,
    this.isIconRight = false,
  });

  final String text;
  final Color textColor;
  final double textSize;
  final Function onPressed;
  final Widget icon;
  final Color color;
  final double borderRadius;
  final bool submitting;
  final bool isIconRight;

  @override
  Widget build(BuildContext context) {
    List<Widget> row = <Widget>[];
    if (submitting) {
      row.add(CupertinoActivityIndicator());
    }
    if (icon != null && !isIconRight) {
      row.add(Container(
          padding: EdgeInsets.only(right: text == null ? 0 : 4), child: icon));
    }
    if (text != null) {
      row.add(Expanded(
          flex: 0,
          child: Text(
            text,
            style: textColor != null
                ? TextStyle(
                    color: textColor,
                    fontSize: textSize,
                    fontWeight: FontWeight.w500)
                : Theme.of(context)
                    .textTheme
                    .button
                    .copyWith(fontSize: textSize, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          )));
    }
    if (icon != null && isIconRight) {
      row.add(Container(
          padding: EdgeInsets.only(right: text == null ? 0 : 4), child: icon));
    }

    final bgColor = onPressed == null || submitting
        ? (color ?? Theme.of(context).primaryColor).withOpacity(0.7)
        : (color ?? Theme.of(context).primaryColor);
    final gradientColor = onPressed == null || submitting
        ? (color ?? Theme.of(context).primaryColor).withOpacity(0.7)
        : (color ?? Theme.of(context).accentColor);

    return RaisedButton(
      padding: EdgeInsets.all(0),
      // color: color ?? Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius)),
      child: Stack(
        children: [
          onPressed == null || submitting
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                  ),
                  constraints: BoxConstraints(minHeight: 50.0, minWidth: 88),
                )
              : Container(),
          Ink(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [bgColor, gradientColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.1, 0.9],
                ),
                // backgroundBlendMode: BlendMode.luminosity,
                borderRadius: BorderRadius.circular(borderRadius)),
            child: Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              constraints: BoxConstraints(minHeight: 50.0, minWidth: 88),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row,
              ),
            ),
          ),
        ],
      ),
      onPressed: submitting ? null : onPressed,
    );
  }
}

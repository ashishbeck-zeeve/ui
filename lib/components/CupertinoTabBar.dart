import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CustomCupertinoTabBar extends StatelessWidget {
  CustomCupertinoTabBar({
    @required this.children,
    @required this.onValueChanged,
    @required this.groupValue,
    this.backgroundColor = Colors.transparent,
    this.thumbColor = Colors.white,
  });

  final List<String> children;
  final Function(int) onValueChanged;
  final int groupValue;
  final Color backgroundColor;
  final Color thumbColor;

  Widget title(BuildContext context, String text, bool selected) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        style: TextStyle(
            color: selected ? Theme.of(context).primaryColor : Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<int, Widget> mapped = {};
    for (var i = 0; i < children.length; i++) {
      mapped.addAll({i: title(context, children[i], groupValue == i)});
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: CupertinoSlidingSegmentedControl<int>(
        children: mapped,
        groupValue: groupValue,
        onValueChanged: (int val) => onValueChanged(val),
        backgroundColor: backgroundColor,
        thumbColor: thumbColor,
      ),
    );
  }
}

import 'package:axiawallet_ui/utils/format.dart';
import 'package:flutter/material.dart';

class TransferSummary extends StatelessWidget {
  final Map arguments;
  const TransferSummary({Key key, @required this.arguments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("arguments are $arguments");
    List<Map> args = [arguments];
    var firstElement = arguments[arguments.keys.first];
    if (firstElement is List && arguments.keys.length == 1) {
      // args = {for (var map in firstElement) ...map};
      // if (firstElement.isEmpty) arguments[arguments.keys.first] = "-";
      args = firstElement;
    } else if (firstElement is Map) {
      args = [firstElement];
    }
    Widget item(String key, String value) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Fmt.capitalizeFirst(key == "" ? '-' : key).replaceAll("_", " "),
            style:
                TextStyle(color: Theme.of(context).primaryColor, fontSize: 12),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            (value == "" ? '-' : value),
            style: TextStyle(color: Theme.of(context).unselectedWidgetColor),
          )
        ],
      );
    }

    List<Widget> children = [];
    args.forEach((element) {
      children.addAll(element.entries
          .map((e) => item(e.key.toString(), e.value.toString()))
          .toList());
      if (element != args.last)
        children.add(Divider(indent: 64, endIndent: 64));
    });
    // args.entries
    //     .map((e) => item(e.key.toString(), e.value.toString()))
    //     .toList();

    return Container(
      alignment: Alignment.centerLeft,
      child: Wrap(
        children: children,
        spacing: 16,
        runSpacing: 16,
      ),
    );
  }
}

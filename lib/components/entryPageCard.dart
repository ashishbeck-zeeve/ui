import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:axiawallet_ui/components/roundedCard.dart';

class EntryPageCard extends StatelessWidget {
  EntryPageCard(this.title, this.brief, this.icon, {this.color});

  final Widget icon;
  final String title;
  final String brief;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 96,
            height: 110,
            decoration: BoxDecoration(
              color: color ?? Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                  topLeft: const Radius.circular(8),
                  bottomLeft: const Radius.circular(8)),
            ),
            child: Center(child: icon),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 8, bottom: 4),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 8),
                width: MediaQuery.of(context).size.width -
                    96 - // from svg widget
                    32, //from parent padding of 16 in all sides
                child: Text(
                  brief,
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).unselectedWidgetColor),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

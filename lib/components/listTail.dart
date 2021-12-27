import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:axiawallet_sdk/utils/i18n.dart';
import 'package:axiawallet_ui/utils/i18n.dart';

class ListTail extends StatelessWidget {
  ListTail(
      {this.isEmpty,
      this.isLoading,
      this.mainAxisAlignment = MainAxisAlignment.center});
  final bool isLoading;
  final bool isEmpty;
  final MainAxisAlignment mainAxisAlignment;
  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_ui, 'common');
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(16),
          child: isLoading
              ? CupertinoActivityIndicator()
              : Text(
                  isEmpty ? dic['list.empty'] : dic['list.end'],
                  style: TextStyle(
                      fontSize: 16, color: Theme.of(context).disabledColor),
                ),
        )
      ],
    );
  }
}

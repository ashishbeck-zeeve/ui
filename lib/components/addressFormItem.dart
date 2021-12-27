import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:axiawallet_sdk/storage/types/keyPairData.dart';
import 'package:axiawallet_ui/components/addressIcon.dart';
import 'package:axiawallet_ui/utils/format.dart';
import 'package:axiawallet_ui/utils/index.dart';

class AddressFormItem extends StatelessWidget {
  AddressFormItem(this.account, {this.label, this.svg, this.onTap});
  final String label;
  final String svg;
  final KeyPairData account;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final grey = Theme.of(context).unselectedWidgetColor;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        label != null
            ? Container(
                margin: EdgeInsets.only(top: 4),
                child: Text(
                  label,
                  style: TextStyle(),
                ),
              )
            : Container(),
        Container(
          margin: EdgeInsets.only(top: 4, bottom: 4),
          padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            border: Border.all(width: 0.5),
          ),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 8),
                child: AddressIcon(
                  account.address,
                  svg: svg ?? account.icon,
                  size: 32,
                  tapToCopy: false,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(UI.accountName(context, account)),
                    Text(
                      Fmt.address(account.address),
                      style: TextStyle(fontSize: 14, color: grey),
                    )
                  ],
                ),
              ),
              onTap == null
                  ? Container()
                  : Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: grey,
                    )
            ],
          ),
        )
      ],
    );

    if (onTap == null) {
      return content;
    }
    return GestureDetector(
      child: content,
      onTap: () => onTap(),
    );
  }
}

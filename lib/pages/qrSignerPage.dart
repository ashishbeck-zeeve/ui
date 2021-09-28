import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:axiawallet_sdk/plugin/index.dart';
import 'package:axiawallet_sdk/storage/keyring.dart';
import 'package:axiawallet_ui/components/addressFormItem.dart';
import 'package:axiawallet_ui/components/textTag.dart';
import 'package:axiawallet_ui/utils/i18n.dart';
import 'package:qr_flutter_fork/qr_flutter_fork.dart';
import 'package:axiawallet_sdk/utils/i18n.dart';

class QrSignerPage extends StatelessWidget {
  QrSignerPage(this.plugin, this.keyring);

  static const String route = 'tx/uos/signer';

  final AXIAWalletPlugin plugin;
  final Keyring keyring;

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_ui, 'account');
    final text = ModalRoute.of(context).settings.arguments;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text(dic['uos.title']), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AddressFormItem(
                  keyring.current,
                  label: dic['uos.signer'],
                  svg: keyring.current.icon,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: TextTag(
                    dic['uos.warn'],
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(dic['uos.push']),
                ),
                QrImage(data: text, size: screenWidth - 24),
              ],
            )
          ],
        ),
      ),
    );
  }
}

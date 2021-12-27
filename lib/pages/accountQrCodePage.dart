import 'package:axiawallet_ui/components/iosBackButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:axiawallet_sdk/plugin/index.dart';
import 'package:axiawallet_sdk/storage/keyring.dart';
import 'package:axiawallet_ui/components/addressIcon.dart';
import 'package:axiawallet_ui/components/roundedButton.dart';
import 'package:axiawallet_ui/components/roundedCard.dart';
import 'package:axiawallet_ui/components/textTag.dart';
import 'package:axiawallet_ui/utils/i18n.dart';
import 'package:axiawallet_ui/utils/index.dart';
import 'package:qr_flutter_fork/qr_flutter_fork.dart';

import 'package:axiawallet_sdk/utils/i18n.dart';

class AccountQrCodePage extends StatelessWidget {
  AccountQrCodePage(this.plugin, this.keyring);
  final AXIAWalletPlugin plugin;
  final Keyring keyring;

  static final String route = '/assets/receive';

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_ui, 'account');

    final codeAddress =
        'substrate:${keyring.current.address}:${keyring.current.pubKey}:${keyring.current.name}';

    final accInfo = keyring.current.indexInfo;
    final qrWidth = MediaQuery.of(context).size.width / 2;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(dic['receive']),
        centerTitle: true,
        leading: IOSBackButton(),
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            RoundedCard(
              margin: EdgeInsets.fromLTRB(32, 16, 32, 16),
              child: Column(
                children: <Widget>[
                  keyring.current.observation ?? false
                      ? Container(
                          margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child:
                              TextTag(dic['warn.external'], color: Colors.red),
                        )
                      : Container(),
                  Padding(
                    padding: EdgeInsets.only(top: 24, bottom: 8),
                    child: AddressIcon(
                      keyring.current.address,
                      svg: keyring.current.icon,
                    ),
                  ),
                  UI.accountDisplayName(
                      keyring.current.address, keyring.current.indexInfo,
                      mainAxisAlignment: MainAxisAlignment.center,
                      expand: false),
                  accInfo != null && accInfo['accountIndex'] != null
                      ? Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(accInfo['accountIndex']),
                        )
                      : Container(width: 8, height: 8),
                  Container(
                    margin: EdgeInsets.all(8),
                    child: QrImage(
                      data: codeAddress,
                      size: qrWidth + 24,
                      embeddedImage: AssetImage(
                          'packages/axiawallet_ui/assets/images/app.png'),
                      embeddedImageStyle:
                          QrEmbeddedImageStyle(size: Size(40, 40)),
                    ),
                  ),
                  Container(
                    width: qrWidth,
                    child: Text(keyring.current.address),
                  ),
                  Container(
                    width: qrWidth,
                    padding: EdgeInsets.only(top: 16, bottom: 24),
                    child: RoundedButton(
                      text: I18n.of(context)
                          .getDic(i18n_full_dic_ui, 'common')['copy'],
                      textSize: 16,
                      onPressed: () =>
                          UI.copyAndNotify(context, keyring.current.address),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

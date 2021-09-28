import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:axiawallet_sdk/plugin/index.dart';
import 'package:axiawallet_sdk/storage/keyring.dart';
import 'package:axiawallet_sdk/storage/types/keyPairData.dart';
import 'package:axiawallet_sdk/utils/i18n.dart';
import 'package:axiawallet_ui/components/accountSelectList.dart';
import 'package:axiawallet_ui/utils/i18n.dart';

class AccountListPageParams {
  AccountListPageParams({this.list, this.title});

  final String title;
  final List<KeyPairData> list;
}

class AccountListPage extends StatelessWidget {
  AccountListPage(this.plugin, this.keyring);

  static final String route = '/profile/contacts/list';
  final AXIAWalletPlugin plugin;
  final Keyring keyring;

  @override
  Widget build(BuildContext context) {
    final AccountListPageParams args =
        ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(args.title ??
            I18n.of(context).getDic(i18n_full_dic_ui, 'account')['select']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: AccountSelectList(
          plugin,
          args.list,
        ),
      ),
    );
  }
}

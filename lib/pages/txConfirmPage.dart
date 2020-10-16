import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_sdk/api/types/recoveryInfo.dart';
import 'package:polkawallet_sdk/api/types/txInfoData.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressFormItem.dart';
import 'package:polkawallet_ui/components/passwordInputDialog.dart';
import 'package:polkawallet_ui/components/tapTooltip.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/pages/accountListPage.dart';
import 'package:polkawallet_ui/pages/qrSenderPage.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/i18n.dart';

class TxConfirmPage extends StatefulWidget {
  const TxConfirmPage(this.plugin, this.keyring);
  final PolkawalletPlugin plugin;
  final Keyring keyring;

  static final String route = '/tx/confirm';

  @override
  _TxConfirmPageState createState() => _TxConfirmPageState();
}

class _TxConfirmPageState extends State<TxConfirmPage> {
  bool _submitting = false;
  String _txStatus = 'queued';

  TxFeeEstimateResult _fee;
  double _tip = 0;
  BigInt _tipValue = BigInt.zero;
  KeyPairData _proxyAccount;
  RecoveryInfo _recoveryInfo = RecoveryInfo();

  Future<String> _getTxFee({bool reload = false}) async {
    if (_fee.partialFee != null && !reload) {
      return _fee.partialFee.toString();
    }
    if (widget.keyring.current.observation ?? false) {
      final recoveryInfo = await widget.plugin.sdk.api.recovery
          .queryRecoverable(widget.keyring.current.address);
      setState(() {
        _recoveryInfo = recoveryInfo;
      });
    }

    final TxConfirmParams args = ModalRoute.of(context).settings.arguments;
    final sender = TxSenderData(
        widget.keyring.current.address, widget.keyring.current.pubKey);
    final txInfo = TxInfoData(args.module, args.call, sender);
    // if (_proxyAccount != null) {
    //   txInfo['proxy'] = _proxyAccount.pubKey;
    // }
    final fee = await widget.plugin.sdk.api.tx
        .estimateFees(txInfo, args.params, rawParam: args.rawParams);
    setState(() {
      _fee = fee;
    });
    return fee.partialFee.toString();
  }

  Future<void> _onSwitch(bool value) async {
    if (value) {
      final accounts = widget.keyring.keyPairs.toList();
      accounts.addAll(widget.keyring.externals);
      final acc = await Navigator.of(context).pushNamed(
        AccountListPage.route,
        arguments: AccountListPageParams(
            title:
                I18n.of(context).getDic(i18n_full_dic_ui, 'account')['select'],
            list: accounts),
      );
      if (acc != null) {
        setState(() {
          _proxyAccount = acc;
        });
      }
    } else {
      setState(() {
        _proxyAccount = null;
      });
    }
    _getTxFee(reload: true);
  }

  void _onTxFinish(BuildContext context, String hash) {
    print('callback triggered, blockHash: $hash}');
    if (mounted) {
      final ScaffoldState state = Scaffold.of(context);

      state.removeCurrentSnackBar();
      state.showSnackBar(SnackBar(
        backgroundColor: Colors.white,
        content: ListTile(
          leading: Container(
            width: 24,
            child: Image.asset('assets/images/assets/success.png'),
          ),
          title: Text(
            I18n.of(context).getDic(i18n_full_dic_ui, 'common')['success'],
            style: TextStyle(color: Colors.black54),
          ),
        ),
        duration: Duration(seconds: 2),
      ));

      Timer(Duration(seconds: 2), () {
        Navigator.of(context).pop(true);
      });
    }
  }

  void _onTxError(BuildContext context, String errorMsg) {
    if (mounted) {
      Scaffold.of(context).removeCurrentSnackBar();
    }
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Container(),
          content: Text(errorMsg),
          actions: <Widget>[
            CupertinoButton(
              child: Text(
                  I18n.of(context).getDic(i18n_full_dic_ui, 'common')['ok']),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _validateProxy() async {
    List proxies = await widget.plugin.sdk.api.recovery
        .queryRecoveryProxies([_proxyAccount.address]);
    print(proxies);
    return proxies[0] == widget.keyring.current.address;
  }

  Future<void> _showPasswordDialog(BuildContext context) async {
    final dic = I18n.of(context).getDic(i18n_full_dic_ui, 'common');
    if (_proxyAccount != null && !(await _validateProxy())) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(Fmt.address(widget.keyring.current.address)),
            content: Text(dic['tx.proxy.invalid']),
            actions: <Widget>[
              CupertinoButton(
                child: Text(
                  dic['cancel'],
                  style: TextStyle(
                    color: Theme.of(context).unselectedWidgetColor,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }
    showCupertinoDialog(
      context: context,
      builder: (_) {
        return PasswordInputDialog(
          widget.plugin.sdk.api,
          title: Text(dic['unlock']),
          account: _proxyAccount ?? widget.keyring.current,
          onOk: (password) => _onSubmit(context, password: password),
        );
      },
    );
  }

  Future<void> _onSubmit(
    BuildContext context, {
    String password,
    bool viaQr = false,
  }) async {
    final dic = I18n.of(context).getDic(i18n_full_dic_ui, 'common');
    final TxConfirmParams args = ModalRoute.of(context).settings.arguments;

    setState(() {
      _submitting = true;
    });
    Scaffold.of(context).showSnackBar(SnackBar(
      backgroundColor: Theme.of(context).cardColor,
      content: ListTile(
        leading: CupertinoActivityIndicator(),
        title: Text(
          dic['tx.$_txStatus'] ?? dic['tx.wait'],
          style: TextStyle(color: Colors.black54),
        ),
      ),
      duration: Duration(minutes: 5),
    ));

    final TxSenderData sender = TxSenderData(
      widget.keyring.current.address,
      widget.keyring.current.pubKey,
    );
    final TxInfoData txInfo = TxInfoData(
      args.module,
      args.call,
      sender,
      proxy: _proxyAccount != null
          ? TxSenderData(_proxyAccount.address, _proxyAccount.pubKey)
          : null,
      tip: _tipValue.toString(),
    );

    print(txInfo);
    print(args.params);

    try {
      final String hash = viaQr
          ? await _sendTxViaQr(context, txInfo, args)
          : await _sendTx(context, txInfo, args, password);
      _onTxFinish(context, hash.toString());
    } catch (err) {
      _onTxError(context, err.toString());
    }
    setState(() {
      _submitting = false;
    });
  }

  Future<String> _sendTx(
    BuildContext context,
    TxInfoData txInfo,
    TxConfirmParams args,
    String password,
  ) async {
    return widget.plugin.sdk.api.tx.signAndSend(txInfo, args.params, password,
        rawParam: args.rawParams, onStatusChange: (status) {
      setState(() {
        _txStatus = status;
      });
    });
  }

  Future<Map> _sendTxViaQr(
      BuildContext context, TxInfoData txInfo, TxConfirmParams args) async {
    final Map dic = I18n.of(context).getDic(i18n_full_dic_ui, 'common');
    print('show qr');
    final signed = await Navigator.of(context)
        .pushNamed(QrSenderPage.route, arguments: txInfo);
    if (signed == null) {
      return {'error': dic['tx.cancelled']};
    }
    return widget.plugin.sdk.api.uos.addSignatureAndSend(
        widget.keyring.current.address, signed.toString(), (status) {
      _txStatus = status;
    });
  }

  void _onTipChanged(double tip) {
    final decimals = widget.plugin.networkState.tokenDecimals;

    /// tip division from 0 to 19:
    /// 0-10 for 0-0.1
    /// 10-19 for 0.1-1
    BigInt value = Fmt.tokenInt('0.01', decimals) * BigInt.from(tip.toInt());
    if (tip > 10) {
      value = Fmt.tokenInt('0.1', decimals) * BigInt.from((tip - 9).toInt());
    }
    setState(() {
      _tip = tip;
      _tipValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_ui, 'common');
    final dicAcc = I18n.of(context).getDic(i18n_full_dic_ui, 'account');
    final String symbol = widget.plugin.networkState.tokenSymbol ?? '';
    final int decimals = widget.plugin.networkState.tokenDecimals ?? 12;

    final TxConfirmParams args = ModalRoute.of(context).settings.arguments;

    final bool isObservation = widget.keyring.current.observation ?? false;
    final bool isProxyObservation =
        _proxyAccount != null ? _proxyAccount.observation ?? false : false;
    final bool isKusama = widget.plugin.name == 'kusama';

    bool isUnsigned = args.isUnsigned ?? false;
    return Scaffold(
      appBar: AppBar(
        title: Text(args.txTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      dic['tx.submit'],
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                  isUnsigned
                      ? Container()
                      : Padding(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: AddressFormItem(
                            widget.keyring.current,
                            label: dic["tx.from"],
                          ),
                        ),
                  isKusama && isObservation && _recoveryInfo.address != null
                      ? Padding(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: Row(
                            children: [
                              TapTooltip(
                                message: dic['tx.proxy.brief'],
                                child: Icon(Icons.info_outline, size: 16),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Text(dic['tx.proxy']),
                                ),
                              ),
                              CupertinoSwitch(
                                value: _proxyAccount != null,
                                onChanged: (res) => _onSwitch(res),
                              )
                            ],
                          ),
                        )
                      : Container(),
                  _proxyAccount != null
                      ? GestureDetector(
                          child: Padding(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: AddressFormItem(
                              _proxyAccount,
                              label: dicAcc["proxy"],
                            ),
                          ),
                          onTap: () => _onSwitch(true),
                        )
                      : Container(),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        Container(width: 64, child: Text(dic["tx.call"])),
                        Text('${args.module}.${args.call}'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      children: <Widget>[
                        Container(width: 64, child: Text(dic["detail"])),
                        Container(
                          width: MediaQuery.of(context).copyWith().size.width -
                              120,
                          child: Text(
                            JsonEncoder.withIndent('  ')
                                .convert(args.txDisplay),
                          ),
                        ),
                      ],
                    ),
                  ),
                  isUnsigned
                      ? Container()
                      : Padding(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(top: 8),
                                width: 64,
                                child: Text(dic["tx.fee"]),
                              ),
                              FutureBuilder<String>(
                                future: _getTxFee(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> snapshot) {
                                  if (snapshot.hasData) {
                                    String fee = Fmt.balance(
                                      _fee.partialFee.toString(),
                                      decimals,
                                      length: 6,
                                    );
                                    return Container(
                                      margin: EdgeInsets.only(top: 8),
                                      width: MediaQuery.of(context)
                                              .copyWith()
                                              .size
                                              .width -
                                          120,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            '$fee $symbol',
                                          ),
                                          Text(
                                            '${_fee.weight} Weight',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Theme.of(context)
                                                  .unselectedWidgetColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return CupertinoActivityIndicator();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 64,
                          child: Text(dic['tx.tip']),
                        ),
                        Text('${Fmt.token(_tipValue, decimals)} $symbol'),
                        TapTooltip(
                          message: dic['tx.tip.brief'],
                          child: Icon(
                            Icons.info,
                            color: Theme.of(context).unselectedWidgetColor,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      children: <Widget>[
                        Text('0'),
                        Expanded(
                          child: Slider(
                            min: 0,
                            max: 19,
                            divisions: 19,
                            value: _tip,
                            onChanged: _onTipChanged,
                          ),
                        ),
                        Text('1')
                      ],
                    ),
                  )
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: _submitting ? Colors.black12 : Colors.orange,
                    child: FlatButton(
                      padding: EdgeInsets.all(16),
                      child: Text(dic['cancel'],
                          style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: _submitting
                        ? Theme.of(context).disabledColor
                        : Theme.of(context).primaryColor,
                    child: FlatButton(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        isUnsigned
                            ? dic['submit.no.sign']
                            : (isObservation && _proxyAccount == null) ||
                                    isProxyObservation
                                ? dic['submit.qr']
                                // dicAcc['observe.invalid']
                                : dic['submit'],
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: isUnsigned
                          ? () => _onSubmit(context)
                          : (isObservation && _proxyAccount == null) ||
                                  isProxyObservation
                              ? () => _onSubmit(context, viaQr: true)
                              : _submitting
                                  ? null
                                  : () => _showPasswordDialog(context),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

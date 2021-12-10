import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:axiawallet_ui/utils/index.dart';

class AddressIcon extends StatelessWidget {
  AddressIcon(
    this.address, {
    this.size,
    this.svg,
    this.tapToCopy = true,
  });
  final String address;
  final String svg;
  final double size;
  final bool tapToCopy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: size ?? 40,
        height: size ?? 40,
        child: svg == null
            ? Image.asset(
                'packages/axiawallet_ui/assets/images/axia_avatar.png',
                bundle: rootBundle,
              )
            : SvgPicture.string(svg),
      ),
      onTap: tapToCopy ? () => UI.copyAndNotify(context, address) : null,
    );
  }
}

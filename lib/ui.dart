library axiawallet_ui;

import 'package:flutter/material.dart';

class PageWrapperWithBackground extends StatelessWidget {
  PageWrapperWithBackground(this.child, {this.height, this.backgroundImage});

  final double height;
  final AssetImage backgroundImage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Stack(
      // fit: StackFit.expand,
      alignment: AlignmentDirectional.topCenter,
      children: <Widget>[
        // Container(
        //   width: double.infinity,
        //   height: double.infinity,
        //   color: Theme.of(context).canvasColor,
        // ),
        Container(
          width: width,
          height: height ?? 200,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              // Theme.of(context).primaryColor,
              // Theme.of(context).primaryColorDark
              Color(0xff178fe1),
              Color(0xff007cbd)
            ],
            stops: [0.1, 0.9],
          ),
          ),
        ),
        Container(
          width: width,
          height: height ?? 200,
          decoration: backgroundImage != null
              ? BoxDecoration(
                  image: DecorationImage(
                    image: backgroundImage,
                    fit: BoxFit.cover,
                  ),
                )
              : null,
        ),
        child,
      ],
    );
  }
}

import 'dart:ui';
import 'package:budget/struct/settings.dart';
import 'package:flutter/material.dart';

class ScrollBehaviorOverride extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    if (appStateSettings["scrollBehavior"] == "bouncing" ||
        appStateSettings["iOSEmulate"] == true) {
      return BouncingScrollPhysics();
    } else if (appStateSettings["scrollBehavior"] == "clamping") {
      return ClampingScrollPhysics();
    }
    return super.getScrollPhysics(context);
  }
}

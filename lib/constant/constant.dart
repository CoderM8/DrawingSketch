import 'package:drawing_sketch/constant/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OverlayStyle {
  /// WHEN BACKGROUND IS DARK AND SHOW STATUS BAR COLOR LIGHT
  static get light {
    return SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: blackColor,
          systemNavigationBarIconBrightness: Brightness.light),
    );
  }

  /// WHEN BACKGROUND IS LIGHT AND SHOW STATUS BAR COLOR DARK
  static get dark {
    return SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: whiteColor,
        systemNavigationBarIconBrightness: Brightness.dark));
  }
}

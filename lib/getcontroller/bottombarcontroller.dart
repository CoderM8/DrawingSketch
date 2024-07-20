import 'package:drawing_sketch/constant/constant.dart';
import 'package:drawing_sketch/ui/bottombar/creation/videoCreation.dart';
import 'package:drawing_sketch/ui/bottombar/favourite/favourite.dart';
import 'package:drawing_sketch/ui/bottombar/home/homescreen.dart';
import 'package:drawing_sketch/ui/bottombar/settings/settingscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomController extends GetxController with WidgetsBindingObserver {
  final List<Widget> pages = <Widget>[
    HomeScreen(),
    VideoCreation(),
    FavouriteCollection(),
    const SettingScreen(),
  ];
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    WidgetsBinding.instance.addObserver(this);
    super.onInit();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      OverlayStyle.dark;
    }
    super.didChangeAppLifecycleState(state);
  }
}

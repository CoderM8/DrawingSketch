import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/getcontroller/bottombarcontroller.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class BottomBar extends GetView {
  BottomBar({super.key});

  final BottomController bc = Get.put(BottomController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          currentIndex: bc.currentIndex.value,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: pinkColor,
          unselectedItemColor: blackColor.withOpacity(.4),
          backgroundColor: whiteColor,
          selectedLabelStyle: TextStyle(fontFamily: "M", fontSize: 12.sp, color: pinkColor),
          unselectedLabelStyle: TextStyle(fontFamily: "M", fontSize: 12.sp, color: blackColor.withOpacity(.4)),
          onTap: (index) {
            bc.currentIndex.value = index;
          },
          items: [
            BottomNavigationBarItem(
                icon: ConstSvg("assets/svg/home.svg", color: borderColor, height: 25.w, width: 23.w, fit: BoxFit.cover),
                activeIcon: ConstSvg("assets/svg/home.svg", color: pinkColor, height: 25.w, width: 23.w, fit: BoxFit.cover),
                label: 'Home'.tr),
            BottomNavigationBarItem(
                icon: ConstSvg("assets/svg/magic.svg", color: borderColor, height: 25.w, width: 23.w, fit: BoxFit.cover),
                activeIcon: ConstSvg("assets/svg/magic.svg", color: pinkColor, height: 25.w, width: 23.w, fit: BoxFit.cover),
                label: 'Creation'.tr),
            BottomNavigationBarItem(
                icon: ConstSvg("assets/svg/rate.svg", color: borderColor, height: 25.w, width: 23.w, fit: BoxFit.cover),
                activeIcon: ConstSvg("assets/svg/rate.svg", color: pinkColor, height: 25.w, width: 23.w, fit: BoxFit.cover),
                label: 'Favourite'.tr),
            BottomNavigationBarItem(
                icon: ConstSvg("assets/svg/setting.svg", color: borderColor, height: 25.w, width: 23.w, fit: BoxFit.cover),
                activeIcon: ConstSvg("assets/svg/setting.svg", color: pinkColor, height: 25.w, width: 23.w, fit: BoxFit.cover),
                label: 'Settings'.tr),
          ],
        );
      }),
      body: Obx(() {
        return IndexedStack(index: bc.currentIndex.value, children: bc.pages);
      }),
    );
  }
}

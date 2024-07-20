import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/localization/languages.dart';
import 'package:drawing_sketch/static/apis.dart';
import 'package:drawing_sketch/storages/storages.dart';
import 'package:drawing_sketch/ui/bottombar/bottombar.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

final RxInt selectedIndex = 0.obs;

class ChangeLanguage extends GetView {
  const ChangeLanguage({super.key, this.isVisit = false});

  final bool isVisit;

  @override
  Widget build(BuildContext context) {
    final indexx = AppLanguage.list.indexWhere((element) => element.languageCode == Storages.read('languageCode'));
    if (!indexx.isNegative) {
      selectedIndex.value = indexx;
    }
    return Scaffold(
      appBar: AppBar(
        title: ConstText(isVisit ? "Languages" : 'Change_Language', fontFamily: "B"),
        leading: isVisit
            ? null
            : ConstSvg(
                "assets/svg/back.svg",
                height: 24.w,
                width: 24.w,
                fit: BoxFit.scaleDown,
                color: blackColor,
                onTap: () {
                  Get.back();
                },
              ),
        actions: [
          Center(
            child: InkWell(
                onTap: () async {
                  await Apis.changeLanguage(AppLanguage.list[selectedIndex.value].languageCode);
                  if (isVisit) {
                    Get.offAll(() => BottomBar());
                  }
                },
                child: ConstText(
                  'Done',
                  fontFamily: "M",
                  fontSize: 16.sp,
                  color: blackColor,
                  textAlign: TextAlign.center,
                  padding: EdgeInsets.all(20.w),
                )),
          ),
        ],
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        itemCount: AppLanguage.list.length,
        itemBuilder: (context, index) {
          final AppLanguage language = AppLanguage.list[index];
          return Obx(() {
            final bool active = (selectedIndex.value == index);
            return ListTile(
              leading: ConstText(language.flag, textAlign: TextAlign.start, fontSize: 20.sp),
              title: ConstText(language.name, maxLines: 1, color: themeColor, textAlign: TextAlign.start, fontFamily: "M", fontSize: 15.sp),
              trailing: active ? ConstSvg("assets/svg/done.svg", height: 22.w, width: 22.w) : Icon(Icons.radio_button_unchecked, color: blackColor, size: 25.h),
              onTap: () {
                selectedIndex.value = index;
              },
            );
          });
        },
        separatorBuilder: (context, index) => SizedBox(height: 8.h),
      ),
    );
  }
}

import 'package:drawing_sketch/ads/ads.dart';
import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/storages/storages.dart';
import 'package:drawing_sketch/subscription/subscription.dart';
import 'package:drawing_sketch/widgets/button.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Future showAdsOption() {
  Storages.writeIfNull('Attempt', {"date": DateTime.now().microsecondsSinceEpoch, 'count': 0});
  final attempt = Storages.read('Attempt');
  RxString string = "".obs;
  if (attempt['count'] as int >= adLimit.value) {
    string.value = "Ad_limit".tr.replaceAll('xxx', '$adLimit/$adLimit');
  }
  return Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10.h),
            ConstText('Choose_an_option', fontFamily: 'B', fontSize: 18.sp),
            SizedBox(height: 15.h),
            ConstText('Option_text', fontFamily: 'M', fontSize: 16.sp),
            SizedBox(height: 10.h),
            Obx(() {
              string.value;
              return ConstText(string.value, fontFamily: 'M', fontSize: 13.sp, color: Colors.red);
            }),
            SizedBox(height: 10.h),
            ConstButton(
              border: true,
              height: 45.h,
              radius: 10.r,
              icon: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstSvg("assets/svg/ads.svg", width: 18.w, height: 18.w, fit: BoxFit.scaleDown, color: Colors.black),
                  SizedBox(width: 5.w),
                  ConstText('Watch_ad', fontSize: 14.sp, fontFamily: "SB", color: Colors.black, textAlign: TextAlign.start),
                ],
              ),
              onTap: () async {
                final DateTime date = DateTime.fromMicrosecondsSinceEpoch(attempt['date']);
                final DateTime initDate = DateTime(date.year, date.month, date.day);
                final DateTime now = DateTime.now();
                final bool isPast = initDate.isBefore(DateTime(now.year, now.month, now.day));
                print('attempt date after isPast $isPast ** $attempt');
                if (isPast) {
                  // date is past add today data
                  Storages.write('Attempt', {"date": DateTime.now().microsecondsSinceEpoch, 'count': 0});
                  await ApplovinAds.showRewardAds();
                } else {
                  // date is Today date and check user show add 3 time after not show
                  if (attempt['count'] as int < adLimit.value) {
                    attempt['count'] += 1;
                    Storages.write('Attempt', attempt);
                    await ApplovinAds.showRewardAds();
                  } else {
                    string.value = "Ad_limit".tr.replaceAll('xxx', '$adLimit/$adLimit');
                    print('Reached to limit $adLimit/$adLimit ad per day');
                  }
                }
                print('attempt data before $attempt');
                if (string.isEmpty) {
                  Get.back();
                } else {
                  Future.delayed(Duration(seconds: 2), () {
                    Get.back();
                  });
                }
              },
            ),
            ConstButton(
              height: 45.h,
              radius: 10.r,
              color: pinkColor,
              icon: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstSvg("assets/svg/premium.svg", width: 18.w, height: 18.w, fit: BoxFit.scaleDown, color: Colors.white),
                  SizedBox(width: 5.w),
                  ConstText('Subscribe', fontSize: 14.sp, fontFamily: "SB", color: Colors.white, textAlign: TextAlign.start),
                ],
              ),
              onTap: () {
                Get.back();
                Get.to(() => SubscriptionPlan());
              },
            ),
          ],
        ),
      ),
    ),
  );
}

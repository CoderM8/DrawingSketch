import 'package:drawing_sketch/ads/ads.dart';
import 'package:drawing_sketch/static/apis.dart';
import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/subscription/config.dart';
import 'package:drawing_sketch/subscription/subscription.dart';
import 'package:drawing_sketch/ui/bottombar/bottombar.dart';
import 'package:drawing_sketch/widgets/button.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RateUsScreen extends GetView {
  const RateUsScreen({super.key, this.isVisit = false});

  final bool isVisit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage("assets/png/background.png"),
          ),
        ),
        child: Column(
          children: [
            Container(height: 80.h),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: ConstSvg(
                  "assets/svg/close.svg",
                  height: 40.w,
                  width: 40.w,
                  onTap: () {
                    if (isVisit) {
                      if (isSubscribe.value) {
                        Get.offAll(() => BottomBar());
                      } else {
                        Get.offAll(() => const SubscriptionPlan(isVisit: true));
                      }
                    } else {
                      Get.back();
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 25.h),
            ConstText('Rate_Us_desc', fontFamily: 'B', fontSize: 30.sp, color: whiteColor),
            SizedBox(height: 37.h),
            Image.asset("assets/png/rateUs.png", width: MediaQuery.sizeOf(context).width, height: 442.h),
            SizedBox(height: 50.h),
            ConstButton(
              onTap: () async {
                await Apis.lunchApp(rateApp);
              },
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              icon: ConstText('Rate_Us', fontFamily: 'M', fontSize: 22.sp, color: whiteColor),
            ),
          ],
        ),
      ),
    );
  }
}

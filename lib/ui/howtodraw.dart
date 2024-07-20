import 'package:drawing_sketch/ads/ads.dart';
import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HowToDraw extends GetView {
  const HowToDraw({super.key, this.fromImg = true});

  final bool fromImg;

  @override
  Widget build(BuildContext context) {
    final String step1Text = (fromImg ? "Step1Image" : "Step1Text");
    final String step3Text = (fromImg ? "Step3Image" : "Step3Text");
    final String step1Image = (fromImg ? "assets/png/step1Image.png" : "assets/png/step1Text.png");
    final String step3Image = (fromImg ? "assets/png/step3Image.png" : "assets/png/step3Text.png");
    return Scaffold(
      appBar: AppBar(
        title: const ConstText('How_To_Draw', fontFamily: "B"),
        leading: ConstSvg(
          "assets/svg/back.svg",
          height: 24.w,
          width: 24.w,
          fit: BoxFit.scaleDown,
          color: blackColor,
          onTap: () {
            Get.back();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ApplovinAds.showNativeAds(200),
              SizedBox(height: 5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 144.w,
                    width: 144.w,
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(30.r),
                      image: DecorationImage(
                        image: AssetImage(step1Image),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConstText("${"STEP".tr} 1", fontFamily: "B", fontSize: 18.sp, textAlign: TextAlign.start, color: pinkColor),
                        SizedBox(height: 10.h),
                        ConstText(step1Text, color: blackColor, textAlign: TextAlign.start, fontSize: 12.sp),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConstText("${"STEP".tr} 2", fontFamily: "B", fontSize: 18.sp, textAlign: TextAlign.start, color: pinkColor),
                        SizedBox(height: 10.h),
                        ConstText("Step2Image", color: blackColor, textAlign: TextAlign.start, fontSize: 12.sp),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Container(
                    height: 144.w,
                    width: 144.w,
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(30.r),
                      image: const DecorationImage(
                        image: AssetImage("assets/png/step2Image.png"),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 144.w,
                    width: 144.w,
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: BorderRadius.circular(30.r),
                      image: DecorationImage(
                        image: AssetImage(step3Image),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConstText("${"STEP".tr} 3", fontFamily: "B", fontSize: 18.sp, textAlign: TextAlign.start, color: pinkColor),
                        SizedBox(height: 10.h),
                        ConstText(step3Text, color: blackColor, textAlign: TextAlign.start, fontSize: 12.sp),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

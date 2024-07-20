import 'package:drawing_sketch/ads/ads.dart';
import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/static/apis.dart';
import 'package:drawing_sketch/ui/starting/boardingscreen.dart';
import 'package:drawing_sketch/ui/HtmlViewer.dart';
import 'package:drawing_sketch/widgets/button.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class GetStartScreen extends GetView {
  const GetStartScreen({super.key});

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
            Container(height: 77.h),
            if (Apis.isMobile(context)) Image.asset("assets/png/start.png", width: MediaQuery.sizeOf(context).width),
            if (Apis.isTab(context)) Image.asset("assets/png/start.png", width: MediaQuery.sizeOf(context).width, height: MediaQuery.sizeOf(context).width / 1.5),
            SizedBox(height: 43.h),
            ConstText('Get_Started_title', fontFamily: 'B', fontSize: 28.sp, color: whiteColor),
            ConstText('Get_Started_desc', padding: EdgeInsets.symmetric(horizontal: 24.w), color: whiteColor, maxLines: 2),
            SizedBox(height: 79.h),
            ConstButton(
              onTap: () {
                Get.offAll(() => BoardingScreen());
              },
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              icon: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ConstText('Get_Started', fontFamily: 'M', fontSize: 22.sp, color: whiteColor),
                  const ConstSvg('assets/svg/arrows.svg'),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                    onTap: () {
                      Get.to(() => HtmlViewer(title: 'Terms_condition', data: terms));
                    },
                    child: ConstText('Terms_condition', fontSize: 12.sp, color: whiteColor)),
                InkWell(
                    onTap: () {
                      Get.to(() => HtmlViewer(title: 'Privacy_policy', data: privacy));
                    },
                    child: ConstText('Privacy_policy', fontSize: 12.sp, color: whiteColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

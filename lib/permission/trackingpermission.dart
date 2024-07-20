import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/constant/extension.dart';
import 'package:drawing_sketch/static/apis.dart';
import 'package:drawing_sketch/widgets/button.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class TrackingPermission extends StatelessWidget {
  const TrackingPermission({super.key});

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Image.asset("assets/png/tracking_permission.png", color: whiteColor, height: 222.w, width: 222.w),
            SizedBox(height: 30.h),
            ConstText("${"Tracking".tr} ${"permission_needed".tr}", fontFamily: 'B', fontSize: 22.sp, color: whiteColor),
            SizedBox(height: 30.h),
            ConstText(
              "permission_tracking",
              fontFamily: 'M',
              color: whiteColor,
              padding: EdgeInsets.all(10.r),
            ),
            Spacer(),
            ConstButton(
              height: 56.w,
              text: "Continue",
              onTap: () async {
                await Apis.requestPermission(context, type: PerType.Tracking, isVisit: true);
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

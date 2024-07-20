import 'package:drawing_sketch/ads/ads.dart';
import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/localization/changeLanguage.dart';
import 'package:drawing_sketch/static/apis.dart';
import 'package:drawing_sketch/subscription/config.dart';
import 'package:drawing_sketch/subscription/subscription.dart';
import 'package:drawing_sketch/ui/HtmlViewer.dart';
import 'package:drawing_sketch/ui/howtodraw.dart';
import 'package:drawing_sketch/ui/rateus.dart';
import 'package:drawing_sketch/widgets/button.dart';
import 'package:drawing_sketch/widgets/class.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class SettingScreen extends GetView {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ConstText('Settings', fontFamily: "SB"),
        actions: const [ConstPro()],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 13.h),
            Container(
              width: MediaQuery.sizeOf(context).width,
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Column(
                children: [
                  ConstTile(title: 'Change_Language', svg: "assets/svg/language.svg", color: const Color(0xff19DFC4), onTap: () => Get.to(() => const ChangeLanguage())),
                  Divider(color: borderColor, indent: 10.w, endIndent: 10.w, thickness: 1.h),
                  ConstTile(title: 'How_To_Use', svg: "assets/svg/info.svg", color: const Color(0xff31C8FD), onTap: () => Get.to(() => const HowToDraw())),
                  Obx(() {
                    return Visibility(
                        visible: !isSubscribe.value,
                        child: Column(
                          children: [
                            Divider(color: borderColor, indent: 10.w, endIndent: 10.w, thickness: 1.h),
                            ConstTile(title: 'Remove_Ads', svg: "assets/svg/ads.svg", color: const Color(0xffFC6A51), onTap: () => Get.to(() => const SubscriptionPlan())),
                          ],
                        ));
                  }),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: MediaQuery.sizeOf(context).width,
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 10.h),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Column(
                children: [
                  ConstTile(title: 'Privacy_policy', svg: "assets/svg/privacy.svg", color: const Color(0xff43DB6D), onTap: () => Get.to(() => HtmlViewer(title: "Privacy_policy", data: privacy))),
                  Divider(color: borderColor, indent: 10.w, endIndent: 10.w, thickness: 1.h),
                  ConstTile(title: 'Terms_condition', svg: "assets/svg/terms.svg", color: const Color(0xffF86EF1), onTap: () => Get.to(() => HtmlViewer(title: "Terms_condition", data: terms))),
                  Divider(color: borderColor, indent: 10.w, endIndent: 10.w, thickness: 1.h),
                  ConstTile(
                    title: 'Rate_Us',
                    svg: "assets/svg/rate.svg",
                    color: const Color(0xffAC6EF8),
                    onTap: () => Get.to(() => const RateUsScreen()),
                  ),
                  Divider(color: borderColor, indent: 10.w, endIndent: 10.w, thickness: 1.h),
                  ConstTile(
                      title: 'Share_app',
                      svg: "assets/svg/share.svg",
                      color: const Color(0xffFFB43F),
                      onTap: () async {
                        if (Apis.isTab(context)) {
                          await Share.share("AR Draw Trace - Sketch & Paint \n${shareApp}",
                              sharePositionOrigin: Rect.fromLTWH(0, 0, MediaQuery.sizeOf(context).width, MediaQuery.sizeOf(context).height / 2));
                        } else {
                          await Share.share("AR Draw Trace - Sketch & Paint \n${shareApp}");
                        }
                      }),
                  Divider(color: borderColor, indent: 10.w, endIndent: 10.w, thickness: 1.h),
                  ConstTile(
                      title: 'More_App',
                      svg: "assets/svg/more.svg",
                      color: const Color(0xff6985E8),
                      onTap: () async {
                        await Apis.lunchApp(moreApp);
                      }),
                ],
              ),
            ),
            SizedBox(height: 13.h),
            ConstText("${"Version".tr} ${appVersion}", fontSize: 13.sp, color: blackColor),
            SizedBox(height: 13.h),
          ],
        ),
      ),
    );
  }
}

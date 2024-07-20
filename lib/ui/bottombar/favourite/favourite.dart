import 'package:drawing_sketch/ads/ads.dart';
import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/getcontroller/favouritecontroller.dart';
import 'package:drawing_sketch/storages/storages.dart';
import 'package:drawing_sketch/subscription/config.dart';
import 'package:drawing_sketch/subscription/subscription.dart';
import 'package:drawing_sketch/storages/sqflite.dart';
import 'package:drawing_sketch/editsection/previewscreen.dart';
import 'package:drawing_sketch/widgets/alertdialog.dart';
import 'package:drawing_sketch/widgets/button.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class FavouriteCollection extends GetView {
  FavouriteCollection({super.key});

  final FavouriteController fc = Get.put(FavouriteController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ConstText('Favourite', fontFamily: "B"),
        actions: const [ConstPro()],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Obx(() {
              return Visibility(
                visible: !isSubscribe.value,
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.sizeOf(context).width,
                  margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 9.h),
                  decoration: BoxDecoration(color: blackColor, borderRadius: BorderRadius.circular(18.r)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset('assets/png/free.png', height: 50.w, width: 68.w),
                      RichText(
                        text: TextSpan(
                          text: "Try_the".tr,
                          style: TextStyle(fontSize: 16.sp),
                          children: [
                            TextSpan(text: " FREE".tr, style: TextStyle(fontSize: 16.sp, fontFamily: "B", color: pinkColor)),
                            TextSpan(text: " Full".tr, style: TextStyle(fontSize: 16.sp, fontFamily: "B")),
                            TextSpan(text: " PRO".tr, style: TextStyle(fontSize: 16.sp, fontFamily: "B", color: pinkColor)),
                            TextSpan(text: " Version".tr, style: TextStyle(fontSize: 16.sp)),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),
                      InkWell(
                        onTap: () {
                          Get.to(() => const SubscriptionPlan());
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 33.h,
                          width: 97.w,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: whiteColor)),
                          child: ConstText("Try_For_Free", fontSize: 12.sp, fontFamily: "B", color: whiteColor),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            ApplovinAds.showBannerAds(),
            SizedBox(height: 8.h),
            Obx(() {
              if (fc.videoList.isEmpty) {
                return SizedBox(
                  height: MediaQuery.sizeOf(context).height / 1.5,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConstSvg("assets/svg/rate.svg", color: pinkColor.withOpacity(.7), height: 50.w, width: 50.w, fit: BoxFit.cover),
                        SizedBox(height: 15.h),
                        ConstText('empty'.tr.replaceAll('xxx', 'Favourite'.tr), fontSize: 16.sp, fontFamily: 'SB'),
                      ],
                    ),
                  ),
                );
              }
              return GridView.builder(
                itemCount: fc.videoList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 157.w / 157.w, crossAxisSpacing: 10.w, mainAxisSpacing: 10.h),
                itemBuilder: (context, index) {
                  final FavouriteModel items = fc.videoList[index];
                  return InkWell(
                    onTap: () async {
                      if (items.type.contains('paid') && !isSubscribe.value) {
                        // this url set to when user click ad close button and navigate to preview screen
                        if (showAds.value) {
                          Storages.remove('url');
                          await Storages.write('url', items.image);
                          showAdsOption();
                        } else {
                          Get.to(() => const SubscriptionPlan());
                        }
                      } else {
                        Get.to(() => PreviewScreen(url: items.image));
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ConstCached(
                          items.image,
                          width: MediaQuery.sizeOf(context).width,
                          height: MediaQuery.sizeOf(context).height,
                          radius: 20.r,
                          fit: BoxFit.scaleDown,
                        ),
                        Positioned(
                          top: 5.h,
                          right: 5.w,
                          child: ConstFavButton(image: items.image, aid: items.aid, cid: items.cid, title: items.title, type: items.type),
                        ),
                        if (items.type.contains('paid')) Positioned(top: 10.h, left: 15.w, child: ConstSvg("assets/svg/premium.svg", width: 19.w, height: 19.w, fit: BoxFit.cover, color: pinkColor)),
                      ],
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

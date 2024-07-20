import 'package:drawing_sketch/ads/ads.dart';
import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/editsection/photoTosketch.dart';
import 'package:drawing_sketch/editsection/previewscreen.dart';
import 'package:drawing_sketch/editsection/texteditscreen.dart';
import 'package:drawing_sketch/getcontroller/commoncontroller.dart';
import 'package:drawing_sketch/static/apis.dart';
import 'package:drawing_sketch/storages/storages.dart';
import 'package:drawing_sketch/subscription/config.dart';
import 'package:drawing_sketch/subscription/subscription.dart';
import 'package:drawing_sketch/ui/category/allcategory.dart';
import 'package:drawing_sketch/ui/category/singlecategory.dart';
import 'package:drawing_sketch/widgets/alertdialog.dart';
import 'package:drawing_sketch/widgets/button.dart';
import 'package:drawing_sketch/widgets/class.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

class HomeScreen extends GetView {
  HomeScreen({super.key});

  final CommonController cc = Get.put(CommonController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ConstText('Home_title', fontFamily: "B"),
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
                  height: 58.h,
                  margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 9.h),
                  decoration: BoxDecoration(color: blackColor, borderRadius: BorderRadius.circular(18.r)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset('assets/png/free.png'),
                      RichText(
                        text: TextSpan(
                          text: "Try_the".tr,
                          style: TextStyle(fontSize: 12.sp, fontFamily: "B"),
                          children: [
                            TextSpan(text: " FREE".tr, style: TextStyle(fontSize: 12.sp, fontFamily: "B", color: pinkColor)),
                            TextSpan(text: " Full".tr, style: TextStyle(fontSize: 12.sp, fontFamily: "B")),
                            TextSpan(text: "\nPRO".tr, style: TextStyle(fontSize: 12.sp, fontFamily: "B", color: pinkColor)),
                            TextSpan(text: " Version".tr, style: TextStyle(fontSize: 12.sp, fontFamily: "B")),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Get.to(() => const SubscriptionPlan());
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 33.h,
                          width: 97.w,
                          decoration: BoxDecoration(color: pinkColor, borderRadius: BorderRadius.circular(8.r)),
                          child: ConstText("Try_For_Free", fontSize: 12.sp, fontFamily: "B", color: whiteColor),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            if (Apis.isMobile(context))
              InkWell(
                onTap: () async {
                  await ApplovinAds.showInterAds();
                  Get.to(() => AllCategories());
                },
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.sizeOf(context).width,
                  height: 111.w,
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/png/girl_paint.png"),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ConstText("Start_Drawing", fontSize: 18.sp, fontFamily: "B", color: whiteColor),
                            ConstText("Just_Tap_And_Draw", fontSize: 10.sp, color: whiteColor),
                            Container(
                              alignment: Alignment.center,
                              height: 25.h,
                              width: 58.w,
                              margin: EdgeInsets.only(top: 10.h),
                              decoration: BoxDecoration(color: whiteColor, borderRadius: BorderRadius.circular(8.r)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ConstText("Start", fontSize: 12.sp, fontFamily: "B", color: pinkColor),
                                  ConstSvg("assets/svg/arrow_forward.svg", color: pinkColor, width: 17.w, height: 17.w),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (Apis.isTab(context))
              InkWell(
                onTap: () async {
                  await ApplovinAds.showInterAds();
                  Get.to(() => AllCategories());
                },
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).width / 3.5,
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/png/girl_paint.png"),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ConstText("Start_Drawing", fontSize: 18.sp, fontFamily: "B", color: whiteColor),
                            ConstText("Just_Tap_And_Draw", fontSize: 10.sp, color: whiteColor),
                            Container(
                              alignment: Alignment.center,
                              height: 25.h,
                              width: 58.w,
                              margin: EdgeInsets.only(top: 10.h),
                              decoration: BoxDecoration(color: whiteColor, borderRadius: BorderRadius.circular(8.r)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ConstText("Start", fontSize: 12.sp, fontFamily: "B", color: pinkColor),
                                  ConstSvg("assets/svg/arrow_forward.svg", color: pinkColor, width: 17.w, height: 17.w),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 15.h),
            if (Apis.isMobile(context))
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () async {
                      await ApplovinAds.showInterAds();
                      Get.to(() => const TextEditScreen());
                    },
                    child: Container(
                      alignment: Alignment.topCenter,
                      height: 125.w,
                      width: 165.w,
                      padding: EdgeInsets.only(top: 17.h),
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage("assets/png/text_sketch.png"),
                        ),
                      ),
                      child: ConstText("Text_To_Sketch", fontSize: 16.sp, fontFamily: "SB", color: whiteColor),
                    ),
                  ),
                  SizedBox(width: 5.w),
                  InkWell(
                    onTap: () {
                      if (isSubscribe.value) {
                        Get.to(() => const PhotoToSketch());
                      } else {
                        Get.to(() => const SubscriptionPlan());
                      }
                    },
                    child: Container(
                      alignment: Alignment.topCenter,
                      height: 125.w,
                      width: 165.w,
                      padding: EdgeInsets.only(top: 17.h),
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage("assets/png/photo_sketch.png"),
                        ),
                      ),
                      child: ConstText("Photo_To_Sketch", fontSize: 16.sp, fontFamily: "SB", color: whiteColor),
                    ),
                  ),
                ],
              ),
            if (Apis.isTab(context))
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        await ApplovinAds.showInterAds();
                        Get.to(() => const TextEditScreen());
                      },
                      child: Container(
                        alignment: Alignment.topCenter,
                        height: MediaQuery.sizeOf(context).width / 4,
                        padding: EdgeInsets.only(top: 17.h),
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/png/text_sketch.png"),
                          ),
                        ),
                        child: ConstText("Text_To_Sketch", fontSize: 16.sp, fontFamily: "SB", color: whiteColor),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (isSubscribe.value) {
                          Get.to(() => const PhotoToSketch());
                        } else {
                          Get.to(() => const SubscriptionPlan());
                        }
                      },
                      child: Container(
                        alignment: Alignment.topCenter,
                        height: MediaQuery.sizeOf(context).width / 4,
                        padding: EdgeInsets.only(top: 17.h),
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/png/photo_sketch.png"),
                          ),
                        ),
                        child: ConstText("Photo_To_Sketch", fontSize: 16.sp, fontFamily: "SB", color: whiteColor),
                      ),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 20.h),
            Obx(() {
              if (cc.categories.isEmpty) {
                return const SizedBox.shrink();
              }
              return AnimationLimiter(
                child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cc.categories.length,
                    itemBuilder: (context, index) {
                      final data = cc.categories[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        child: SlideAnimation(
                          verticalOffset: 50,
                          duration: const Duration(milliseconds: 375),
                          child: FadeInAnimation(
                            curve: Curves.easeIn,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    ConstText(
                                      data['category_name'],
                                      fontSize: 16.sp,
                                      fontFamily: "SB",
                                      color: blackColor,
                                      textAlign: TextAlign.start,
                                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Get.to(() => SingleCategory(cid: data['cid'], title: data['category_name'], length: int.parse(data['total_records'])));
                                      },
                                      child: ConstText(
                                        "See_All",
                                        fontSize: 12.sp,
                                        color: pinkColor,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 130.h,
                                  child: FutureBuilder(
                                      future: cc.getSingleCategory(cid: data['cid']),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return ConstShimmer(length: int.parse(data['total_records']), scrollDirection: Axis.horizontal);
                                        }
                                        if (snapshot.data!.isEmpty) {
                                          return Center(child: ConstText('empty'.tr.replaceAll('xxx', data['category_name']), fontSize: 18.sp, fontFamily: 'SB'));
                                        }
                                        return ListView.separated(
                                          itemCount: snapshot.data!.take(5).length,
                                          shrinkWrap: true,
                                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {
                                            final item = snapshot.data![index];
                                            return Stack(
                                              alignment: Alignment.topRight,
                                              children: [
                                                ConstCached(
                                                  item['image'],
                                                  width: 130.w,
                                                  height: 130.w,
                                                  radius: 20.r,
                                                  fit: BoxFit.scaleDown,
                                                  onTap: () async {
                                                    if (item['type'].toString().contains('paid') && !isSubscribe.value) {
                                                      // this url set to when user click ad close button and navigate to preview screen
                                                      if (showAds.value) {
                                                        Storages.remove('url');
                                                        await Storages.write('url', item['image']);
                                                        showAdsOption();
                                                      } else {
                                                        Get.to(() => const SubscriptionPlan());
                                                      }
                                                    } else {
                                                      Get.to(() => PreviewScreen(url: item['image']));
                                                    }
                                                  },
                                                ),
                                                if (item['type'].toString().contains('paid'))
                                                  Positioned(top: 10.h, right: 10.w, child: ConstSvg("assets/svg/premium.svg", width: 15.w, height: 15.w, fit: BoxFit.cover, color: pinkColor)),
                                              ],
                                            );
                                          },
                                          separatorBuilder: (context, index) => SizedBox(width: 5.w),
                                        );
                                      }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => SizedBox(height: 10.h)),
              );
            }),
            SizedBox(height: 10.h),
          ],
        ),
      ),
      bottomNavigationBar: ApplovinAds.showBannerAds(),
    );
  }
}

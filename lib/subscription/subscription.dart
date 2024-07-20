import 'package:drawing_sketch/ads/ads.dart';
import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/subscription/config.dart';
import 'package:drawing_sketch/ui/HtmlViewer.dart';
import 'package:drawing_sketch/localization/changeLanguage.dart';
import 'package:drawing_sketch/widgets/button.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class SubscriptionPlan extends StatefulWidget {
  const SubscriptionPlan({super.key, this.isVisit = false});

  final bool isVisit;

  @override
  State<SubscriptionPlan> createState() => _SubscriptionPlanState();
}

class _SubscriptionPlanState extends State<SubscriptionPlan> {
  final RxInt selectedIndex = 0.obs;

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    if (Config.products.isEmpty) {
      await Config.getAllProducts();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("assets/png/SplashScreen.png"),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(height: 60.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 34.w),
                      Image.asset("assets/png/girl.png", width: 260.w, height: 260.w),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: ConstSvg(
                          "assets/svg/close.svg",
                          color: whiteColor.withOpacity(.7),
                          height: 40.w,
                          width: 40.w,
                          onTap: () {
                            if (widget.isVisit) {
                              Get.offAll(() => const ChangeLanguage(isVisit: true));
                            } else {
                              Get.back();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  ConstText("Upgrade_To_Premium", fontFamily: "EB", fontSize: 20.sp, textAlign: TextAlign.start, color: pinkColor),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ConstSvg("assets/svg/done.svg", width: 20.w, height: 20.w),
                            SizedBox(width: 15.w),
                            ConstText("feature1", fontFamily: "M", textAlign: TextAlign.start, color: pinkColor, fontSize: 14.sp),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            ConstSvg("assets/svg/done.svg", width: 20.w, height: 20.w),
                            SizedBox(width: 15.w),
                            ConstText("feature2", fontFamily: "M", textAlign: TextAlign.start, color: pinkColor, fontSize: 14.sp),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Obx(() {
                    if (Config.isLoadPlan.value) {
                      return AnimationLimiter(
                        child: ListView.separated(
                          itemCount: 3,
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(vertical: 18.h),
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (context, index) => SizedBox(height: 8.h),
                          itemBuilder: (context, index) {
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              child: SlideAnimation(
                                verticalOffset: 50,
                                duration: const Duration(milliseconds: 375),
                                child: FadeInAnimation(
                                  curve: Curves.easeIn,
                                  child: Shimmer.fromColors(
                                    baseColor: borderColor,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      height: 71.h,
                                      width: MediaQuery.sizeOf(context).width,
                                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                                      margin: EdgeInsets.only(left: 20.w, right: 20.w),
                                      decoration: BoxDecoration(border: Border.all(color: pinkColor), borderRadius: BorderRadius.circular(20.r)),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(color: whiteColor, height: 20.h),
                                                Container(color: whiteColor, height: 10.h, margin: EdgeInsets.symmetric(vertical: 8.h)),
                                              ],
                                            ),
                                          ),
                                          Icon(Icons.radio_button_unchecked, color: blackColor, size: 25.h),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                    if (Config.products.isEmpty) {
                      return Center(
                        child: ConstText(
                          'empty'.tr.replaceAll('xxx', 'Subscription'.tr),
                          fontSize: 18.sp,
                          fontFamily: 'SB',
                          color: blackColor,
                          padding: EdgeInsets.all(20.h),
                        ),
                      );
                    }
                    return AnimationLimiter(
                      child: ListView.separated(
                        itemCount: Config.products.length,
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(vertical: 18.h),
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) => SizedBox(height: 8.h),
                        itemBuilder: (cont, index) {
                          final product = Config.products[index];
                          final bool isPopular = product.identifier.contains('month');
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50,
                              child: FadeInAnimation(
                                curve: Curves.easeIn,
                                child: Obx(() {
                                  return Stack(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          selectedIndex.value = index;
                                        },
                                        child: Container(
                                          height: 71.h,
                                          width: MediaQuery.sizeOf(context).width,
                                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                                          margin: EdgeInsets.only(left: 20.w, right: 20.w, top: isPopular ? 10.h : 0),
                                          decoration: BoxDecoration(border: Border.all(color: pinkColor), borderRadius: BorderRadius.circular(20.r)),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  ConstText("${product.priceString} / ${product.title}", fontFamily: "SB", textAlign: TextAlign.start, maxLines: 1, fontSize: 16.sp),
                                                  ConstText(product.description, fontSize: 12.sp, textAlign: TextAlign.start, maxLines: 2),
                                                ],
                                              ),
                                              if (selectedIndex.value == index)
                                                ConstSvg("assets/svg/done.svg", height: 23.w, width: 23.w)
                                              else
                                                Icon(Icons.radio_button_unchecked, color: blackColor, size: 25.h),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (isPopular)
                                        Positioned(
                                          left: 40.w,
                                          top: 0.h,
                                          child: Container(
                                            height: 23.h,
                                            width: 88.w,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(color: pinkColor, borderRadius: BorderRadius.circular(20.r)),
                                            child: ConstText('Most_Popular', fontFamily: 'M', color: whiteColor, fontSize: 11.sp),
                                          ),
                                        ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  Obx(() {
                    return ConstButton(
                      enable: Config.products.isNotEmpty,
                      onTap: () async {
                        await Config.buySubscription(context, item: Config.products[selectedIndex.value], isVisit: widget.isVisit);
                      },
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      icon: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const ConstText('Start_For_Free', fontFamily: 'M', color: whiteColor),
                          ConstText('Cancel_Anytime', fontFamily: 'R', color: greyColor.withOpacity(0.3), fontSize: 13.sp),
                        ],
                      ),
                    );
                  }),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: InkWell(
                            onTap: () {
                              Get.to(() => HtmlViewer(title: 'Terms_condition', data: terms));
                            },
                            child: ConstText('Terms_condition', fontSize: 12.sp, color: blackColor, padding: EdgeInsets.all(10.h), maxLines: 2)),
                      ),
                      Expanded(child: InkWell(onTap: Config.restoreSubscription, child: ConstText('Restore', fontSize: 12.sp, color: blackColor, padding: EdgeInsets.all(10.h)))),
                      Expanded(
                        child: InkWell(
                            onTap: () {
                              Get.to(() => HtmlViewer(title: 'Privacy_policy', data:privacy));
                            },
                            child: ConstText('Privacy_policy', fontSize: 12.sp, color: blackColor, padding: EdgeInsets.all(10.h), maxLines: 2)),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h)
                ],
              ),
            ),
          ),
          Obx(() {
            if (!Config.isPurchasing.value) {
              return const SizedBox.shrink();
            }
            return Container(
              alignment: Alignment.center,
              height: MediaQuery.sizeOf(context).height,
              width: MediaQuery.sizeOf(context).width,
              color: whiteColor.withOpacity(0.4),
              child: const CircularProgressIndicator(color: themeColor),
            );
          }),
        ],
      ),
    );
  }
}

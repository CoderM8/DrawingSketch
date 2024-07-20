import 'package:drawing_sketch/ads/ads.dart';
import 'package:drawing_sketch/static/apis.dart';
import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/getcontroller/commoncontroller.dart';
import 'package:drawing_sketch/editsection/previewscreen.dart';
import 'package:drawing_sketch/ui/category/singlecategory.dart';
import 'package:drawing_sketch/widgets/button.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AllCategories extends GetView {
  AllCategories({super.key});

  final CommonController cc = Get.find<CommonController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ConstText('Drawing', fontFamily: "B"),
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
        actions: const [ConstPro()],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 22.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      await Apis.pickImage(source: ImageSource.gallery).then((url) async {
                        if (url != null) {
                          await Apis.cropImage(fileTest: url).then((value) {
                            if (value != null) {
                              Get.to(() => PreviewScreen(url: value.path, isFile: true));
                            }
                          });
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 20.w),
                      padding: EdgeInsets.only(top: 15.h, left: 13.w, bottom: 15.h),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Row(
                        children: [
                          Image.asset("assets/png/gallery.png", width: 40.w, height: 40.h),
                          SizedBox(width: 5.w),
                          RichText(
                            text: TextSpan(text: "Image_From".tr, style: TextStyle(color: blackColor, fontFamily: "B", fontSize: 16.sp), children: [
                              TextSpan(
                                text: "\n${"Gallery".tr}",
                                style: TextStyle(color: blackColor, fontSize: 12.sp, fontFamily: "R"),
                              ),
                            ]),
                            textScaler: const TextScaler.linear(1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      await Apis.pickImage(source: ImageSource.camera).then((url) async {
                        if (url != null) {
                          await Apis.cropImage(fileTest: url).then((value) {
                            if (value != null) {
                              Get.to(() => PreviewScreen(url: value.path, isFile: true));
                            }
                          });
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 20.w),
                      padding: EdgeInsets.only(top: 15.h, left: 13.w, bottom: 15.h),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Row(
                        children: [
                          Image.asset("assets/png/camera.png", width: 40.w, height: 40.h),
                          SizedBox(width: 5.w),
                          RichText(
                            text: TextSpan(text: "Image_From".tr, style: TextStyle(color: blackColor, fontFamily: "B", fontSize: 16.sp), children: [
                              TextSpan(
                                text: "\n${"Camera".tr}",
                                style: TextStyle(color: blackColor, fontSize: 12.sp, fontFamily: "R"),
                              ),
                            ]),
                            textScaler: const TextScaler.linear(1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            ApplovinAds.showBannerAds(),
            SizedBox(height: 30.h),
            Align(alignment: Alignment.centerLeft, child: ConstText('Categories', fontFamily: "B", padding: EdgeInsets.only(left: 20.w))),
            Obx(() {
              if (cc.categories.isEmpty) {
                return Center(child: ConstText('empty'.tr.replaceAll('xxx', 'Categories'.tr), fontSize: 18.sp, fontFamily: 'SB'));
              }
              return AnimationLimiter(
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cc.categories.length,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10.w, mainAxisSpacing: 12.h, childAspectRatio: 105.w / 127.h),
                  itemBuilder: (context, index) {
                    final data = cc.categories[index];
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      columnCount: 3,
                      child: SlideAnimation(
                        verticalOffset: 50,
                        duration: const Duration(milliseconds: 375),
                        child: FadeInAnimation(
                          curve: Curves.easeIn,
                          child: InkWell(
                            onTap: () {
                              Get.to(() => SingleCategory(cid: data['cid'], title: data['category_name'], length: int.parse(data['total_records'])));
                            },
                            child: Column(
                              children: [
                                Expanded(child: ConstCached(data['category_image'], radius: 20.r, fit: BoxFit.scaleDown)),
                                SizedBox(height: 5.h),
                                ConstText(data['category_name'], fontFamily: "M", fontSize: 14.sp, maxLines: 1),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

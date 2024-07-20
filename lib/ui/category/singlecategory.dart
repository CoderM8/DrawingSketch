import 'package:drawing_sketch/ads/ads.dart';
import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/getcontroller/commoncontroller.dart';
import 'package:drawing_sketch/storages/storages.dart';
import 'package:drawing_sketch/subscription/config.dart';
import 'package:drawing_sketch/editsection/previewscreen.dart';
import 'package:drawing_sketch/subscription/subscription.dart';
import 'package:drawing_sketch/widgets/alertdialog.dart';
import 'package:drawing_sketch/widgets/button.dart';
import 'package:drawing_sketch/widgets/class.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

class SingleCategory extends GetView {
  SingleCategory({super.key, required this.cid, required this.title, required this.length});

  final String cid;
  final String title;
  final int length;
  final CommonController cc = Get.find<CommonController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ConstText(title, fontFamily: "B"),
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
      body: FutureBuilder<List>(
          future: cc.getSingleCategory(cid: cid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ConstShimmer(length: length);
            }
            if (snapshot.data!.isEmpty) {
              return Center(child: ConstText('empty'.tr.replaceAll('xxx', title), fontSize: 18.sp, fontFamily: 'SB'));
            }
            if (!isSubscribe.value && showAds.value) {
              return AnimationLimiter(
                child: GridView.custom(
                  shrinkWrap: true,
                  gridDelegate: SliverStairedGridDelegate(
                      pattern: List.generate(
                    snapshot.data!.length,
                    (index) {
                      if (index == 4) {
                        return StairedGridTile(1, 1.2);
                      } else {
                        return StairedGridTile(.5, 1);
                      }
                    },
                  )),
                  childrenDelegate: SliverChildBuilderDelegate(childCount: snapshot.data!.length, (context, index) {
                    if ((index + 1) % 5 == 0 && (index - (index ~/ 5)) == 4) {
                      return ApplovinAds.showNativeAds(200);
                    } else {
                      final data = snapshot.data![index - index ~/ 5];
                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        columnCount: 2,
                        child: SlideAnimation(
                          verticalOffset: 50,
                          duration: const Duration(milliseconds: 375),
                          child: FadeInAnimation(
                            curve: Curves.easeIn,
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    if (data['type'].toString().contains('paid') && !isSubscribe.value) {
                                      // this url set to when user click ad close button and navigate to preview screen
                                      if (showAds.value) {
                                        Storages.remove('url');
                                        await Storages.write('url', data['image']);
                                        showAdsOption();
                                      } else {
                                        Get.to(() => const SubscriptionPlan());
                                      }
                                    } else {
                                      Get.to(() => PreviewScreen(url: data['image']));
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(8.w),
                                    child: ConstCached(
                                      data['image'],
                                      radius: 20.r,
                                      height: MediaQuery.of(context).size.height,
                                      width: MediaQuery.of(context).size.width,
                                      fit: BoxFit.scaleDown,
                                    ),
                                  ),
                                ),
                                Positioned(
                                    top: 15.h,
                                    right: 15.w,
                                    child: ConstFavButton(
                                      title: data['iteam_name'],
                                      aid: data['aid'],
                                      cid: data['cat_id'],
                                      image: data['image'],
                                      type: data['type'],
                                    )),
                                if (data['type'].toString().contains('paid'))
                                  Positioned(top: 15.h, left: 15.w, child: ConstSvg("assets/svg/premium.svg", width: 25.w, height: 25.w, fit: BoxFit.scaleDown, color: pinkColor)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  }),
                ),
              );
            } else {
              return AnimationLimiter(
                child: GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 15.r, vertical: 15.h),
                    physics: const BouncingScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10.w, mainAxisSpacing: 10.h, childAspectRatio: 83.w / 83.w),
                    itemBuilder: (context, index) {
                      final data = snapshot.data![index];
                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        columnCount: 2,
                        child: SlideAnimation(
                          verticalOffset: 50,
                          duration: const Duration(milliseconds: 375),
                          child: FadeInAnimation(
                            curve: Curves.easeIn,
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (data['type'].toString().contains('paid') && !isSubscribe.value) {
                                      Get.to(() => const SubscriptionPlan());
                                    } else {
                                      Get.to(() => PreviewScreen(url: data['image']));
                                    }
                                  },
                                  child: ConstCached(
                                    data['image'],
                                    radius: 20.r,
                                    height: MediaQuery.of(context).size.height,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.scaleDown,
                                  ),
                                ),
                                Positioned(
                                    top: 10.h,
                                    right: 15.w,
                                    child: ConstFavButton(
                                      title: data['iteam_name'],
                                      aid: data['aid'],
                                      cid: data['cat_id'],
                                      image: data['image'],
                                      type: data['type'],
                                    )),
                                if (data['type'].toString().contains('paid'))
                                  Positioned(top: 10.h, left: 15.w, child: ConstSvg("assets/svg/premium.svg", width: 19.w, height: 19.w, fit: BoxFit.cover, color: pinkColor)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              );
            }
          }),
    );
  }
}

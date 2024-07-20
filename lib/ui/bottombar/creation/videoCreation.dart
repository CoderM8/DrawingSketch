import 'dart:io';

import 'package:drawing_sketch/ads/ads.dart';
import 'package:drawing_sketch/static/apis.dart';
import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/getcontroller/videocreationcontroller.dart';
import 'package:drawing_sketch/player/player.dart';
import 'package:drawing_sketch/storages/sqflite.dart';
import 'package:drawing_sketch/widgets/button.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class VideoCreation extends GetView {
  VideoCreation({super.key});

  final CreationController cc = Get.put(CreationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ConstText('Creation', fontFamily: "B"),
        actions: const [ConstPro()],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 5.h),
            ApplovinAds.showBannerAds(),
            SizedBox(height: 5.h),
            Obx(() {
              if (cc.videoList.isEmpty) {
                return SizedBox(
                  height: MediaQuery.sizeOf(context).height / 1.5,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConstSvg("assets/svg/magic.svg", color: pinkColor.withOpacity(.7), height: 50.w, width: 50.w, fit: BoxFit.cover),
                        SizedBox(height: 15.h),
                        ConstText('empty'.tr.replaceAll('xxx', 'Creation'.tr), fontSize: 16.sp, fontFamily: 'SB'),
                      ],
                    ),
                  ),
                );
              }
              List<Widget> groupedMessages = [];

              Apis.groupByDateList<VideoModel, String>(cc.videoList, (value) {
                return Apis.getWhen(date: DateTime.parse(value.createdAt));
              }).forEach((when, videos) {
                groupedMessages.add(
                  ConstText(when, fontFamily: 'M', color: blackColor, padding: EdgeInsets.only(bottom: 10.h), textAlign: TextAlign.start),
                );
                groupedMessages.add(GridView.builder(
                  itemCount: videos.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 107.w / 107.w, crossAxisSpacing: 7.w, mainAxisSpacing: 10.h),
                  itemBuilder: (context, index) {
                    return Obx(() {
                      return InkWell(
                        onTap: () {
                          if (cc.deleteMulti.isEmpty) {
                            Get.to(() => PlayVideo(path: videos[index].path));
                          } else {
                            if (!cc.deleteMulti.contains(videos[index].id)) {
                              cc.deleteMulti.add(videos[index].id);
                            } else {
                              cc.deleteMulti.remove(videos[index].id);
                            }
                          }
                        },
                        onLongPress: cc.deleteMulti.isNotEmpty
                            ? null
                            : () {
                                cc.deleteMulti.clear();
                                cc.deleteMulti.add(videos[index].id);
                              },
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          height: MediaQuery.sizeOf(context).height,
                          decoration: BoxDecoration(
                            color: pinkColor,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: pinkColor),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: FileImage(File(videos[index].image)),
                              opacity: cc.deleteMulti.contains(videos[index].id) ? 0.4 : 1,
                            ),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            height: 40.w,
                            width: 40.w,
                            child: cc.deleteMulti.contains(videos[index].id) ? Icon(Icons.check_circle_outline, color: whiteColor, size: 40.h) : Icon(Icons.play_circle, color: whiteColor, size: 40.h),
                          ),
                        ),
                      );
                    });
                  },
                ));
              });
              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                children: groupedMessages,
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() {
        if (cc.deleteMulti.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          height: 70.h,
          color: whiteColor,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Obx(() {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.r), side: BorderSide(width: 1.w, color: pinkColor)),
                        side: BorderSide(width: 1.w, color: pinkColor),
                        value: cc.isSelectedAll.value,
                        onChanged: (check) {
                          cc.isSelectedAll.value = check!;
                          if (check) {
                            for (final video in cc.videoList) {
                              if (!cc.deleteMulti.contains(video.id)) {
                                cc.deleteMulti.add(video.id);
                              }
                            }
                          } else {
                            cc.deleteMulti.clear();
                          }
                        }),
                    ConstText(cc.isSelectedAll.value ? "Selected" : 'Select_All', color: pinkColor, fontSize: 16.sp, fontFamily: 'M'),
                  ],
                );
              }),
              InkWell(
                onTap: () async {
                  for (final id in cc.deleteMulti) {
                    await DatabaseHelper.removeVideo(id);
                    cc.videoList.removeWhere((element) => element.id == id);
                  }
                  cc.deleteMulti.clear();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.delete, color: pinkColor),
                    ConstText('Delete', color: pinkColor, fontSize: 16.sp, fontFamily: 'M'),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

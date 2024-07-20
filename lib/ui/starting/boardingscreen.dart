import 'package:drawing_sketch/ads/ads.dart';
import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/getcontroller/boardingcontroller.dart';
import 'package:drawing_sketch/static/apis.dart';
import 'package:drawing_sketch/storages/storages.dart';
import 'package:drawing_sketch/ui/HtmlViewer.dart';
import 'package:drawing_sketch/ui/rateus.dart';
import 'package:drawing_sketch/widgets/button.dart';
import 'package:drawing_sketch/widgets/class.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class BoardingScreen extends GetView {
  BoardingScreen({super.key});

  final BoardingController bc = Get.put(BoardingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
            Expanded(
              child: PageView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: bc.board.length,
                controller: bc.pageController,
                onPageChanged: (page) {
                  bc.currentIndex.value = page;
                },
                itemBuilder: (context, index) {
                  final Boarding board = bc.board[index];
                  return Column(
                    children: [
                      SizedBox(height: 77.h),
                      Image.asset(board.img, height: 436.h, width: MediaQuery.sizeOf(context).width),
                      SizedBox(height: 30.h),
                      ConstText(
                        board.title,
                        color: whiteColor,
                        maxLines: 2,
                        padding: EdgeInsets.symmetric(horizontal: Apis.isTab(context) ? 30.w : 23.w),
                      ),
                    ],
                  );
                },
              ),
            ),

            /// BUTTON
            Obx(() {
              bc.currentIndex.value;
              return ConstButton(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                icon: Row(
                  children: [
                    const Spacer(flex: 3),
                    ConstText('Continue', fontFamily: 'M', fontSize: 22.sp, color: whiteColor),
                    const Spacer(flex: 2),
                    ConstSvg("assets/svg/arrow_forward.svg", width: 39.w, height: 39.w),
                  ],
                ),
                onTap: bc.last()
                    ? () async {
                        await Storages.write('new', false);
                        Get.offAll(() => const RateUsScreen(isVisit: true));
                      }
                    : bc.next,
              );
            }),
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
            SizedBox(height: 20.h)
          ],
        ),
      ),
    );
  }
}

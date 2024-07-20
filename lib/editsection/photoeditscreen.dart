import 'dart:io';
import 'package:drawing_sketch/widgets/bottomsheet.dart';

import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/widgets/button.dart';
import 'package:drawing_sketch/widgets/imagefilter.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class OptionScreen extends StatefulWidget {
  const OptionScreen({super.key, required this.url});

  final File url;

  @override
  State<OptionScreen> createState() => _OptionScreenState();
}

class _OptionScreenState extends State<OptionScreen> {
  final RxBool isDefault = true.obs;
  final RxBool isPro = false.obs;
  late File selectedFile;

  @override
  void initState() {
    selectedFile = widget.url;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ConstText("Photo_To_Sketch", fontFamily: "B"),
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
      body: Obx(() {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              height: 435.h,
              width: MediaQuery.sizeOf(context).width,
              alignment: Alignment.center,
              margin: EdgeInsets.all(28.w),
              child: Image.file(selectedFile),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ConstButton(
                  icon: ConstText('Default', fontSize: 16.sp, fontFamily: 'SB', color: whiteColor),
                  height: 55.h,
                  width: 143.w,
                  radius: 53.r,
                  color: isDefault.value ? pinkColor : pinkColor.withOpacity(0.4),
                  onTap: () {
                    isDefault.value = !isDefault.value;
                    if (isDefault.value) {
                      selectedFile = widget.url;
                      isPro.value = false;
                    }
                  },
                ),
                ConstButton(
                  icon: ConstText('Black_White', fontSize: 16.sp, fontFamily: 'SB', color: whiteColor),
                  height: 55.h,
                  width: 143.w,
                  radius: 53.r,
                  color: isPro.value ? pinkColor : pinkColor.withOpacity(0.4),
                  onTap: () async {
                    isPro.value = !isPro.value;
                    final File? xFile = await Get.to(() => PhotoFilter(image: selectedFile));
                    if (xFile != null) {
                      selectedFile = xFile;
                    }
                    if (isPro.value) {
                      isDefault.value = false;
                    }
                  },
                ),
              ],
            ),
            ConstButton(
                icon: ConstText('Next', fontSize: 18.sp, fontFamily: 'SB', color: whiteColor),
                height: 60.h,
                color: pinkColor,
                onTap: () {
                  selectOption(context, selectedFile.path, isFile: true);
                }),
          ],
        );
      }),
    );
  }
}

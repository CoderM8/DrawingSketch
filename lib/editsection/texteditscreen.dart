import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/subscription/config.dart';
import 'package:drawing_sketch/subscription/subscription.dart';
import 'package:drawing_sketch/storages/storages.dart';
import 'package:drawing_sketch/editsection/previewscreen.dart';
import 'package:drawing_sketch/widgets/button.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TextEditScreen extends StatefulWidget {
  const TextEditScreen({super.key});

  @override
  State<TextEditScreen> createState() => _TextEditScreenState();
}

class _TextEditScreenState extends State<TextEditScreen> {
  final RxDouble fontSize = 22.0.obs;
  final RxInt fontIndex = 0.obs;
  final TextEditingController textEditingController = TextEditingController();

  /// CHANGE ALSO [apis.dart] (style)
  final RxList fontList = [
    {"value": GoogleFonts.inter, "type": "free"}, // 0
    {"value": GoogleFonts.parisienne, "type": "paid"}, // 1
    {"value": GoogleFonts.tiltNeon, "type": "paid"}, // 2
    {"value": GoogleFonts.bungeeSpice, "type": "paid"}, // 3
    {"value": GoogleFonts.rye, "type": "free"}, // 4
    {"value": GoogleFonts.rubikMonoOne, "type": "free"}, // 5
    {"value": GoogleFonts.bungeeShade, "type": "paid"}, // 6
    {"value": GoogleFonts.alike, "type": "free"}, // 7
    {"value": GoogleFonts.carterOne, "type": "paid"}, // 8
    {"value": GoogleFonts.protestGuerrilla, "type": "free"}, //9
  ].obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ConstText('Text_To_Sketch', fontFamily: "B"),
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                return Container(
                  height: 200.h,
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(15.r),
                    border: Border.all(color: pinkColor),
                  ),
                  child: TextFormField(
                    controller: textEditingController,
                    textAlign: TextAlign.center,
                    maxLines: 7,
                    cursorColor: blackColor,
                    style: fontList[fontIndex.value]['value'](color: blackColor, fontSize: fontSize.value.sp, fontWeight: FontWeight.bold),
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: "Enter_Your_Text".tr,
                      hintStyle: TextStyle(color: blackColor.withOpacity(0.3), fontFamily: "EB", fontSize: 30.sp),
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                );
              }),
              SizedBox(height: 20.h),
              ConstText("Select_Text_Size", fontFamily: "SB", fontSize: 16.sp),
              SizedBox(height: 10.h),
              Container(
                decoration: BoxDecoration(color: whiteColor, borderRadius: BorderRadius.circular(10.r)),
                child: Obx(() {
                  return SliderTheme(
                    data: SliderThemeData(
                      thumbColor: pinkColor,
                      trackHeight: 3,
                      activeTrackColor: pinkColor,
                      inactiveTrackColor: blackColor.withOpacity(0.3),
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.r),
                    ),
                    child: Slider(
                      value: fontSize.value,
                      max: 50,
                      min: 20,
                      onChanged: (value) {
                        fontSize.value = value;
                      },
                    ),
                  );
                }),
              ),
              SizedBox(height: 20.h),
              ConstText("Select_Font", fontFamily: "SB", fontSize: 16.sp),
              SizedBox(height: 15.h),
              GridView.builder(
                shrinkWrap: true,
                itemCount: fontList.length,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8.w, mainAxisSpacing: 8.h, childAspectRatio: 100.w / 40.w),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      if (fontList[index]['type'].toString().contains('paid') && !isSubscribe.value) {
                        Get.to(() => const SubscriptionPlan());
                      } else {
                        fontIndex.value = index;
                      }
                      FocusManager.instance.primaryFocus!.unfocus();
                    },
                    child: Obx(() {
                      return Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            width: MediaQuery.sizeOf(context).width,
                            height: MediaQuery.sizeOf(context).height,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: fontIndex.value == index ? pinkColor : whiteColor, borderRadius: BorderRadius.circular(10.r)),
                            child: ConstText(
                              "HELLO",
                              style: fontList[index]['value'](color: fontIndex.value == index ? whiteColor : blackColor, fontSize: 18.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (fontList[index]['type'].toString().contains('paid'))
                            Positioned(
                              left: 13.w,
                              child: ConstSvg("assets/svg/premium.svg", width: 19.w, height: 19.w, fit: BoxFit.cover, color: fontIndex.value == index ? whiteColor : pinkColor),
                            ),
                        ],
                      );
                    }),
                  );
                },
              ),
              SizedBox(height: 15.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: ConstButton(
          text: "Continue",
          height: 60.h,
          color: pinkColor,
          onTap: () async {
            if (textEditingController.text.isNotEmpty) {
              FocusManager.instance.primaryFocus!.unfocus();
              await Storages.remove('style');
              await Storages.write('style', {"index": fontIndex.value, "font": fontSize.value});
              Get.to(() => PreviewScreen(url: textEditingController.text, isText: true));
            }
          },
        ),
      ),
    );
  }
}

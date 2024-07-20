import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/getcontroller/favouritecontroller.dart';
import 'package:drawing_sketch/subscription/config.dart';
import 'package:drawing_sketch/subscription/subscription.dart';
import 'package:drawing_sketch/storages/sqflite.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ConstButton extends StatelessWidget {
  const ConstButton(
      {super.key, this.text = '', this.onTap, this.height, this.width, this.color, this.textColor, this.enable = true, this.border = false, this.icon, this.padding = EdgeInsets.zero, this.radius});

  final String text;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final Color? color;
  final Color? textColor;
  final Widget? icon;
  final double? radius;
  final bool enable;
  final bool border;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: !enable ? null : onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        height: height ?? 70.h,
        width: width ?? MediaQuery.sizeOf(context).width,
        padding: padding,
        margin: EdgeInsets.only(bottom: 10.h, right: 18.w, left: 18.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: border
              ? null
              : enable
                  ? color ?? blackColor
                  : blackColor.withOpacity(0.4),
          border: border ? Border.all(color: Colors.black) : null,
          borderRadius: BorderRadius.circular(radius ?? 20.r),
        ),
        child: icon ?? ConstText(text.tr, color: textColor ?? whiteColor, fontFamily: "M"),
      ),
    );
  }
}

class ConstFavButton extends StatelessWidget {
  const ConstFavButton({super.key, required this.title, required this.aid, required this.cid, required this.image, required this.type});

  final String title;
  final String aid;
  final String cid;
  final String image;
  final String type;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: DatabaseHelper.isFavourite(aid),
        builder: (context, snapshot) {
          RxBool isFavourite = (snapshot.data != null && snapshot.data == true).obs;
          return Obx(() {
            return InkWell(
              onTap: () async {
                final FavouriteController fc = Get.find<FavouriteController>();
                if (isFavourite.value) {
                  await DatabaseHelper.removeFavourite(aid);
                  isFavourite.value = false;
                  fc.videoList.removeWhere((element) => element.aid == aid);
                } else {
                  final int id = await DatabaseHelper.addFavourite(FavouriteModel(
                    title: title,
                    image: image,
                    cid: cid,
                    aid: aid,
                    type: type,
                    createdAt: DateTime.now().toString(),
                  ));
                  if (!fc.videoList.toString().contains(id.toString())) {
                    fc.videoList.insert(0, FavouriteModel(id: id, title: title, image: image, cid: cid, aid: aid, type: type, createdAt: DateTime.now().toString()));
                  }
                  isFavourite.value = true;
                }
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: isFavourite.value
                  ? ConstSvg("assets/svg/rate.svg", height: 24.w, width: 24.w, color: pinkColor, fit: BoxFit.cover)
                  : ConstSvg("assets/svg/star_outline.svg", height: 24.w, width: 24.w, color: pinkColor, fit: BoxFit.cover),
            );
          });
        });
  }
}

class ConstPro extends StatelessWidget {
  const ConstPro({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Visibility(
        visible: !isSubscribe.value,
        child: InkWell(
          onTap: () {
            Get.to(() => const SubscriptionPlan());
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            alignment: Alignment.center,
            height: 40.h,
            padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
            margin: EdgeInsets.all(15.h),
            decoration: BoxDecoration(
                color: pinkColor, borderRadius: BorderRadius.circular(35.r), boxShadow: [BoxShadow(color: pinkColor.withOpacity(0.3), spreadRadius: 6, blurRadius: 6, offset: const Offset(0.0, 3))]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstSvg("assets/svg/premium.svg", width: 18.w, height: 18.w, fit: BoxFit.scaleDown),
                SizedBox(width: 2.w),
                ConstText("PRO", color: whiteColor, fontFamily: "SB", fontSize: 14.sp, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    });
  }
}

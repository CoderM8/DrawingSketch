import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class Boarding {
  final String title;
  final String img;

  Boarding({required this.title, required this.img});
}

class ConstShimmer extends GetView {
  const ConstShimmer({super.key, required this.length, this.scrollDirection = Axis.vertical});

  final int length;
  final Axis scrollDirection;

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: GridView.builder(
        padding: scrollDirection == Axis.vertical ? EdgeInsets.symmetric(horizontal: 15.r, vertical: 15.h) : EdgeInsets.symmetric(horizontal: 20.w),
        physics: const BouncingScrollPhysics(),
        itemCount: length,
        scrollDirection: scrollDirection,
        gridDelegate: scrollDirection == Axis.vertical
            ? SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10.w, mainAxisSpacing: 10.h, childAspectRatio: 83.w / 83.w)
            : SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, crossAxisSpacing: 5.w, mainAxisSpacing: 5.h, childAspectRatio: 130.w / 130.w),
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            columnCount: scrollDirection == Axis.vertical ? 2 : 1,
            child: SlideAnimation(
              verticalOffset: 50,
              duration: const Duration(milliseconds: 375),
              child: ScaleAnimation(
                duration: const Duration(milliseconds: 800),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r), color: whiteColor),
                  alignment: Alignment.center,
                  child: Shimmer.fromColors(
                    baseColor: borderColor,
                    highlightColor: Colors.grey.shade100,
                    child: Icon(Icons.image, color: themeColor, size: 30.h),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ConstTile extends StatelessWidget {
  const ConstTile({super.key, required this.title, required this.svg, this.onTap, required this.color});

  final String title;
  final String svg;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: ConstText(title, fontFamily: "M", textAlign: TextAlign.start, fontSize: 15.sp),
      leading: Container(
        height: 40.w,
        width: 40.w,
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8.r)),
        child: ConstSvg(svg, width: 22.w, height: 22.w, color: whiteColor, fit: BoxFit.scaleDown),
      ),
      trailing: ConstSvg("assets/svg/arrow_forward.svg", width: 25.w, height: 25.w, color: borderColor),
      onTap: onTap,
    );
  }
}

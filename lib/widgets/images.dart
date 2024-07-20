import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/constant/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

class ConstSvg extends StatelessWidget {
  const ConstSvg(this.path, {super.key, this.type = SvgType.assets, this.fit = BoxFit.contain, this.height, this.width, this.color, this.onTap});

  final SvgType type;
  final String path;
  final double? height;
  final double? width;
  final Color? color;
  final VoidCallback? onTap;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case SvgType.file:
        return InkWell(onTap: onTap, child: SvgPicture.file(File(path), height: height, width: width, color: color, fit: fit));
      case SvgType.network:
        return InkWell(onTap: onTap, child: SvgPicture.network(path, height: height, width: width, color: color, fit: fit));
      case SvgType.assets:
        return InkWell(onTap: onTap, child: SvgPicture.asset(path, height: height, width: width, color: color, fit: fit));
    }
  }
}

class ConstCached extends StatelessWidget {
  const ConstCached(this.path, {super.key, this.fit = BoxFit.contain, this.height, this.width, this.color, this.circle = false, this.radius, this.onTap});

  final String path;
  final double? height;
  final double? width;
  final Color? color;
  final BoxFit fit;
  final bool circle;
  final double? radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: path,
      fit: BoxFit.cover,
      height: height ?? 200.w,
      width: width ?? 200.w,
      imageBuilder: (context, image) => InkWell(
        onTap: onTap,
        child: Container(
          height: height ?? 200.w,
          width: width ?? 200.w,
          decoration: circle
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: whiteColor,
                  image: DecorationImage(image: image, fit: fit),
                )
              : BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(radius ?? 8.r),
                  image: DecorationImage(image: image, fit: fit),
                ),
        ),
      ),
      placeholder: (context, url) => Container(
        height: height ?? 200.w,
        width: width ?? 200.w,
        alignment: Alignment.center,
        decoration: circle ? const BoxDecoration(shape: BoxShape.circle, color: whiteColor) : BoxDecoration(borderRadius: BorderRadius.circular(radius ?? 8.r), color: whiteColor),
        child: Shimmer.fromColors(
          baseColor: borderColor,
          highlightColor: Colors.grey.shade100,
          child: const Icon(Icons.image, color: themeColor),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: height ?? 200.w,
        width: width ?? 200.w,
        decoration: circle ? const BoxDecoration(shape: BoxShape.circle, color: whiteColor) : BoxDecoration(borderRadius: BorderRadius.circular(radius ?? 8.r), color: whiteColor),
        child: const Icon(Icons.error_outline, color: blackColor),
      ),
    );
  }
}

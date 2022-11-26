import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  final Object? shape;
  final double? size;
  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final double? radius;
  final Color? baseColor;
  final Color? highlightColor;
  final Color? shimmerColor;
  final Color? backgroundColor;

  const ShimmerWidget({
    Key? key,
    this.shape,
    this.size,
    this.width,
    this.height,
    this.margin,
    this.radius = 6,
    this.baseColor,
    this.highlightColor,
    this.shimmerColor,
    this.backgroundColor,
  }) : super(key: key);

  const ShimmerWidget.rectangle({
    Key? key,
    this.size,
    this.width,
    this.height,
    this.margin,
    this.radius = 6,
    this.baseColor,
    this.highlightColor,
    this.shimmerColor,
    this.backgroundColor,
  })  : shape = BoxShape.rectangle,
        super(key: key);

  const ShimmerWidget.circle({
    Key? key,
    this.size,
    this.width,
    this.height,
    this.margin,
    this.baseColor,
    this.highlightColor,
    this.shimmerColor,
    this.backgroundColor,
  })  : shape = BoxShape.circle,
        radius = null,
        super(key: key);

  const ShimmerWidget.expand({
    Key? key,
    this.shape,
    this.margin,
    this.radius = 6,
    this.baseColor,
    this.highlightColor,
    this.shimmerColor,
    this.backgroundColor,
  })  : size = double.infinity,
        height = double.infinity,
        width = double.infinity,
        super(key: key);

  const ShimmerWidget.square({
    Key? key,
    this.shape,
    this.margin,
    this.size,
    this.radius = 6,
    this.baseColor,
    this.highlightColor,
    this.shimmerColor,
    this.backgroundColor,
  })  : height = size,
        width = size,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Color shimmerColor = this.shimmerColor ?? Theme.of(context).dividerColor;
    Color backgroundColor = this.backgroundColor ?? Theme.of(context).cardColor;
    BorderRadius? kBorderRadius = radius == null ? null : BorderRadius.circular(radius!);

    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        period: const Duration(milliseconds: 750),
        baseColor: baseColor ?? shimmerColor.withOpacity(.75),
        highlightColor: highlightColor ?? shimmerColor.withOpacity(.325),
        child: DecoratedBox(
          decoration: shape == null
              ? BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: kBorderRadius,
                  color: backgroundColor,
                )
              : shape is BoxShape
                  ? BoxDecoration(
                      shape: shape as BoxShape,
                      borderRadius:
                          shape == BoxShape.circle ? null : kBorderRadius,
                      color: backgroundColor,
                    )
                  : ShapeDecoration(
                      shape: shape as ShapeBorder,
                      color: backgroundColor,
                    ),
          child: SizedBox(width: width, height: height),
        ),
      ),
    );
  }
}

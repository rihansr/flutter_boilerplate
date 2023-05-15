import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  final Object? shape;
  final num? size;
  final num? width;
  final num? height;
  final EdgeInsets? margin;
  final num? radius;
  final Color? baseColor;
  final Color? highlightColor;
  final Color? shimmerColor;
  final Color? backgroundColor;

  const ShimmerWidget({
    Key? key,
    this.shape = const StadiumBorder(),
    this.size,
    width,
    height,
    this.margin,
    this.radius,
    this.baseColor,
    this.highlightColor,
    this.shimmerColor,
    this.backgroundColor,
  })  : width = width ?? size,
        height = height ?? size,
        super(key: key);

  const ShimmerWidget.rectangle({
    Key? key,
    this.size,
    width,
    height,
    this.margin,
    this.radius = 6,
    this.baseColor,
    this.highlightColor,
    this.shimmerColor,
    this.backgroundColor,
  })  : shape = BoxShape.rectangle,
        width = width ?? size,
        height = height ?? size,
        super(key: key);

  const ShimmerWidget.circle({
    Key? key,
    this.size,
    this.margin,
    this.baseColor,
    this.highlightColor,
    this.shimmerColor,
    this.backgroundColor,
  })  : shape = BoxShape.circle,
        height = size,
        width = size,
        radius = null,
        super(key: key);

  const ShimmerWidget.expand({
    Key? key,
    this.shape,
    this.margin,
    this.radius,
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
    this.radius,
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
    BorderRadius? kBorderRadius =
        radius == null ? null : BorderRadius.circular(radius!.toDouble());

    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        period: const Duration(milliseconds: 750),
        baseColor: baseColor ?? shimmerColor.withOpacity(.5),
        highlightColor: highlightColor ?? shimmerColor.withOpacity(.25),
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
          child: SizedBox(
            width: width?.toDouble(),
            height: height?.toDouble(),
          ),
        ),
      ),
    );
  }
}

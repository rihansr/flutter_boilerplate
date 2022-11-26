import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ButtonWidget<T> extends StatelessWidget {
  final T? shape;
  final Color? fillColor;
  final Color borderTint;
  final double borderSize;
  final double radius;
  final double? width;
  final double? height;
  final TextStyle? labelStyle;
  final Color? fontColor;
  final FontWeight? fontWeight;
  final String? label;
  final double contentSpacing;
  final bool dense;
  final double? minFontSize;
  final double? fontSize;
  final int maxLines;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Axis direction;
  final bool disable;
  final bool loading;
  final WrapAlignment horizontalAlignment;
  final WrapAlignment verticalAlignment;
  final WrapCrossAlignment wrapCrossAlignment;
  final Function()? onPressed;

  const ButtonWidget({
    Key? key,
    this.shape,
    this.label,
    this.fillColor,
    this.borderTint = Colors.transparent,
    this.radius = 6,
    this.width,
    this.height,
    this.labelStyle,
    this.fontColor,
    this.dense = false,
    this.fontSize,
    this.leading,
    this.trailing,
    this.fontWeight,
    this.margin = const EdgeInsets.symmetric(vertical: 8),
    this.padding = const EdgeInsets.all(16),
    this.contentSpacing = 0,
    this.minFontSize,
    this.maxLines = 1,
    this.borderSize = 1,
    this.direction = Axis.horizontal,
    this.disable = false,
    this.loading = false,
    this.horizontalAlignment = WrapAlignment.center,
    this.verticalAlignment = WrapAlignment.center,
    this.wrapCrossAlignment = WrapCrossAlignment.center,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextStyle labelStyle = (this.labelStyle ?? theme.textTheme.button)!.copyWith(
      color: fontColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
    return InkWell(
      onTap: disable || loading ? null : onPressed,
      radius: radius,
      child: Container(
        width: width,
        height: height,
        margin: dense ? EdgeInsets.zero : margin,
        padding: padding,
        decoration: shape == null
            ? ShapeDecoration(
                shape: StadiumBorder(
                  side: BorderSide(
                    color: borderTint,
                    width: borderSize,
                  ),
                ),
                color: fillColor ?? theme.colorScheme.secondary,
              )
            : shape is BoxShape
                ? BoxDecoration(
                    shape: shape as BoxShape,
                    borderRadius: shape == BoxShape.circle
                        ? null
                        : BorderRadius.circular(radius),
                    color: fillColor ?? theme.colorScheme.secondary,
                  )
                : ShapeDecoration(
                    shape: shape as ShapeBorder,
                    color: fillColor ?? theme.colorScheme.secondary,
                  ),
        child: Wrap(
          direction: direction,
          spacing: contentSpacing,
          runSpacing: contentSpacing,
          alignment: horizontalAlignment,
          runAlignment: verticalAlignment,
          crossAxisAlignment: wrapCrossAlignment,
          children: loading
              ? [
                  SpinKitThreeBounce(
                    size: (labelStyle.fontSize ?? 18) * 1.2,
                    color: labelStyle.color,
                  )
                ]
              : [
                  if (leading != null)
                    Padding(
                      padding: EdgeInsets.only(
                        right:
                            direction == Axis.horizontal ? contentSpacing : 0,
                        bottom: direction == Axis.vertical ? contentSpacing : 0,
                      ),
                      child: leading,
                    ),
                  if (label != null)
                    Text(
                      label!,
                      textAlign: TextAlign.center,
                      maxLines: maxLines,
                      overflow: TextOverflow.ellipsis,
                      style: labelStyle,
                    ),
                  if (trailing != null)
                    Padding(
                      padding: EdgeInsets.only(
                        top: direction == Axis.vertical ? contentSpacing : 0,
                        left: direction == Axis.horizontal ? contentSpacing : 0,
                      ),
                      child: trailing,
                    ),
                ],
        ),
      ),
    );
  }
}

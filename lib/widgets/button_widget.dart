import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Button<T> extends StatelessWidget {
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
  final double? minFontSize;
  final double? fontSize;
  final int? maxLines;
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

  const Button({
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
    this.fontSize,
    this.leading,
    this.trailing,
    this.fontWeight,
    this.margin = const EdgeInsets.symmetric(vertical: 8),
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    this.contentSpacing = 8,
    this.minFontSize,
    this.maxLines,
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
    TextStyle labelStyle =
        (this.labelStyle ?? theme.textTheme.button)!.copyWith(
      color: disable ? Theme.of(context).textTheme.subtitle1?.color : fontColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );

    Color? fillColor = disable
        ? Theme.of(context).disabledColor
        : this.fillColor ?? Theme.of(context).primaryColor;

    return Padding(
      padding: margin,
      child: InkWell(
        onTap: disable || loading ? null : onPressed,
        radius: radius,
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          height: height,
          width: width,
          padding: padding,
          decoration: shape == null
              ? ShapeDecoration(
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: borderTint,
                      width: borderSize,
                    ),
                  ),
                  color: fillColor,
                )
              : shape is BoxShape
                  ? BoxDecoration(
                      shape: shape as BoxShape,
                      borderRadius: shape == BoxShape.circle
                          ? null
                          : BorderRadius.circular(radius),
                      color: fillColor,
                    )
                  : ShapeDecoration(
                      shape: shape as ShapeBorder,
                      color: fillColor,
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
                    SizedBox(
                      width: labelStyle.fontSize! * 2.175,
                      child: SpinKitThreeBounce(
                        size: labelStyle.fontSize! * 1.45,
                        color: labelStyle.color,
                      ),
                    )
                  ]
                : [
                    if (leading != null) leading!,
                    if (label != null)
                      Text(
                        label!,
                        textAlign: TextAlign.center,
                        maxLines: maxLines,
                        overflow: TextOverflow.ellipsis,
                        style: labelStyle,
                      ),
                    if (trailing != null) trailing!,
                  ],
          ),
        ),
      ),
    );
  }
}

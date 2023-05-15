import 'package:flutter/material.dart';
import 'card_tile_widget.dart';
import '../shared/strings.dart';
import '../shared/styles.dart';

class TitleBar extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final int? maxLines;
  final Color? fontColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextStyle? textStyle;
  final Color? fillColor;
  final Color borderTint;
  final double? borderSize;
  final double? iconSize;
  final double? leadingIconSize;
  final Color? iconTint;
  final Color? leadingIconTint;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double horizontalSpacing;
  final double verticalSpacing;
  final double? topSpacing;
  final double? leftSpacing;
  final double? rightSpacing;
  final double? bottomSpacing;
  final dynamic leading;
  final dynamic trailing;
  final TextStyle? trailingStyle;
  final bool hide;
  final double? elevation;
  final Function()? onTapTile;
  final Function()? onTapTrailing;

  const TitleBar({
    Key? key,
    this.title,
    this.titleWidget,
    this.maxLines,
    this.fontColor,
    this.fontSize,
    this.fontWeight,
    this.textStyle,
    this.fillColor,
    this.borderTint = Colors.transparent,
    this.borderSize,
    this.iconSize,
    this.leadingIconSize,
    this.iconTint,
    this.leadingIconTint,
    this.margin,
    this.padding,
    this.horizontalSpacing = 0,
    this.verticalSpacing = 0,
    this.topSpacing,
    this.leftSpacing,
    this.rightSpacing,
    this.bottomSpacing,
    this.leading,
    this.trailing,
    this.hide = false,
    this.elevation,
    this.trailingStyle,
    this.onTapTile,
    this.onTapTrailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Visibility(
      visible: !hide,
      maintainAnimation: true,
      maintainState: true,
      child: CardTile(
        onTap: onTapTile,
        margin: margin ??
            EdgeInsets.fromLTRB(
              leftSpacing ?? horizontalSpacing,
              topSpacing ?? verticalSpacing,
              rightSpacing ?? horizontalSpacing,
              bottomSpacing ?? verticalSpacing,
            ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
        elevation: elevation,
        tileColor: fillColor,
        border: borderSize != null
            ? Border.all(
                color: borderTint,
                width: borderSize ?? 1,
              )
            : null,
        leading: leading != null
            ? leading is String
                ? style.image(
                    leading!,
                    size: leadingIconSize ?? iconSize ?? theme.iconTheme.size,
                    color: leadingIconTint ?? iconTint ?? theme.iconTheme.color,
                    fit: BoxFit.contain,
                  )
                : leading is Widget
                    ? leading
                    : null
            : null,
        title: titleWidget ??
            (title != null
                ? Text(
                    title ?? '',
                    textAlign: TextAlign.start,
                    maxLines: maxLines,
                    overflow: maxLines == null ? null : TextOverflow.ellipsis,
                    style: (textStyle ?? theme.textTheme.titleLarge)!.copyWith(
                      color: fontColor,
                      fontWeight: fontWeight,
                      fontSize: fontSize,
                    ),
                  )
                : null),
        trailing: onTapTrailing != null || trailing != null
            ? GestureDetector(
                onTap: onTapTrailing,
                child: trailing is Widget
                    ? trailing
                    : Text(
                        trailing ?? string(context).viewAll,
                        style: trailingStyle ??
                            theme.textTheme.bodyMedium!.copyWith(
                              color: theme.colorScheme.onSecondary,
                            ),
                      ),
              )
            : null,
      ),
    );
  }
}

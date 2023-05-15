import 'package:flutter/material.dart';
import '../shared/icons.dart';

class CustomizedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color? backgroundColor;
  final IconData? leading;
  final double iconSize;
  final Color? iconTint;
  final Color? iconBackground;
  final IconData? trailing;
  final dynamic title;
  final dynamic subtitle;
  final bool centerTitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final Color? fontColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Widget? titleWidget;
  final bool automaticallyImplyLeading;
  final Function()? onTapLeading;
  final bool isCartPage;
  final double? elevation;
  final List<Widget>? actions;
  final Function()? onTapTrailing;

  const CustomizedAppBar({
    Key? key,
    this.leading,
    this.iconSize = 24,
    this.iconTint,
    this.iconBackground,
    this.trailing,
    this.backgroundColor,
    this.title,
    this.subtitle,
    this.centerTitle = true,
    this.titleStyle,
    this.subtitleStyle,
    this.fontColor,
    this.fontSize,
    this.fontWeight,
    this.titleWidget,
    this.automaticallyImplyLeading = true,
    this.onTapLeading,
    this.isCartPage = false,
    this.elevation,
    this.actions,
    this.onTapTrailing,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: elevation,
      centerTitle: centerTitle,
      titleSpacing: 0,
      backgroundColor: backgroundColor ?? theme.colorScheme.background,
      leading: automaticallyImplyLeading || leading != null
          ? AppBarIconButton(
              icon: leading ?? AppIcons.arrow_back,
              size: iconSize,
              background: iconBackground,
              tint: iconBackground,
              onTap: () => onTapLeading != null
                  ? onTapLeading?.call()
                  : Navigator.pop(context),
            )
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (title != null)
            title is Widget
                ? title
                : Text(
                    title ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle ?? theme.textTheme.titleLarge,
                  ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: subtitle is Widget
                  ? subtitle
                  : Text(
                      subtitle ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: subtitleStyle ?? theme.textTheme.titleSmall,
                    ),
            ),
        ],
      ),
      actions: actions ??
          (trailing != null
              ? [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: AppBarIconButton(
                      icon: trailing!,
                      size: iconSize,
                      background: iconBackground,
                      tint: iconBackground,
                      onTap: onTapTrailing,
                    ),
                  ),
                ]
              : null),
    );
  }
}

class AppBarIconButton extends StatelessWidget {
  const AppBarIconButton({
    Key? key,
    required this.icon,
    this.size = 24,
    this.radius,
    this.background = Colors.transparent,
    this.tint,
    this.padding = const EdgeInsets.all(8.0),
    this.onTap,
  }) : super(key: key);

  final IconData icon;
  final double size;
  final double? radius;
  final Color? background;
  final Color? tint;
  final EdgeInsets padding;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: background,
        child: IconButton(
          icon: Icon(icon,
              size: size, color: tint ?? Theme.of(context).iconTheme.color),
          padding: padding,
          iconSize: size,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: onTap,
        ),
      ),
    );
  }
}

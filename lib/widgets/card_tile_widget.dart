import 'package:flutter/material.dart';

class CardTile extends StatelessWidget {
  final Color? tileColor;
  final BoxConstraints? constraints;
  final double? height;
  final double? width;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final BoxBorder? border;
  final double radius;
  final double? elevation;
  final Widget? title;
  final Widget? subtitle;
  final Widget? additional;
  final List<Widget> children;
  final Widget? leading;
  final Widget? trailing;
  final double leadingSpace;
  final double trailingSpace;
  final double contentPadding;
  final bool dense;
  final bool denseInside;
  final AlignmentGeometry? alignment;
  final Function()? onTap;

  const CardTile({
    Key? key,
    this.tileColor,
    this.constraints,
    this.height,
    this.width,
    this.border,
    this.radius = 8,
    this.margin = const EdgeInsets.all(10),
    this.padding = const EdgeInsets.all(16),
    this.elevation,
    this.title,
    this.subtitle,
    this.additional,
    this.children = const [],
    this.leading,
    this.trailing,
    this.leadingSpace = 16,
    this.trailingSpace = 16,
    this.contentPadding = 16,
    this.dense = false,
    this.denseInside = false,
    this.alignment,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      radius: radius,
      child: Container(
        constraints: constraints,
        height: height,
        width: width,
        margin: dense ? null : margin,
        padding: denseInside ? null : padding,
        clipBehavior: Clip.antiAlias,
        alignment: alignment,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          border: border,
          boxShadow: elevation == null
              ? null
              : [
                  BoxShadow(
                    color: theme.shadowColor,
                    offset: const Offset(0, 0),
                    blurRadius: elevation!,
                  )
                ],
          color: tileColor ?? theme.cardColor,
        ),
        child: Row(
          children: [
            if (leading != null) leading!,
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: leading == null ? 0 : leadingSpace,
                  right: trailing == null ? 0 : trailingSpace,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null) title!,
                    if (subtitle != null) ...[
                      if (title != null) SizedBox(height: contentPadding),
                      subtitle!,
                    ],
                    if (additional != null) ...[
                      if ((title ?? subtitle) != null)
                        SizedBox(height: contentPadding),
                      additional!,
                    ],
                    if (children.isNotEmpty) ...[
                      if ((title ?? subtitle ?? additional) != null)
                        SizedBox(height: contentPadding),
                      ...children,
                    ],
                  ],
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

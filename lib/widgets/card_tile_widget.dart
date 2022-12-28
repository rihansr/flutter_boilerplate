import 'package:flutter/material.dart';
import '../utils/extensions.dart';

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
  final double contentSpacing;
  final bool dense;
  final bool denseInside;
  final MainAxisAlignment parentMainAxisAlignment;
  final CrossAxisAlignment parentCrossAxisAlignment;
  final MainAxisSize parentMainAxisSize;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final AlignmentGeometry? alignment;
  final Function()? onTap;

  const CardTile({
    Key? key,
    this.tileColor,
    this.constraints,
    this.height,
    this.width,
    this.border,
    this.radius = 0,
    this.margin = const EdgeInsets.all(10),
    this.padding = const EdgeInsets.all(12),
    this.elevation,
    this.title,
    this.subtitle,
    this.additional,
    this.children = const [],
    this.leading,
    this.trailing,
    this.leadingSpace = 12,
    this.trailingSpace = 12,
    this.contentSpacing = 4,
    this.dense = false,
    this.denseInside = false,
    this.parentMainAxisAlignment = MainAxisAlignment.start,
    this.parentCrossAxisAlignment = CrossAxisAlignment.center,
    this.parentMainAxisSize = MainAxisSize.max,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.mainAxisSize = MainAxisSize.min,
    this.alignment,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      onTap: onTap,
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
                    color: context.theme.shadowColor,
                    offset: const Offset(0, 0),
                    blurRadius: elevation!,
                  )
                ],
          color: tileColor,
        ),
        child: Row(
          crossAxisAlignment: parentCrossAxisAlignment,
          mainAxisAlignment: parentMainAxisAlignment,
          mainAxisSize: parentMainAxisSize,
          children: [
            if (leading != null) leading!,
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: leading == null ? 0 : leadingSpace,
                  right: trailing == null ? 0 : trailingSpace,
                ),
                child: Column(
                  mainAxisAlignment: mainAxisAlignment,
                  crossAxisAlignment: crossAxisAlignment,
                  mainAxisSize: mainAxisSize,
                  children: [
                    if (title != null) title!,
                    if (subtitle != null) ...[
                      if (title != null) SizedBox(height: contentSpacing),
                      subtitle!,
                    ],
                    if (additional != null) ...[
                      if ((title ?? subtitle) != null)
                        SizedBox(height: contentSpacing),
                      additional!,
                    ],
                    if (children.isNotEmpty) ...[
                      if ((title ?? subtitle ?? additional) != null)
                        SizedBox(height: contentSpacing),
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

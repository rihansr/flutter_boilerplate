import 'package:flutter/material.dart';
import '../shared/icons.dart';
import '../utils/extensions.dart';

class DropdownWidget<T> extends StatefulWidget {
  final Color? fillColor;
  final double? width;
  final double? height;
  final Color? fontColor;
  final Color? hintColor;
  final FontWeight? fontWeight;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final String? hint;
  final Widget? hintWidget;
  final int? maxLines;
  final double borderSize;
  final Color? borderTint;
  final Widget? icon;
  final Color? iconColor;
  final bool dense;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double? fontSize;
  final double borderRadius;
  final bool borderFocusable;
  final bool bottomBorderOnly;
  final List<T> items;
  final Widget Function(T)? itemBuilder;
  final Widget Function(T)? selectedItemBuilder;
  final T? value;
  final bool isExpanded;
  final bool maintainState;
  final Function(T)? onSelected;

  const DropdownWidget({
    Key? key,
    this.fillColor,
    this.onSelected,
    this.width,
    this.height,
    this.hint,
    this.maxLines,
    this.borderSize = 1,
    this.borderTint,
    this.value,
    this.items = const [],
    this.itemBuilder,
    this.selectedItemBuilder,
    this.margin = const EdgeInsets.symmetric(vertical: 8),
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.fontSize,
    this.dense = true,
    this.hintWidget,
    this.fontColor,
    this.hintColor,
    this.fontWeight,
    this.textStyle,
    this.hintStyle,
    this.iconColor,
    this.icon,
    this.isExpanded = true,
    this.maintainState = false,
    this.borderRadius = 0,
    this.borderFocusable = true,
    this.bottomBorderOnly = true,
  }) : super(key: key);

  @override
  State<DropdownWidget<T>> createState() => _DropdownWidgetState<T>();
}

class _DropdownWidgetState<T> extends State<DropdownWidget<T>> {
  T? selectedItem;

  @override
  void initState() {
    selectedItem = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Color borderTint = widget.borderFocusable
        ? widget.borderTint ?? theme.dividerColor
        : Colors.transparent;
    return Container(
      width: widget.width,
      padding: widget.padding,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.fillColor ?? context.theme.disabledColor,
        borderRadius: widget.bottomBorderOnly
            ? null
            : BorderRadius.all(Radius.circular(widget.borderRadius)),
        border: widget.bottomBorderOnly
            ? Border(
                bottom: BorderSide(color: borderTint, width: widget.borderSize),
              )
            : Border.all(color: borderTint, width: widget.borderSize),
      ),
      child: DropdownButton(
        menuMaxHeight: widget.height,
        borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
        isDense: widget.dense,
        isExpanded: widget.isExpanded,
        icon: Icon(
          AppIcons.arrow_down,
          color: context.theme.iconTheme.color,
        ),
        iconSize: 16,
        hint: widget.hintWidget ??
            Text(
              widget.hint ?? '',
              maxLines: widget.maxLines,
              style: widget.hintStyle ??
                  context.textTheme.titleMedium?.copyWith(
                    color: widget.hintColor ?? context.theme.hintColor,
                    fontSize: widget.fontSize,
                    fontWeight: widget.fontWeight,
                  ),
            ),
        value: widget.maintainState ? selectedItem : widget.value,
        style: (widget.textStyle ?? context.textTheme.bodyLarge)?.copyWith(
          color: widget.fontColor,
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
        ),
        underline: const SizedBox.shrink(),
        items: widget.itemBuilder == null
            ? null
            : widget.items.map((item) {
                return DropdownMenuItem(
                    value: item, child: widget.itemBuilder!(item));
              }).toList(),
        selectedItemBuilder: widget.selectedItemBuilder == null
            ? null
            : (_) => widget.items.map<Widget>((item) {
                  return Align(
                      alignment: Alignment.centerLeft,
                      child: widget.selectedItemBuilder!(item));
                }).toList(),
        onChanged: (T? item) => {
          if (widget.maintainState) setState(() => selectedItem = item),
          if (item != null) widget.onSelected?.call(item),
        },
      ),
    );
  }
}

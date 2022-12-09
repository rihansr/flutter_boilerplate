import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputWidget extends StatelessWidget {
  final TextEditingController? controller;
  final double? height;
  final double? width;
  final bool autoValidate;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool dense;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextStyle? textStyle;
  final String? hint;
  final String? title;
  final TextStyle? titleStyle;
  final TextAlign titleAlign;
  final EdgeInsets? titleSpacing;
  final String? subtitle;
  final TextStyle? subtitleStyle;
  final TextAlign subtitleAlign;
  final EdgeInsets? subtitleSpacing;
  final bool obscureText;
  final TextAlign textAlign;
  final int? maxCharacters;
  final int maxLines;
  final Widget? prefix;
  final Widget? prefixIcon;
  final Widget? suffix;
  final Widget? suffixIcon;
  final bool typeable;
  final bool selectable;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool borderFocusable;
  final Color? fillColor;
  final Color? borderTint;
  final Color? fontColor;
  final Color? hintColor;
  final TextStyle? hintStyle;
  final TextCapitalization textCapitalization;
  final int lengthFilter;
  final double? borderRadius;
  final bool bottomBorderOnly;
  final bool autoFocus;

  /// Action
  final Function? validator;
  final Function()? onClick;
  final Function()? onTapPrefix;
  final Function()? onTapSuffix;
  final TextInputAction? inputAction;
  final Function(String)? onAction;
  final Function(String?)? onTyping;
  final Function(String?)? onQuery;

  const InputWidget({
    Key? key,
    this.controller,
    this.height,
    this.width,
    this.validator,
    this.onTapSuffix,
    this.autoValidate = true,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.title,
    this.titleAlign = TextAlign.start,
    this.titleStyle,
    this.titleSpacing,
    this.subtitle,
    this.subtitleAlign = TextAlign.start,
    this.subtitleStyle,
    this.subtitleSpacing,
    this.obscureText = false,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.suffixIcon,
    this.typeable = true,
    this.selectable = true,
    this.borderTint,
    this.maxCharacters,
    this.hint,
    this.fontSize,
    this.fontWeight,
    this.textStyle,
    this.textCapitalization = TextCapitalization.none,
    this.dense = false,
    this.padding,
    this.margin,
    this.borderFocusable = true,
    this.onClick,
    this.prefixIcon,
    this.onTapPrefix,
    this.onAction,
    this.onTyping,
    this.lengthFilter = 1,
    this.borderRadius,
    this.onQuery,
    this.fontColor,
    this.hintColor,
    this.hintStyle,
    this.fillColor,
    this.prefix,
    this.suffix,
    this.autoFocus = false,
    this.inputAction,
    this.bottomBorderOnly = true,
  }) : super(key: key);

  InputBorder boder(Color color) {
    BorderSide borderSide = BorderSide(
        color: borderTint ?? (borderFocusable ? color : Colors.transparent));

    return bottomBorderOnly
        ? UnderlineInputBorder(borderSide: borderSide)
        : OutlineInputBorder(
            borderSide: borderSide,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 6)),
          );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    EdgeInsets padding = this.padding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 13);

    bool hasTitle = title?.isNotEmpty ?? false;
    bool hasSubtitle = subtitle?.isNotEmpty ?? false;

    return Container(
      height: height,
      width: width,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasTitle)
            Padding(
              padding: titleSpacing ?? const EdgeInsets.only(bottom: 8),
              child: Text(
                title ?? '',
                textAlign: titleAlign,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: titleStyle ?? theme.textTheme.bodyText2,
              ),
            ),
          if (hasSubtitle)
            Padding(
              padding: subtitleSpacing ?? const EdgeInsets.only(bottom: 8),
              child: Text(
                subtitle ?? '',
                textAlign: subtitleAlign,
                style: subtitleStyle ?? theme.textTheme.subtitle1,
              ),
            ),
          TextFormField(
            controller: controller,
            readOnly: !typeable,
            autofocus: autoFocus,
            enableInteractiveSelection: selectable,
            textCapitalization: textCapitalization,
            toolbarOptions: ToolbarOptions(
              paste: selectable,
              cut: selectable,
              copy: selectable,
              selectAll: selectable,
            ),
            onChanged: (value) {
              onTyping?.call(value);
              int length = value.trim().length;
              if (length == 0 || length >= lengthFilter) {
                onQuery?.call(value);
              }
            },
            textInputAction: inputAction,
            onFieldSubmitted: onAction,
            onTap: onClick,
            maxLength: maxCharacters,
            inputFormatters: inputFormatters ?? format(keyboardType),
            validator: (value) => validator != null ? validator!(value) : null,
            autovalidateMode: autoValidate
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            keyboardType: keyboardType,
            textAlign: textAlign,
            obscureText: obscureText,
            maxLines: maxLines,
            style: (textStyle ?? theme.textTheme.bodyText1)?.copyWith(
              color: fontColor,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: fillColor ?? Theme.of(context).disabledColor,
              hintText: hint,
              counterStyle: theme.textTheme.subtitle2,
              errorStyle:
                  theme.textTheme.subtitle2?.copyWith(color: theme.errorColor),
              hintStyle: (hintStyle ?? theme.textTheme.subtitle1)?.copyWith(
                color: hintColor ?? theme.hintColor,
                fontSize: fontSize,
                fontWeight: fontWeight,
              ),
              prefixIconConstraints: BoxConstraints(
                minWidth: theme.iconTheme.size! + padding.right,
                maxHeight: theme.iconTheme.size!,
              ),
              prefixIcon: prefix ??
                  (prefixIcon == null
                      ? null
                      : IconButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          icon: prefixIcon!,
                          onPressed: onTapPrefix,
                          padding: EdgeInsets.zero,
                          iconSize: theme.iconTheme.size!,
                        )),
              suffixIconConstraints: BoxConstraints(
                minWidth: theme.iconTheme.size! + padding.top,
                maxHeight: theme.iconTheme.size!,
              ),
              suffixIcon: suffix ??
                  (suffixIcon == null
                      ? null
                      : IconButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          icon: suffixIcon!,
                          onPressed: onTapSuffix,
                          padding: EdgeInsets.zero,
                          iconSize: theme.iconTheme.size!,
                        )),
              isDense: dense,
              isCollapsed: false,
              contentPadding: padding,
              disabledBorder: boder(theme.disabledColor),
              enabledBorder: boder(theme.dividerColor),
              border: boder(theme.dividerColor),
              focusedBorder: boder(theme.hintColor),
              errorBorder: boder(theme.errorColor),
              focusedErrorBorder: boder(theme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}

List<TextInputFormatter> format(TextInputType? type,
    {bool allowDecimal = true}) {
  if (type == TextInputType.name) {
    return [FilteringTextInputFormatter.allow(RegExp(r'[ .a-zA-Z]*'))];
  } else if (type == TextInputType.phone) {
    return [FilteringTextInputFormatter.allow(RegExp(r'[+-\d]*'))];
  } else if (type == TextInputType.number) {
    return [
      FilteringTextInputFormatter.allow(
          allowDecimal ? RegExp(r'^\d+\.?\d*') : RegExp(r'\d*'))
    ];
  } else {
    return [];
  }
}

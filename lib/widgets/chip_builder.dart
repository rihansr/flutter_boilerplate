import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ChipBuilder<T, V> extends StatefulWidget {
  final List<String>? labels;
  final V? value;
  final List<T>? groupValues;
  final ChipStyle style;
  final double spacing;
  final double runSpacing;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Alignment alignment;
  final bool maintainState;
  final bool allowMultipleSelection;
  final Widget Function(T item, int i)? builder;
  final Function(dynamic)? onSelect;

  const ChipBuilder({
    Key? key,
    required this.labels,
    this.value,
    required this.groupValues,
    this.style = const ChipStyle(),
    this.spacing = 12,
    this.runSpacing = 6,
    this.padding,
    this.margin,
    this.alignment = Alignment.centerLeft,
    this.maintainState = true,
    this.allowMultipleSelection = false,
    this.onSelect,
  })  : builder = null,
        super(key: key);

  const ChipBuilder.builder({
    Key? key,
    this.groupValues,
    this.spacing = 12,
    this.runSpacing = 6,
    this.padding,
    this.margin,
    this.alignment = Alignment.centerLeft,
    this.builder,
  })  : labels = null,
        value = null,
        style = const ChipStyle(),
        maintainState = false,
        allowMultipleSelection = false,
        onSelect = null,
        super(key: key);

  @override
  State<ChipBuilder<T, V>> createState() => _ChipBuilderState<T, V>();
}

class _ChipBuilderState<T, V> extends State<ChipBuilder<T, V>> {
  List<T> _selectedChips = [];

  set _slectChip(T? item) {
    if (item == null) return;
    if (!widget.maintainState) {
      _selectedChips = widget.value == null
          ? []
          : widget.value is List
              ? widget.value as List<T>
              : [widget.value as T];
    }
    if (_selectedChips.contains(item)) {
      _selectedChips.remove(item);
    } else {
      if (widget.allowMultipleSelection) {
        _selectedChips.add(item);
      } else {
        _selectedChips.clear();
        _selectedChips.add(item);
      }
    }
    if (widget.maintainState) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: widget.alignment,
      padding: widget.padding ?? const EdgeInsets.fromLTRB(20, 12, 20, 12),
      margin: widget.margin,
      child: Wrap(
        spacing: widget.spacing,
        runSpacing: widget.runSpacing,
        children: [
          for (int i = 0; i < (widget.groupValues?.length ?? 0); i++)
            widget.builder?.call(widget.groupValues![i], i) ??
                ChipItem<T>(
                  label: widget.labels?[i] ?? '',
                  value: widget.groupValues?[i],
                  selectedValue:
                      widget.maintainState ? _selectedChips : widget.value,
                  style: widget.style,
                  onSelect: (value) => {
                    _slectChip = value,
                    widget.onSelect?.call(
                      widget.allowMultipleSelection
                          ? _selectedChips
                          : _selectedChips.isEmpty
                              ? null
                              : _selectedChips.first,
                    ),
                  },
                ),
        ],
      ),
    );
  }
}

class ChipItem<T> extends StatelessWidget {
  final String? label;
  final dynamic icon;
  final ChipStyle? style;
  final T? value;
  final dynamic selectedValue;

  final Function(T?)? onSelect;

  const ChipItem({
    Key? key,
    this.label,
    this.icon,
    this.style,
    required this.value,
    this.selectedValue,
    this.onSelect,
  }) : super(key: key);

  bool get isSelected => selectedValue == null
      ? false
      : selectedValue is List
          ? (selectedValue as List).contains(value)
          : selectedValue is String
              ? label?.toLowerCase() == (selectedValue as String).toLowerCase()
              : selectedValue == value;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return FilterChip(
      avatar: icon != null
          ? icon == Widget
              ? icon
              : Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? style?.selectedFontColor ?? theme.primaryColorLight
                      : style?.unselectedFontColor,
                )
          : null,
      padding: style?.padding,
      labelPadding: style?.labelPadding,
      clipBehavior: Clip.antiAlias,
      label: Text(label ?? '...'),
      selected: isSelected,
      labelStyle: (style?.labelStyle ?? theme.textTheme.bodyMedium)!.copyWith(
        color: isSelected
            ? style?.selectedFontColor ?? theme.primaryColorLight
            : style?.unselectedFontColor,
      ),
      shape: style?.radius != null
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(style!.radius!))
          : null,
      backgroundColor:
          style?.unselectedChipColor ?? theme.colorScheme.background,
      selectedColor: style?.selectedChipColor ?? theme.colorScheme.secondary,
      showCheckmark: false,
      onSelected: (bool isSelected) => {
        if (onSelect != null) onSelect!(value),
      },
    );
  }
}

class ChipStyle with Diagnosticable {
  const ChipStyle({
    this.labelStyle,
    this.padding = const EdgeInsets.all(8),
    this.labelPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.radius,
    this.selectedFontColor,
    this.unselectedFontColor,
    this.selectedChipColor,
    this.unselectedChipColor,
  });

  final TextStyle? labelStyle;
  final EdgeInsets? padding;
  final EdgeInsets? labelPadding;
  final double? radius;
  final Color? selectedFontColor;
  final Color? unselectedFontColor;
  final Color? selectedChipColor;
  final Color? unselectedChipColor;
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../shared/icons.dart';

class QuantityUpdater extends StatefulWidget {
  const QuantityUpdater({
    Key? key,
    required this.size,
    required this.value,
    this.style = const QuantityUpdaterStyle(),
    this.minLimit = 1,
    this.maxLimit,
    this.onUpdate,
    this.onIncrement,
    this.onDecrement,
  })  : initialCount = value ?? 1,
        maintainState = false,
        super(key: key);

  const QuantityUpdater.maintainState({
    Key? key,
    required this.size,
    this.initialCount = 1,
    this.style = const QuantityUpdaterStyle(),
    this.minLimit = 1,
    this.maxLimit,
    this.onUpdate,
    this.onIncrement,
    this.onDecrement,
  })  : maintainState = true,
        value = null,
        super(key: key);

  final Size size;
  final int initialCount;
  final int? value;
  final QuantityUpdaterStyle? style;
  final int minLimit;
  final int? maxLimit;
  final bool maintainState;
  final Function(int current)? onUpdate;
  final Function(int current)? onIncrement;
  final Function(int current)? onDecrement;

  @override
  State<QuantityUpdater> createState() => _QuantityUpdaterState();
}

class _QuantityUpdaterState extends State<QuantityUpdater> {
  late int count;

  @override
  void initState() {
    count = widget.value ?? widget.initialCount;
    super.initState();
  }

  bool get canIncrement => widget.maxLimit == null || count < widget.maxLimit!;
  increment() => widget.maintainState ? setState(() => count++) : count++;

  bool get canDecrement => count > widget.minLimit;
  decrement() => widget.maintainState ? setState(() => count--) : count--;

  Widget iconButton(IconData icon, void Function()? onPressed,
          {Color? iconTint}) =>
      SizedBox.square(
        dimension: widget.size.height,
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: widget.style?.iconSize,
            color: iconTint ?? Theme.of(context).iconTheme.color,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      width: widget.size.width,
      height: widget.size.height,
      decoration: ShapeDecoration(
        color: widget.style?.background ?? theme.cardColor,
        shape: StadiumBorder(
          side: (widget.style?.hideBorder ?? false)
              ? BorderSide.none
              : BorderSide(color: theme.primaryColor, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          iconButton(
            AppIcons.remove_circle_outlined,
            canDecrement
                ? () => this
                  ..decrement()
                  ..widget.onUpdate?.call(count)
                  ..widget.onDecrement?.call(count)
                : null,
            iconTint: widget.style?.contentColor,
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                child: Text(
                  '${widget.value ?? count}'.padLeft(2, '0'),
                  style: widget.style?.counterStyle ??
                      theme.textTheme.bodyLarge?.copyWith(
                        color: widget.style?.contentColor ?? theme.primaryColor,
                      ),
                ),
              ),
            ),
          ),
          iconButton(
            AppIcons.add_circle_outlined,
            canIncrement
                ? () => this
                  ..increment()
                  ..widget.onUpdate?.call(count)
                  ..widget.onIncrement?.call(count)
                : null,
            iconTint: widget.style?.contentColor ?? theme.primaryColor,
          ),
        ],
      ),
    );
  }
}

class QuantityUpdaterStyle with Diagnosticable {
  const QuantityUpdaterStyle({
    this.background,
    this.iconSize = 24,
    this.contentColor,
    this.counterStyle,
    this.hideBorder = false,
    this.borderSize = 1,
    this.borderTint,
  }) : assert(borderSize >= 0);

  final Color? background;
  final double iconSize;
  final Color? contentColor;
  final TextStyle? counterStyle;
  final bool hideBorder;
  final double borderSize;
  final Color? borderTint;
}

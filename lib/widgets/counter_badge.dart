import 'package:flutter/material.dart';
import '../shared/colors.dart';
import '../utils/extensions.dart';

class CounterBadge extends StatelessWidget {
  const CounterBadge({
    Key? key,
    required this.child,
    this.alignment,
    this.count = 0,
  }) : super(key: key);

  final Widget child;
  final AlignmentDirectional? alignment;

  final int count;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Badge(
      backgroundColor: context.colorScheme.primary,
      isLabelVisible: count != 0,
      largeSize: 16,
      label: SizedBox(
        width: 8,
        child: FittedBox(
          alignment: Alignment.center,
          child: Text(
            '$count',
            style: theme.textTheme.bodyLarge!.copyWith(
              fontSize: 11,
              color: ColorPalette.light().primaryLight,
            ),
          ),
        ),
      ),
      alignment: alignment,
      child: child,
    );
  }
}

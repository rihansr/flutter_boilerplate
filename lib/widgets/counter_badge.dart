import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

class CounterBadge extends StatelessWidget {
  const CounterBadge({
    Key? key,
    required this.child,
    this.count = 0,
    this.position,
  }) : super(key: key);

  final int count;
  final Widget child;
  final BadgePosition? position;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Badge(
      showBadge: count != 0,
      badgeColor: theme.primaryColor,
      animationType: BadgeAnimationType.slide,
      badgeContent: Text(
        '$count',
        style: theme.textTheme.bodyText1!.copyWith(
          color: theme.primaryColorLight,
          fontSize: 11,
        ),
      ),
      padding: const EdgeInsets.all(5),
      position: position ?? BadgePosition.topEnd(end: 2, top: 6),
      child: child,
    );
  }
}

import 'package:flutter/material.dart';

class Unfocus extends StatelessWidget {
  final Widget child;

  const Unfocus({
    Key? key,
    required this.child,
    this.behavior = HitTestBehavior.deferToChild,
  }) : super(key: key);

  final HitTestBehavior behavior;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: behavior,
      child: child,
    );
  }
}

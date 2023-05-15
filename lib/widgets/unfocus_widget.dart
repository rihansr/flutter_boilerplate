import 'package:flutter/material.dart';

class Unfocus extends StatelessWidget {
  final Widget child;
  final HitTestBehavior behavior;

  const Unfocus({
    Key? key,
    required this.child,
    this.behavior = HitTestBehavior.translucent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: behavior,
      child: child,
    );
  }
}

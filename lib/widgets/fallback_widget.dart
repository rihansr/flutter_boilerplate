import 'package:flutter/material.dart';

class FallbackWidget extends StatelessWidget {
  final dynamic check;
  final Widget child;
  final bool loading;
  final bool expanded;
  final Widget? loadingChild;
  final Widget? fallbackChild;

  const FallbackWidget({
    Key? key,
    required this.check,
    required this.child,
    this.loadingChild,
    this.fallbackChild,
    this.loading = false,
    this.expanded = false,
  }) : super(key: key);

  const FallbackWidget.expand({
    Key? key,
    required this.check,
    required this.child,
    this.loadingChild,
    this.fallbackChild,
    this.loading = false,
  })  : expanded = true,
        super(key: key);

  Widget body([Widget? child = const SizedBox.shrink()]) =>
      expanded ? Expanded(child: child!) : child!;

  @override
  Widget build(BuildContext context) {
    return loading
        ? body(loadingChild)
        : check == null ||
                (check is num && check == 0) ||
                (check is List && check.length == 0) ||
                (check is bool && check == false) ||
                (check is String && (check as String).trim().isEmpty)
            ? body(fallbackChild)
            : body(child);
  }
}

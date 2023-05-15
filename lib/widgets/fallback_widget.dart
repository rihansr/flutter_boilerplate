import 'package:flutter/material.dart';

class FallbackWidget extends StatelessWidget {
  final dynamic check;
  final Widget child;
  final bool loading;
  final bool expanded;
  final Widget? loadingChild;
  final Widget? fallbackChild;
  final Future<void> Function()? onRefresh;

  const FallbackWidget({
    Key? key,
    required this.check,
    required this.child,
    this.loadingChild,
    this.fallbackChild,
    this.onRefresh,
    this.loading = false,
  })  : expanded = false,
        super(key: key);

  const FallbackWidget.expand({
    Key? key,
    required this.check,
    required this.child,
    this.loadingChild,
    this.fallbackChild,
    this.onRefresh,
    this.loading = false,
  })  : expanded = true,
        super(key: key);

  Widget body([Widget? child]) => expanded
      ? Expanded(child: child ?? const SizedBox.shrink())
      : child ?? const SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    return !loading &&
            (check == null ||
                (check is num && check == 0) ||
                (check is List && check.length == 0) ||
                (check is bool && check == false) ||
                (check is String && (check as String).trim().isEmpty))
        ? body(onRefresh != null && fallbackChild != null
            ? LayoutBuilder(
                builder: (context, constraints) => RefreshIndicator(
                  onRefresh: onRefresh!,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: fallbackChild!,
                    ),
                  ),
                ),
              )
            : fallbackChild)
        : body(loading && loadingChild != null ? loadingChild : child);
  }
}

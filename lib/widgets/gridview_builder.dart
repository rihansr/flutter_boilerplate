import 'package:flutter/material.dart';

class GridViewBuilder<T> extends StatelessWidget {
  final ScrollController? controller;
  final List<T>? children;
  final Function(T? item, int index) builder;
  final int spanCount;
  final int dummyChildCount;
  final double? height;
  final double? width;
  final EdgeInsets? spacing;
  final double? horizontalSpacing;
  final double? verticalSpacing;
  final double childSpacing;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final double childAspectRatio;
  final ScrollPhysics? scrollPhysics;
  final bool isLoading;
  final Future<void> Function()? onRefresh;
  final Function()? onStartListener;
  final Function()? onEndListener;
  final Function(T?)? onChildSelected;

  const GridViewBuilder({
    Key? key,
    this.controller,
    required this.children,
    required this.builder,
    this.spanCount = 2,
    this.dummyChildCount = 2,
    this.height,
    this.width,
    this.spacing,
    this.childSpacing = 0,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.childAspectRatio = 1.0,
    this.scrollPhysics,
    this.isLoading = false,
    this.onChildSelected,
    this.horizontalSpacing,
    this.verticalSpacing,
    this.onRefresh,
    this.onStartListener,
    this.onEndListener,
  }) : super(key: key);

  List<T?> dummyItems() => [for (int i = 0; i < dummyChildCount; i++) null];

  @override
  Widget build(BuildContext context) {
    var items = isLoading ? dummyItems() : children ?? [];

    Widget listItems = GridView.builder(
      controller: controller,
      physics: scrollPhysics ?? const BouncingScrollPhysics(),
      padding: spacing ??
          EdgeInsets.symmetric(
            vertical: verticalSpacing ?? 10,
            horizontal: horizontalSpacing ?? 10,
          ),
      shrinkWrap: true,
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: spanCount,
        crossAxisSpacing: crossAxisSpacing ?? childSpacing,
        mainAxisSpacing: mainAxisSpacing ?? childSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (_, i) {
        return InkWell(
          onTap: () => {
            if (items.isNotEmpty && items[i] != null)
              onChildSelected?.call(items[i])
          },
          child: builder(items[i], i),
        );
      },
      scrollDirection: Axis.vertical,
    );

    return Visibility(
      visible: isLoading || (children?.isNotEmpty ?? false),
      maintainAnimation: true,
      maintainState: true,
      child: onStartListener != null || onEndListener != null
          ? NotificationListener<ScrollUpdateNotification>(
              onNotification: (scrollEnd) {
                var metrics = scrollEnd.metrics;
                if (metrics.atEdge) {
                  if (metrics.pixels == 0) {
                    if (onStartListener != null) onStartListener!();
                  } else {
                    if (onEndListener != null) onEndListener!();
                  }
                }
                return true;
              },
              child: onRefresh == null
                  ? listItems
                  : RefreshIndicator(
                      onRefresh: onRefresh!,
                      child: listItems,
                    ),
            )
          : onRefresh == null
              ? listItems
              : RefreshIndicator(
                  onRefresh: onRefresh!,
                  child: listItems,
                ),
    );
  }
}

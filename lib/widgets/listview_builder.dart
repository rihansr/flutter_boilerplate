import 'package:flutter/material.dart';

class ListViewBuilder<T> extends StatelessWidget {
  final ScrollController? controller;
  final Color? background;
  final bool reverse;
  final double? radius;
  final List<T>? items;
  final Function(T? item, int index) builder;
  final double? height;
  final double? width;
  final double? itemWidth;
  final double? itemHeight;
  final double itemSpacing;
  final int dummyChildCount;
  final bool isLoading;
  final ScrollPhysics? scrollPhysics;
  final Axis scrollDirection;
  final Widget? divider;
  final EdgeInsets? spacing;
  final Future<void> Function()? onRefresh;
  final Function()? onStartListener;
  final Function()? onEndListener;
  final Function(T)? onItemSelected;

  const ListViewBuilder({
    Key? key,
    this.controller,
    this.background,
    this.reverse = false,
    this.radius,
    required this.items,
    required this.builder,
    this.height,
    this.width,
    this.itemWidth,
    this.itemHeight,
    this.itemSpacing = 0,
    this.dummyChildCount = 0,
    this.isLoading = false,
    this.scrollPhysics,
    this.scrollDirection = Axis.vertical,
    this.divider,
    this.spacing,
    this.onRefresh,
    this.onStartListener,
    this.onEndListener,
    this.onItemSelected,
  }) : super(key: key);

  const ListViewBuilder.vertical({
    Key? key,
    this.controller,
    this.background,
    this.reverse = false,
    this.radius,
    required this.items,
    required this.builder,
    this.height,
    this.width,
    this.itemWidth,
    this.itemHeight,
    this.itemSpacing = 0,
    this.dummyChildCount = 0,
    this.isLoading = false,
    this.scrollPhysics,
    this.divider,
    this.spacing,
    this.onRefresh,
    this.onStartListener,
    this.onEndListener,
    this.onItemSelected,
  })  : scrollDirection = Axis.vertical,
        super(key: key);

  const ListViewBuilder.horizontal({
    Key? key,
    this.controller,
    this.background,
    this.reverse = false,
    this.radius,
    required this.items,
    required this.builder,
    this.height,
    this.width,
    this.itemWidth,
    this.itemHeight,
    this.itemSpacing = 0,
    this.dummyChildCount = 0,
    this.isLoading = false,
    this.scrollPhysics,
    this.divider,
    this.spacing,
    this.onRefresh,
    this.onStartListener,
    this.onEndListener,
    this.onItemSelected,
  })  : scrollDirection = Axis.horizontal,
        super(key: key);

  List<T?> dummyItems() => List.generate(dummyChildCount, (index) => null);

  @override
  Widget build(BuildContext context) {
    var children = isLoading ? dummyItems() : items ?? [];
    double? width = scrollDirection == Axis.vertical
        ? (this.width ?? itemWidth)
        : this.width;

    double? height = scrollDirection == Axis.horizontal
        ? (this.height ?? itemHeight)
        : this.height;
    EdgeInsets spacing =
        this.spacing ?? const EdgeInsets.fromLTRB(20, 12, 20, 12);

    Widget child = ListView.separated(
      controller: controller,
      reverse: reverse,
      physics: scrollPhysics ?? const BouncingScrollPhysics(),
      padding: spacing,
      shrinkWrap: true,
      itemCount: children.length,
      itemBuilder: (_, i) {
        return InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () => {
            if (children.isNotEmpty && children[i] != null)
              onItemSelected?.call(children[i] as T)
          },
          child: SizedBox(
            width: itemWidth,
            height: itemHeight,
            child: builder(children[i], i),
          ),
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(
          width: scrollDirection == Axis.horizontal ? itemSpacing : null,
          height: scrollDirection == Axis.vertical ? itemSpacing : null,
          child: divider,
        );
      },
      scrollDirection: scrollDirection,
    );

    return Visibility(
      visible: isLoading || (items?.isNotEmpty ?? false),
      maintainAnimation: true,
      maintainState: true,
      child: Container(
        decoration: BoxDecoration(
            color: background,
            borderRadius:
                radius == null ? null : BorderRadius.circular(radius!)),
        constraints: BoxConstraints(
          maxWidth: width == null
              ? double.infinity
              : width + spacing.left + spacing.right,
          maxHeight: height == null
              ? double.infinity
              : height + spacing.top + spacing.bottom,
        ),
        child: onStartListener != null || onEndListener != null
            ? NotificationListener<ScrollUpdateNotification>(
                onNotification: (notification) {
                  if (notification.metrics.atEdge) {
                    notification.metrics.pixels == 0
                        ? onStartListener?.call()
                        : onEndListener?.call();
                  }
                  return true;
                },
                child: onRefresh == null
                    ? child
                    : LayoutBuilder(
                        builder: (context, constraints) => RefreshIndicator(
                          onRefresh: onRefresh!,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: constraints.maxHeight),
                            child: child,
                          ),
                        ),
                      ),
              )
            : onRefresh == null
                ? child
                : LayoutBuilder(
                    builder: (context, constraints) => RefreshIndicator(
                      onRefresh: onRefresh!,
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: child,
                      ),
                    ),
                  ),
      ),
    );
  }
}

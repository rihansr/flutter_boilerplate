import 'package:flutter/material.dart';

class ListViewBuilder<T> extends StatelessWidget {
  final ScrollController? controller;
  final List<T>? children;
  final Function(T? item, int index) builder;
  final double? height;
  final double? width;
  final double? childWidth;
  final double? childHeight;
  final double childSpacing;
  final int dummyChildCount;
  final bool isLoading;
  final ScrollPhysics? scrollPhysics;
  final Axis scrollDirection;
  final Widget? divider;
  final EdgeInsets? spacing;
  final Future<void> Function()? onRefresh;
  final Function()? onStartListener;
  final Function()? onEndListener;
  final Function(T?)? onChildSelected;

  const ListViewBuilder({
    Key? key,
    this.controller,
    required this.children,
    required this.builder,
    this.height,
    this.width,
    this.childWidth,
    this.childHeight,
    this.childSpacing = 0,
    this.dummyChildCount = 0,
    this.isLoading = false,
    this.scrollPhysics,
    this.scrollDirection = Axis.vertical,
    this.divider,
    this.spacing,
    this.onRefresh,
    this.onStartListener,
    this.onEndListener,
    this.onChildSelected,
  }) : super(key: key);

  const ListViewBuilder.vertical({
    Key? key,
    this.controller,
    required this.children,
    required this.builder,
    this.height,
    this.width,
    this.childWidth,
    this.childHeight,
    this.childSpacing = 0,
    this.dummyChildCount = 0,
    this.isLoading = false,
    this.scrollPhysics,
    this.divider,
    this.spacing,
    this.onRefresh,
    this.onStartListener,
    this.onEndListener,
    this.onChildSelected,
  }) : scrollDirection = Axis.vertical, super(key: key);

  const ListViewBuilder.horizontal({
    Key? key,
    this.controller,
    required this.children,
    required this.builder,
    this.height,
    this.width,
    this.childWidth,
    this.childHeight,
    this.childSpacing = 0,
    this.dummyChildCount = 0,
    this.isLoading = false,
    this.scrollPhysics,
    this.divider,
    this.spacing,
    this.onRefresh,
    this.onStartListener,
    this.onEndListener,
    this.onChildSelected,
  }) : scrollDirection = Axis.horizontal, super(key: key);

  List<T?> dummyItems() => [for (int i = 0; i < dummyChildCount; i++) null];

  @override
  Widget build(BuildContext context) {
    var items = isLoading ? dummyItems() : children ?? [];

    Widget child = ListView.separated(
      controller: controller,
      physics: scrollPhysics ?? const BouncingScrollPhysics(),
      padding: spacing ??
          (scrollDirection == Axis.horizontal
              ? const EdgeInsets.symmetric(horizontal: 20)
              : const EdgeInsets.symmetric(vertical: 20)),
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (_, i) {
        return InkWell(
          onTap: () => {
            if (items.isNotEmpty && items[i] != null)
              onChildSelected?.call(items[i])
          },
          child: SizedBox(
            width: childWidth,
            height: childHeight,
            child: builder(items[i], i),
          ),
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(
          width: scrollDirection == Axis.horizontal ? childSpacing : null,
          height: scrollDirection == Axis.vertical ? childSpacing : null,
          child: divider,
        );
      },
      scrollDirection: scrollDirection,
    );

    return Visibility(
      visible: isLoading || (children?.isNotEmpty ?? false),
      maintainAnimation: true,
      maintainState: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: width ?? double.infinity,
          maxHeight: (scrollDirection == Axis.horizontal
                  ? (height ?? childHeight)
                  : height) ??
              double.infinity,
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
                    : RefreshIndicator(
                        onRefresh: onRefresh!,
                        child: child,
                      ),
              )
            : onRefresh == null
                ? child
                : RefreshIndicator(
                    onRefresh: onRefresh!,
                    child: child,
                  ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SliderBuilder<T> extends StatefulWidget {
  const SliderBuilder({
    Key? key,
    this.controller,
    this.initialIndex = 0,
    this.sliders = const [],
    this.aspectRatio = 16 / 9,
    this.loading = false,
    this.dummyChildCount = 3,
    this.indicatorColor,
    this.indicatorSize = 8,
    this.indicatorSpace = 6,
    this.loader,
    required this.itemBuilder,
  }) : super(key: key);

  final CarouselController? controller;
  final int initialIndex;
  final List<T> sliders;
  final double aspectRatio;
  final bool loading;
  final int dummyChildCount;
  final Color? indicatorColor;
  final double indicatorSize;
  final double indicatorSpace;
  final Widget? loader;
  final Widget Function(T) itemBuilder;

  @override
  State<SliderBuilder<T>> createState() => _SliderBuilderState<T>();
}

class _SliderBuilderState<T> extends State<SliderBuilder<T>> {
  late CarouselController controller;
  late int pageIndex;

  @override
  void initState() {
    controller = widget.controller ?? CarouselController();
    pageIndex = widget.initialIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) =>
      !widget.loading && widget.sliders.isEmpty
          ? const SizedBox.shrink()
          : Stack(
              children: [
                CarouselSlider.builder(
                  carouselController: controller,
                  itemCount: widget.loading
                      ? widget.dummyChildCount
                      : widget.sliders.length,
                  options: CarouselOptions(
                    aspectRatio: widget.aspectRatio,
                    viewportFraction: 1,
                    autoPlay: true,
                    enableInfiniteScroll: false,
                    autoPlayAnimationDuration: const Duration(seconds: 1),
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index, reason) =>
                        setState(() => pageIndex = index),
                  ),
                  itemBuilder:
                      (BuildContext context, int index, int realIndex) =>
                          widget.loading
                              ? widget.loader ?? const SizedBox.shrink()
                              : widget.itemBuilder(widget.sliders[index]),
                ),
                if (widget.sliders.length > 1)
                  AspectRatio(
                    aspectRatio: widget.aspectRatio,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        runAlignment: WrapAlignment.end,
                        spacing: widget.indicatorSpace,
                        runSpacing: widget.indicatorSpace,
                        children: List.generate(
                          widget.sliders.length,
                          (index) {
                            {
                              final isSelected = index == pageIndex;
                              return GestureDetector(
                                onTap: () => controller.animateToPage(index),
                                child: Container(
                                  width: widget.indicatorSize,
                                  height: widget.indicatorSize,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (widget.indicatorColor ??
                                            Theme.of(context).primaryColor)
                                        : (widget.indicatorColor ??
                                                Theme.of(context).primaryColor)
                                            .withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  )
              ],
            );
}

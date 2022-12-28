import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SliderBuilder<T> extends StatelessWidget {
  const SliderBuilder({
    Key? key,
    this.sliders = const [],
    this.aspectRatio = 16 / 8,
    this.loading = false,
    this.dummyChildCount = 3,
    this.placeholder,
    required this.itemBuilder,
  }) : super(key: key);

  final List<T> sliders;
  final double aspectRatio;
  final bool loading;
  final int dummyChildCount;
  final Widget? placeholder;
  final Widget Function(T) itemBuilder;

  @override
  Widget build(BuildContext context) => Visibility(
        visible: loading || sliders.isNotEmpty,
        maintainAnimation: true,
        maintainState: true,
        child: CarouselSlider.builder(
          itemCount: loading ? dummyChildCount : sliders.length,
          options: CarouselOptions(
            enlargeCenterPage: false,
            autoPlay: true,
            aspectRatio: aspectRatio,
            viewportFraction: 1,
            autoPlayAnimationDuration: const Duration(seconds: 1),
            scrollDirection: Axis.horizontal,
          ),
          itemBuilder: (BuildContext context, int index, int realIndex) =>
              loading
                  ? placeholder ?? const SizedBox.shrink()
                  : itemBuilder(sliders[index]),
        ),
      );
}

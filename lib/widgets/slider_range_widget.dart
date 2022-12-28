import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class SliderRange extends StatelessWidget {
  const SliderRange({
    Key? key,
    required this.min,
    required this.max,
    required this.values,
    required this.onChanged,
  }) : super(key: key);

  final double min;
  final double max;
  final SfRangeValues values;
  final Function(SfRangeValues)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 48, 6, 0),
      child: SfRangeSlider(
        values: values,
        min: min,
        max: max,
        showTicks: false,
        showLabels: false,
        enableTooltip: true,
        interval: 1,
        shouldAlwaysShowTooltip: true,
        inactiveColor: Theme.of(context).dividerColor,
        onChanged: onChanged,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class Splitter extends StatelessWidget {
  final List<Widget> children;
  final List<int> flexes;
  final int defaultFlex;
  final double spacing;
  final Widget? spacer;
  final Axis axis;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const Splitter({
    key,
    required this.axis,
    this.children = const [],
    this.flexes = const [],
    this.defaultFlex = 0,
    this.spacing = 24,
    this.spacer,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  }) : super(key: key);

  const Splitter.horizontal({
    key,
    this.children = const [],
    this.flexes = const [],
    this.defaultFlex = 0,
    this.spacing = 16,
    this.spacer,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  })  : axis = Axis.horizontal,
        super(key: key);

  const Splitter.vertical({
    key,
    this.children = const [],
    this.flexes = const [],
    this.defaultFlex = 0,
    this.spacing = 16,
    this.spacer,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  })  : axis = Axis.vertical,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<int, int> flexes = this.flexes.asMap();
    List<Widget> children = [
      for (int i = 0; i < this.children.length; i++)
        if (this.children.length >= i + 1) ...[
          (flexes[i] ?? defaultFlex) == 0
              ? this.children[i]
              : Expanded(
                  flex: flexes[i] ?? 1,
                  child: this.children[i],
                ),
          if (i != this.children.length - 1)
            spacer ??
                SizedBox(
                  width: axis == Axis.horizontal ? spacing : 0,
                  height: axis == Axis.vertical ? spacing : 0,
                ),
        ]
    ];

    return axis == Axis.horizontal
        ? Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: mainAxisSize,
            children: children,
          )
        : Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: mainAxisSize,
            children: children,
          );
  }
}

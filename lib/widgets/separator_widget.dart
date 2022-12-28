import 'package:flutter/material.dart';

class Separator extends StatelessWidget {
  final double size;
  final Color? color;
  final Axis axis;
  final double? thickness;

  const Separator.horizontal({
    key,
    this.size = 1,
    this.color,
    this.thickness = .75,
  }) : axis = Axis.horizontal, super(key: key);

  const Separator.vertical({
    key,
    this.size = 1,
    this.color,
    this.thickness = .75,
  }) : axis = Axis.vertical, super(key: key);

  @override
  Widget build(BuildContext context) {
    return axis == Axis.horizontal
        ? VerticalDivider(width: size, color: color, thickness: thickness)
        : Divider(height: size, color: color, thickness: thickness);
  }
}

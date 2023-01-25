import 'package:flutter/material.dart';
import '../../utils/extensions.dart';
import '../../widgets/button_widget.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {Key? key,
      required this.label,
      this.icon,
      this.loading = false,
      this.onPressed})
      : super(key: key);

  final String label;
  final IconData? icon;
  final bool loading;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Button(
      loading: loading,
      label: label,
      fontColor: context.theme.scaffoldBackgroundColor,
      leading: icon != null
          ? Icon(
              icon,
              color: context.theme.scaffoldBackgroundColor,
            )
          : null,
      onPressed: onPressed,
    );
  }
}
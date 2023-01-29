import 'package:boilerplate/shared/styles.dart';
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
  final dynamic icon;
  final bool loading;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Button(
      loading: loading,
      label: label,
      fontColor: context.theme.scaffoldBackgroundColor,
      leading: icon != null
          ? icon is IconData
              ? Icon(
                  icon,
                  size: 24,
                  color: context.theme.scaffoldBackgroundColor,
                )
              : style.image(
                  icon,
                  size: 24,
                  color: context.theme.scaffoldBackgroundColor,
                )
          : null,
      onPressed: onPressed,
    );
  }
}

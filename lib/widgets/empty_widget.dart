import 'package:flutter/material.dart';
import '../shared/styles.dart';
import 'button_widget.dart';

class EmptyWidget extends StatelessWidget {
  final dynamic image;
  final Color? backgound;
  final String? title;
  final String? subtitle;
  final String? actionLabel;
  final Color? cardColor;
  final Clip clipBehavior;
  final Function()? onAction;

  const EmptyWidget({
    Key? key,
    required this.image,
    this.backgound,
    this.title,
    this.subtitle,
    this.cardColor,
    this.actionLabel,
    this.clipBehavior = Clip.antiAlias,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size mqSize = MediaQuery.of(context).size;
    double size = mqSize.height + mqSize.width;

    return Container(
      width: size * .265,
      clipBehavior: clipBehavior,
      padding: EdgeInsets.all(size * .015),
      color: backgound,
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: image is Widget
                ? image
                : style.image(image, fit: BoxFit.fitWidth),
          ),
          if (title != null)
            Padding(
              padding: EdgeInsets.only(top: size * .015),
              child: Text(
                title!,
                textAlign: TextAlign.center,
                style: theme.textTheme.headline5,
              ),
            ),
          if (subtitle != null)
            Padding(
              padding: EdgeInsets.only(top: size * .01),
              child: Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: theme.textTheme.subtitle1,
              ),
            ),
          if (onAction != null)
            Button(
              shape: BoxShape.rectangle,
              margin: EdgeInsets.only(
                top: size * .015,
              ),
              label: actionLabel,
              onPressed: onAction,
            ),
        ],
      ),
    );
  }
}

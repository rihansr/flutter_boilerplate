import 'package:flutter/material.dart';
import '../shared/styles.dart';
import 'button_widget.dart';

class EmptyWidget extends StatelessWidget {
  final dynamic image;
  final String? title;
  final String? subtitle;
  final String? actionLabel;
  final Color? cardColor;
  final Function()? onAction;

  const EmptyWidget({
    Key? key,
    required this.image,
    this.title,
    this.subtitle,
    this.cardColor,
    this.actionLabel,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size mqSize = MediaQuery.of(context).size;
    double size = mqSize.height + mqSize.width;

    return Container(
      width: size * .265,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(size * .015),
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
                style: theme.textTheme.headline1,
              ),
            ),
          if (subtitle != null)
            Padding(
              padding: EdgeInsets.only(top: size * .015),
              child: Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyText2!.copyWith(
                  height: 1.75,
                ),
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

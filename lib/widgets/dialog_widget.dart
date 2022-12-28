import 'dart:ui';
import 'package:flutter/material.dart';
import '../shared/strings.dart';
import '../services/navigation_service.dart';
import '../shared/styles.dart';
import '../widgets/button_widget.dart';
import 'splitter_widget.dart';

Future<void> showNormalDialog({
  Widget? child,
  Color? background,
  bool dismissible = true,
  String? headline,
  String? image,
  String? title,
  String? subtitle,
  TextAlign textAlign = TextAlign.center,
  TextAlign? headlineAlign,
  TextAlign? titleAlign,
  TextAlign? subtitleAlign,
  String? negativeButtonLabel,
  String? positiveButtonLabel,
  Object? arguments,
  double radius = 8,
  EdgeInsets? padding,
  bool hideHeadline = true,
  BoxConstraints? constraints,
  Function(dynamic)? callback,
  Function()? onTapNegativeButton,
  Function()? onTapPositiveButton,
}) {
  return showGeneralDialog(
    context: navigator.context,
    barrierDismissible: dismissible,
    barrierLabel:
        MaterialLocalizations.of(navigator.context).modalBarrierDismissLabel,
    barrierColor: Colors.black12,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) =>
        BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        backgroundColor: background ?? Theme.of(context).backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          constraints: constraints ??
              BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75),
          child: child ??
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!hideHeadline)
                    Row(
                      children: [
                        const IconButton(
                          onPressed: null,
                          icon: SizedBox.shrink(),
                        ),
                        Expanded(
                          child: Text(
                            headline ?? '',
                            textAlign: headlineAlign ?? textAlign,
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                        )
                      ],
                    ),
                  if (image != null)
                    Flexible(
                      child: style.image(image, fit: BoxFit.fitWidth),
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title != null)
                        Text(
                          title,
                          textAlign: titleAlign ?? textAlign,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      if (title != null && subtitle != null)
                        const SizedBox(height: 12),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          textAlign: subtitleAlign ?? textAlign,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (negativeButtonLabel != null)
                        Expanded(
                          child: Button(
                            shape: const StadiumBorder(),
                            label: negativeButtonLabel,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            fillColor:
                                Theme.of(context).colorScheme.onBackground,
                            fontColor:
                                Theme.of(context).textTheme.subtitle1?.color,
                            margin: EdgeInsets.zero,
                            onPressed: () => {
                              Navigator.pop(context),
                              onTapNegativeButton?.call()
                            },
                          ),
                        ),
                      if (negativeButtonLabel != null &&
                          positiveButtonLabel != null)
                        const SizedBox(width: 16),
                      if (positiveButtonLabel != null)
                        Expanded(
                          child: Button(
                            shape: const StadiumBorder(),
                            label: positiveButtonLabel,
                            margin: EdgeInsets.zero,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            onPressed: () => {
                              Navigator.pop(context),
                              onTapPositiveButton?.call()
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ),
        ),
      ),
    ),
  ).then((value) => callback?.call(value));
}

showSimpleDialog({
  String? positiveButtonLabel,
  Function()? onTapPositiveButton,
  String? negativeButtonLabel,
  Function()? onTapNegativeButton,
}) =>
    showNormalDialog(
      padding: const EdgeInsets.all(0),
      child: Splitter.vertical(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -4),
            contentPadding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
            onTap: () async =>
                {Navigator.pop(navigator.context), onTapPositiveButton?.call()},
            title: Text(
              positiveButtonLabel ?? string().yes,
              style: Theme.of(navigator.context).textTheme.bodyText2,
            ),
          ),
          ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -4),
            contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
            onTap: () async =>
                {Navigator.pop(navigator.context), onTapNegativeButton?.call()},
            title: Text(
              negativeButtonLabel ?? string().no,
              style: Theme.of(navigator.context).textTheme.bodyText2,
            ),
          ),
        ],
      ),
    );

showFullScreenDialog({
  required Widget child,
  Color? backgroundColor,
  bool dismissible = false,
  bool useSafeArea = false,
  Object? arguments,
  Function(dynamic)? onDispose,
}) {
  return showDialog(
    barrierDismissible: dismissible,
    context: navigator.context,
    barrierLabel:
        MaterialLocalizations.of(navigator.context).modalBarrierDismissLabel,
    barrierColor:
        backgroundColor ?? Theme.of(navigator.context).backgroundColor,
    useSafeArea: useSafeArea,
    builder: (context) => ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: child,
    ),
  ).then((value) => onDispose?.call(value));
}

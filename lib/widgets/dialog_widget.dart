import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/navigation_service.dart';
import '../shared/styles.dart';
import '../widgets/button_widget.dart';

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
  double radius = 6,
  EdgeInsets? padding,
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
          padding: padding ?? const EdgeInsets.all(20),
          constraints: constraints ??
              BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.875),
          child: child ??
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 0, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              title,
                              textAlign: titleAlign ?? textAlign,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ),
                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              subtitle,
                              textAlign: subtitleAlign ?? textAlign,
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      if (negativeButtonLabel != null)
                        Expanded(
                          child: Button(
                            shape: BoxShape.rectangle,
                            label: negativeButtonLabel,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 8,
                            ),
                            fillColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            fontColor: Theme.of(context).colorScheme.secondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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
                            shape: BoxShape.rectangle,
                            label: positiveButtonLabel,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 8,
                            ),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/utils/extensions.dart';
import '/services/navigation_service.dart';
import '/shared/strings.dart';
import 'drawables.dart';
import 'enums.dart';

final style = Style.value;

class Style {
  static Style get value => Style._();
  Style._();
  SnackBar snackbar(
    String message, {
    MessageType? type,
    String? actionLabel,
    int duration = 4,
    Function()? onAction,
  }) =>
      SnackBar(
        backgroundColor: (() {
          switch (type) {
            case MessageType.success:
              return Colors.green;
            case MessageType.error:
              return Colors.red;
            default:
              return null;
          }
        }()),
        content: Text(
          message,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: navigator.context.textTheme.bodyMedium!.copyWith(
            color: navigator.context.theme.primaryColorLight,
          ),
        ),
        action: (onAction != null)
            ? SnackBarAction(
                label: actionLabel ??
                    (() {
                      switch (type) {
                        case MessageType.error:
                          return string().retry;
                        default:
                          return string().okay;
                      }
                    }()),
                textColor: navigator.context.theme.primaryColorLight,
                onPressed: onAction,
              )
            : null,
        duration: Duration(seconds: duration),
      );

  void toast(String message, {MessageType? type}) => Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: (() {
          switch (type) {
            case MessageType.success:
              return Colors.green;
            case MessageType.error:
              return Colors.red;
            default:
              return null;
          }
        }()),
        textColor: Colors.white,
      );

  Widget image(
    dynamic img, {
    EdgeInsets margin = EdgeInsets.zero,
    EdgeInsets padding = EdgeInsets.zero,
    Clip clipBehavior = Clip.antiAlias,
    double? boxSize,
    double? boxHeight,
    double? boxWidth,
    double? size,
    double? height,
    Color? background,
    double? width,
    BoxFit? fit,
    Color? color,
    String? placeholder,
    BoxFit? placeholderFit,
    Alignment? alignment,
    BoxShape? shape,
    double radius = 0,
  }) =>
      Container(
        height: boxHeight ?? boxSize,
        width: boxWidth ?? boxSize,
        margin: margin,
        padding: padding,
        alignment: alignment,
        clipBehavior: clipBehavior,
        decoration: BoxDecoration(
          shape: shape ?? BoxShape.rectangle,
          color: background,
          borderRadius: shape == BoxShape.circle
              ? null
              : BorderRadius.all(Radius.circular(radius)),
        ),
        child: (() {
          placeholder ??= Drawable.placeholder;
          fit ??= BoxFit.cover;
          placeholderFit ??= fit;
          size ??= height ??= width;
          height ??= size;
          width ??= size;

          if (img == null) {
            return image(placeholder,
                height: height, width: width, fit: placeholderFit);
          } else if (img is IconData) {
            return Icon(img, size: size, color: color);
          } else if (img is File) {
            return img.existsSync()
                ? Image.file(img,
                    height: height, width: width, fit: fit, color: color)
                : image(placeholder,
                    height: height, width: width, fit: placeholderFit);
          } else if (Uri.tryParse(img ?? '')?.hasAbsolutePath ?? false) {
            return CachedNetworkImage(
              imageUrl: img,
              height: height,
              width: width,
              color: color,
              fit: fit,
              fadeInCurve: Curves.easeIn,
              placeholder: (context, url) => image(placeholder,
                  height: height, width: width, fit: placeholderFit),
              errorWidget: (context, url, error) => image(placeholder,
                  height: height, width: width, fit: placeholderFit),
            );
          } else if (img?.toString().toLowerCase().endsWith('.svg') ?? false) {
            return svg.SvgPicture.asset(img,
                height: height, width: width, fit: fit!, color: color);
          } else {
            return Image.asset(img,
                height: height, width: width, fit: fit, color: color);
          }
        }()),
      );

  ImageProvider<Object> imageProvider(
    dynamic img, {
    String? placeholder,
  }) =>
      (() {
        placeholder ??= Drawable.placeholder;

        if (img == null) {
          return imageProvider(placeholder);
        } else if (img is File) {
          return img.existsSync()
              ? FileImage(img)
              : imageProvider(placeholder ?? Drawable.placeholder);
        } else if (Uri.tryParse(img ?? '')?.hasAbsolutePath ?? false) {
          return CachedNetworkImageProvider(img);
        } else if (img?.toString().toLowerCase().endsWith('.svg') ?? false) {
          return Svg(img);
        } else {
          return AssetImage(img);
        }
      }());
}

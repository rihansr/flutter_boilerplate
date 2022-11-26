import 'package:boilerplate/configs/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
class ColorPalette {
  Color primary;
  Color primaryLight;
  Color primaryDark;
  Color onSecondary;
  Color active;
  Color inactive;
  Color accent;
  Color scaffold;
  Color background;
  Color shadow;
  Color icon;
  Color focus;
  Color text;
  Color subtitle;
  Color hint;
  Color divider;
  Color disable;
  Color error;

  ColorPalette({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.onSecondary,
    required this.accent,
    required this.active,
    required this.inactive,
    required this.scaffold,
    required this.background,
    required this.shadow,
    required this.icon,
    required this.focus,
    required this.text,
    required this.subtitle,
    required this.hint,
    required this.divider,
    required this.disable,
    required this.error,
  });

  factory ColorPalette.dark() => ColorPalette(
        primary: const Color(0xFFFFFFFF),
        primaryLight: const Color(0xFFFFFFFF),
        primaryDark: const Color(0xFF0A191E),
        onSecondary: const Color(0xFFFF7B5F),
        active: const Color(0xFF029094),
        inactive: const Color(0xFFFF8F0C),
        accent: const Color(0xFFF62D01),
        scaffold: const Color(0xFF2B2B2B),
        background: const Color(0xFF333333),
        shadow: const Color(0x3F000000),
        icon: const Color(0xFFFFFFFF),
        focus: const Color(0xFFF62D01),
        text: const Color(0xFFFFFFFF),
        subtitle: const Color(0xFF8E8E8E),
        hint: const Color(0xFF717273),
        divider: const Color(0xFFB3B3B3).withOpacity(.5),
        disable: const Color(0xFFB3B3B3),
        error: const Color(0xFFFF5421),
      );

  factory ColorPalette.light() => ColorPalette(
        primary: const Color(0xFF0A191E),
        primaryLight: const Color(0xFFFFFFFF),
        primaryDark: const Color(0xFF0A191E),
        onSecondary: const Color(0xFFFF7B5F),
        active: const Color(0xFF029094),
        inactive: const Color(0xFFFF8F0C),
        accent: const Color(0xFFF62D01),
        scaffold: const Color(0xFFF8F8F8),
        background: const Color(0xFFFFFFFF),
        shadow: const Color(0x3fd3d1d8),
        icon: const Color(0xFF0A191E),
        focus: const Color(0xFFF62D01),
        text: const Color(0xFF373737),
        subtitle: const Color(0xFF57585A),
        hint: const Color(0xFFB3B3B3),
        divider: const Color(0xFFB3B3B3).withOpacity(.5),
        disable: const Color(0xFFB3B3B3),
        error: const Color(0xFFFF5421),
      );

  factory ColorPalette.current([BuildContext? context]) =>
      appSettings.isDarkTheme
          ? ColorPalette.dark()
          : ColorPalette.light();
}

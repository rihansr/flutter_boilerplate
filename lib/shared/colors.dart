import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../configs/app_settings.dart';
import '../models/settings_model.dart';

class ColorPalette {
  Color primary;
  Color onPrimary;
  Color primaryLight;
  Color primaryDark;
  Color secondary;
  Color onSecondary;
  Color scaffold;
  Color background;
  Color card;
  Color shadow;
  Color buttonText;
  Color icon;
  Color focus;
  Color title;
  Color subtitle;
  Color hint;
  Color divider;
  Color disable;
  Color error;

  ColorPalette({
    required this.primary,
    required this.onPrimary,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondary,
    required this.onSecondary,
    required this.scaffold,
    required this.background,
    required this.card,
    required this.shadow,
    required this.buttonText,
    required this.icon,
    required this.focus,
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.divider,
    required this.disable,
    required this.error,
  });

  factory ColorPalette.dark() => ColorPalette(
        primary: const Color(0xFFFC8019),
        onPrimary: const Color(0xFFEEA734),
        primaryLight: const Color(0xFF1C1C1C),
        primaryDark: const Color(0xFFFFFFFF),
        secondary: const Color(0xFF8FB404),
        onSecondary: const Color(0xFFFAE5C2),
        scaffold: const Color(0xFF2B2B2B),
        background: const Color(0xFF1C1C1C),
        card: const Color(0xFF1C1C1C),
        shadow: const Color(0x1AFC8019),
        buttonText: const Color(0xFFFFFFFF),
        icon: const Color(0xFFFFFFFF),
        focus: const Color(0xFFFFF2E8),
        title: const Color(0xFFFFFFFF),
        subtitle: const Color(0xFFBFBFBF),
        hint: const Color(0xFFBFBFBF),
        divider: const Color(0xFFB3B3B3).withOpacity(.5),
        disable: const Color(0xFFB3B3B3),
        error: const Color(0xFFF33030),
      );

  factory ColorPalette.light() => ColorPalette(
        primary: const Color(0xFFFC8019),
        onPrimary: const Color(0xFFEEA734),
        primaryLight: const Color(0xFFFFFFFF),
        primaryDark: const Color(0xFF1C1C1C),
        secondary: const Color(0xFF8FB404),
        onSecondary: const Color(0xFFFAE5C2),
        scaffold: const Color(0xFFFFFBF8),
        background: const Color(0xFFFFFFFF),
        card: const Color(0xFFFFFFFF),
        shadow: const Color(0x1AFC8019),
        buttonText: const Color(0xFFFFFFFF),
        icon: const Color(0xFF1C1B1B),
        focus: const Color(0xFFFFF2E8),
        title: const Color(0xFF1C1C1C),
        subtitle: const Color(0xFF696969),
        hint: const Color(0xFFBFBFBF),
        divider: const Color(0xFFE3E3E3),
        disable: const Color(0xFFF8F8F8),
        error: const Color(0xFFF33030),
      );

  factory ColorPalette.current([Settings? settings]) =>
      appSettings.isDarkTheme(settings)
          ? ColorPalette.dark()
          : ColorPalette.light();
}

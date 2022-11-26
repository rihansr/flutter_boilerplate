import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../shared/colors.dart';
import '../shared/constants.dart';
import '../shared/dimens.dart';

ThemeData theming(ThemeMode mode) {
  ColorPalette colorPalette;
  switch (mode) {
    case ThemeMode.light:
      colorPalette = ColorPalette.light();

      break;
    case ThemeMode.dark:
    default:
      colorPalette = ColorPalette.dark();
  }

  return ThemeData(
    fontFamily: kFontFamily,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
      },
    ),
    canvasColor: colorPalette.background,
    appBarTheme: const AppBarTheme().copyWith(
      color: colorPalette.background,
      shadowColor: colorPalette.shadow,
    ),
    primaryColor: colorPalette.primary,
    backgroundColor: colorPalette.background,
    dividerColor: colorPalette.divider,
    splashColor: colorPalette.scaffold,
    shadowColor: colorPalette.shadow,
    scaffoldBackgroundColor: colorPalette.scaffold,
    primaryColorDark: colorPalette.primaryDark,
    primaryColorLight: colorPalette.primaryLight,
    colorScheme: mode == ThemeMode.light
        ? ColorScheme.light(
            primary: colorPalette.primary,
            onPrimary: colorPalette.primaryLight,
            secondary: colorPalette.accent,
            onSecondary: colorPalette.onSecondary,
            background: colorPalette.background,
            surface: colorPalette.scaffold,
            error: colorPalette.error,
          )
        : ColorScheme.dark(
            primary: colorPalette.primary,
            onPrimary: colorPalette.primaryLight,
            secondary: colorPalette.accent,
            onSecondary: colorPalette.onSecondary,
            background: colorPalette.background,
            surface: colorPalette.scaffold,
            error: colorPalette.error,
          ),
    cardColor: colorPalette.background,
    hintColor: colorPalette.hint,
    disabledColor: colorPalette.disable,
    errorColor: colorPalette.error,
    toggleableActiveColor: colorPalette.accent,
    iconTheme: IconThemeData(
      color: colorPalette.icon,
      size: Dimen.iconSize_24,
    ),
    snackBarTheme: const SnackBarThemeData().copyWith(
      backgroundColor: colorPalette.scaffold,
      contentTextStyle: TextStyle(
        fontSize: Dimen.fontSize_12,
        color: colorPalette.primary,
        fontWeight: FontWeight.w400,
      ),
      actionTextColor: colorPalette.accent,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: Dimen.elevation_4,
      selectedItemColor: colorPalette.onSecondary,
      unselectedItemColor: colorPalette.onSecondary,
      backgroundColor: colorPalette.accent,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(
        fontSize: Dimen.fontSize_12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: Dimen.fontSize_12,
        fontWeight: FontWeight.w500,
      ),
    ),
    tabBarTheme: const TabBarTheme().copyWith(
      labelPadding: EdgeInsets.zero,
      labelColor: colorPalette.accent,
      labelStyle: const TextStyle(
        fontSize: Dimen.fontSize_16,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelColor: colorPalette.subtitle,
      unselectedLabelStyle: const TextStyle(
        fontSize: Dimen.fontSize_16,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: TextTheme(
      headline1: TextStyle(
        fontSize: Dimen.fontSize_24,
        fontWeight: FontWeight.w700,
        color: colorPalette.text,
      ),
      headline2: TextStyle(
        fontSize: Dimen.fontSize_20,
        fontWeight: FontWeight.w700,
        color: colorPalette.text,
      ),
      headline3: TextStyle(
        fontSize: Dimen.fontSize_18,
        fontWeight: FontWeight.w700,
        color: colorPalette.text,
      ),
      headline4: TextStyle(
        fontSize: Dimen.fontSize_16,
        fontWeight: FontWeight.w700,
        color: colorPalette.text,
      ),
      headline5: TextStyle(
        fontSize: Dimen.fontSize_16,
        fontWeight: FontWeight.w600,
        color: colorPalette.text,
      ),
      headline6: TextStyle(
        fontSize: Dimen.fontSize_14,
        fontWeight: FontWeight.w500,
        color: colorPalette.text,
      ),
      bodyText1: TextStyle(
        fontSize: Dimen.fontSize_16,
        fontWeight: FontWeight.w400,
        color: colorPalette.text,
      ),
      bodyText2: TextStyle(
        fontSize: Dimen.fontSize_14,
        fontWeight: FontWeight.w400,
        color: colorPalette.text,
      ),
      subtitle1: TextStyle(
        fontSize: Dimen.fontSize_12,
        fontWeight: FontWeight.w400,
        color: colorPalette.subtitle,
      ),
      subtitle2: TextStyle(
        fontSize: Dimen.fontSize_11,
        fontWeight: FontWeight.w400,
        color: colorPalette.subtitle,
      ),
      button: TextStyle(
        fontSize: Dimen.fontSize_18,
        fontWeight: FontWeight.w700,
        color: colorPalette.primaryLight,
      ),
      caption: TextStyle(
        fontSize: Dimen.fontSize_14,
        fontWeight: FontWeight.w500,
        color: colorPalette.primaryLight,
      ),
      overline: TextStyle(
        fontSize: Dimen.fontSize_12,
        fontWeight: FontWeight.w400,
        color: colorPalette.subtitle,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: colorPalette.divider,
      thickness: 1,
    ),
    bottomSheetTheme: const BottomSheetThemeData().copyWith(
      backgroundColor: Colors.transparent,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorPalette.accent,
      foregroundColor: colorPalette.accent,
    ),
  );
}

SystemUiOverlayStyle overlayStyle(ThemeMode mode) {
  return SystemUiOverlayStyle(
    systemNavigationBarColor: ColorPalette.current().background,
    systemNavigationBarIconBrightness:
        mode == ThemeMode.light ? Brightness.dark : Brightness.light,
    statusBarColor: Colors.transparent,
  );
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/navigation_service.dart';
import '../shared/colors.dart';
import '../shared/constants.dart';

final themeConfig = ThemeConfig.value;

class ThemeConfig {
  static ThemeConfig get value => ThemeConfig._();
  ThemeConfig._();

  ThemeData theme = Theme.of(navigator.context);
  TextTheme textTheme = Theme.of(navigator.context).textTheme;
  IconThemeData iconTheme = Theme.of(navigator.context).iconTheme;
  ColorScheme colorScheme = Theme.of(navigator.context).colorScheme;
}

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
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colorPalette.title,
        height: 1.5,
      ),
    ),
    primaryColor: colorPalette.primary,
    backgroundColor: colorPalette.background,
    dividerColor: colorPalette.divider,
    splashColor: colorPalette.focus,
    focusColor: colorPalette.focus,
    shadowColor: colorPalette.shadow,
    scaffoldBackgroundColor: colorPalette.scaffold,
    primaryColorDark: colorPalette.primaryDark,
    primaryColorLight: colorPalette.primaryLight,
    colorScheme: ColorScheme(
      brightness: mode == ThemeMode.light ? Brightness.light : Brightness.dark,
      primary: colorPalette.primary,
      onPrimary: colorPalette.onPrimary,
      secondary: colorPalette.secondary,
      onSecondary: colorPalette.onSecondary,
      background: colorPalette.background,
      onBackground: colorPalette.background,
      surface: colorPalette.scaffold,
      onSurface: colorPalette.scaffold,
      error: colorPalette.error,
      onError: colorPalette.error,
    ),
    cardColor: colorPalette.card,
    hintColor: colorPalette.hint,
    disabledColor: colorPalette.disable,
    errorColor: colorPalette.error,
    toggleableActiveColor: colorPalette.primary,
    iconTheme: IconThemeData(
      color: colorPalette.icon,
      size: 24,
    ),
    snackBarTheme: const SnackBarThemeData().copyWith(
      backgroundColor: colorPalette.primary,
      actionTextColor: colorPalette.buttonText,
      disabledActionTextColor: colorPalette.disable,
      contentTextStyle: TextStyle(
        fontSize: 12,
        color: colorPalette.buttonText,
        fontWeight: FontWeight.w300,
        height: 1.5,
        overflow: TextOverflow.ellipsis,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 0,
      selectedItemColor: colorPalette.primary,
      unselectedItemColor: colorPalette.subtitle,
      backgroundColor: Colors.transparent,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w300,
        height: 1.5,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w300,
        height: 1.5,
      ),
    ),
    tabBarTheme: const TabBarTheme().copyWith(
      labelColor: colorPalette.primary,
      labelPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 32),
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
      ),
      unselectedLabelColor: colorPalette.subtitle,
      unselectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
      ),
    ),
    textTheme: TextTheme(
      headline1: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: colorPalette.title,
        height: 1.39,
      ),
      headline2: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: colorPalette.title,
        height: 1.43,
      ),
      headline3: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: colorPalette.title,
        height: 1.5,
      ),
      headline4: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colorPalette.title,
        height: 1.5,
      ),
      headline5: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colorPalette.title,
        height: 1.44,
      ),
      headline6: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colorPalette.title,
        height: 1.5,
      ),
      bodyText1: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorPalette.title,
        height: 1.43,
      ),
      bodyText2: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorPalette.title,
        height: 1.43,
      ),
      subtitle1: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w300,
        color: colorPalette.subtitle,
        height: 1.5,
      ),
      subtitle2: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w300,
        color: colorPalette.subtitle,
        height: 1.4,
      ),
      button: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorPalette.buttonText,
        height: 1.43,
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
      backgroundColor: colorPalette.primary,
      foregroundColor: colorPalette.onPrimary,
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

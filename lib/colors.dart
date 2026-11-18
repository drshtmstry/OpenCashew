import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:system_theme/system_theme.dart';

//import 'package:budget/colors.dart';
//getColor(context, "lightDarkAccent")

Color getColor(BuildContext context, String colorName) {
  return Theme.of(context).extension<AppColors>()?.colors[colorName] ??
      Colors.red;
}

AppColors getAppColors(
    {required Brightness brightness,
    required ThemeData themeData,
    required Color accentColor}) {
  Color lightDarkAccentHeavyLight = brightness == Brightness.light
      ? const Color(0xFFFFFFFF)
      : const Color(0xFF1E293B);
  return brightness == Brightness.light
      ? AppColors(
          colors: {
            "white": Colors.white,
            "black": Colors.black,
            "textLight": appStateSettings["increaseTextContrast"]
                ? Colors.black.withOpacity(0.7)
                : appStateSettings["materialYou"]
                    ? Colors.black.withOpacity(0.4)
                    : const Color(0xFF64748B), // Slate 500
            "lightDarkAccent": const Color(0xFFF8FAFC), // Slate 50
            "lightDarkAccentHeavyLight": lightDarkAccentHeavyLight,
            "canvasContainer": const Color(0xFFF1F5F9), // Slate 100
            "lightDarkAccentHeavy": const Color(0xFFE2E8F0), // Slate 200
            "shadowColor": const Color(0x140F172A), // Low-contrast slate shadow
            "shadowColorLight": const Color(0x0A0F172A),
            "unPaidUpcoming": const Color(0xFF0284C7), // Sky 600
            "unPaidOverdue": const Color(0xFF4F46E5), // Indigo 600
            "incomeAmount": const Color(0xFF059669), // Emerald 600
            "expenseAmount": const Color(0xFFE11D48), // Rose 600
            "warningOrange": const Color(0xFFD97706), // Amber 600
            "starYellow": const Color(0xFFEAB308),
            "dividerColor": appStateSettings["materialYou"]
                ? const Color(0x140F172A)
                : const Color(0xFFE2E8F0),
            "standardContainerColor": const Color(0xFFFFFFFF),
          },
        )
      : AppColors(
          colors: {
            "white": Colors.black,
            "black": Colors.white,
            "textLight": appStateSettings["increaseTextContrast"]
                ? Colors.white.withOpacity(0.75)
                : appStateSettings["materialYou"]
                    ? Colors.white.withOpacity(0.4)
                    : const Color(0xFF94A3B8), // Slate 400
            "lightDarkAccent": const Color(0xFF1E293B), // Slate 800
            "lightDarkAccentHeavyLight": lightDarkAccentHeavyLight,
            "canvasContainer": const Color(0xFF0F172A), // Slate 900
            "lightDarkAccentHeavy": const Color(0xFF334155), // Slate 700
            "shadowColor": const Color(0x33000000),
            "shadowColorLight": const Color(0x1A000000),
            "unPaidUpcoming": const Color(0xFF38BDF8), // Sky 400
            "unPaidOverdue": const Color(0xFF818CF8), // Indigo 400
            "incomeAmount": const Color(0xFF10B981), // Emerald 500
            "expenseAmount": const Color(0xFFF43F5E), // Rose 500
            "warningOrange": const Color(0xFFF59E0B), // Amber 500
            "starYellow": const Color(0xFFFACC15),
            "dividerColor": appStateSettings["materialYou"]
                ? const Color(0x1AFFFFFF)
                : const Color(0xFF334155),
            "standardContainerColor": const Color(0xFF1E293B),
          },
        );
}

// Ensure you specify a shade, otherwise type will be of MaterialColor which can't be compared
// when using in other widgets, such as the Color Picker
extension ColorsDefined on ColorScheme {
  Color get selectableColorRed => Colors.red.shade400;
  Color get selectableColorGreen => Colors.green.shade400;
  Color get selectableColorBlue => Colors.blue.shade400;
  Color get selectableColorPurple => Colors.purple.shade400;
  Color get selectableColorOrange => Colors.orange.shade400;
  Color get selectableColorBlueGrey => Colors.blueGrey.shade400;
  Color get selectableColorYellow => Colors.yellow.shade400;
  Color get selectableColorAqua => Colors.teal.shade400;
  Color get selectableColorInidigo => Colors.indigo.shade500;
  Color get selectableColorGrey => Colors.grey.shade400;
  Color get selectableColorBrown => Colors.brown.shade400;
  Color get selectableColorDeepPurple => Colors.deepPurple.shade400;
  Color get selectableColorDeepOrange => Colors.deepOrange.shade400;
  Color get selectableColorCyan => Colors.cyan.shade400;
}

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.colors,
  });

  final Map<String, Color?> colors;

  @override
  AppColors copyWith({Map<String, Color?>? colors}) {
    return AppColors(
      colors: colors ?? this.colors,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }

    final Map<String, Color?> lerpColors = {};
    colors.forEach((key, value) {
      lerpColors[key] = Color.lerp(colors[key], other.colors[key], t);
    });

    return AppColors(
      colors: lerpColors,
    );
  }
}

Color darken(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

Color lighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
}

Color lightenPastel(Color color, {double amount = 0.1}) {
  return Color.alphaBlend(
    Colors.white.withOpacity(amount),
    color,
  );
}

Color darkenPastel(Color color, {double amount = 0.1}) {
  return Color.alphaBlend(
    Colors.black.withOpacity(amount),
    color,
  );
}

Color blend(Color colorToBlend, Color baseColor, {double amount = 0.1}) {
  return Color.alphaBlend(
    baseColor.withOpacity(amount),
    colorToBlend,
  );
}

Color dynamicPastel(
  BuildContext context,
  Color color, {
  double amount = 0.1,
  bool inverse = false,
  double? amountLight,
  double? amountDark,
}) {
  if (amountLight == null) {
    amountLight = amount;
  }
  if (amountDark == null) {
    amountDark = amount;
  }
  if (amountLight > 1) {
    amountLight = 1;
  }
  if (amountDark > 1) {
    amountDark = 1;
  }
  if (amount > 1) {
    amount = 1;
  }
  if (inverse) {
    if (Theme.of(context).brightness == Brightness.light) {
      return darkenPastel(color, amount: amountDark);
    } else {
      return lightenPastel(color, amount: amountLight);
    }
  } else {
    if (Theme.of(context).brightness == Brightness.light) {
      return lightenPastel(color, amount: amountLight);
    } else {
      return darkenPastel(color, amount: amountDark);
    }
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String? hexColor, Color? defaultColor, context) {
    try {
      if (hexColor == null) {
        if (defaultColor == null) {
          return Colors.grey.value;
        } else {
          return defaultColor.value;
        }
      }
      hexColor = hexColor.replaceAll("#", "");
      hexColor = hexColor.replaceAll("0x", "");
      if (hexColor.length == 6) {
        hexColor = "FF" + hexColor;
      }
      return int.parse(hexColor, radix: 16);
    } catch (e) {
      return Colors.grey.value;
    }
  }

  HexColor(final String? hexColor, {final Color? defaultColor})
      : super(_getColorFromHex(hexColor, defaultColor, context));
}

String? toHexString(Color? color) {
  if (color == null) {
    return null;
  }
  String valueString = color.value.toRadixString(16);
  return "0x" + valueString;
}

List<Color> selectableColors(context) {
  return [
    Theme.of(context).colorScheme.selectableColorGreen,
    Theme.of(context).colorScheme.selectableColorAqua,
    Theme.of(context).colorScheme.selectableColorCyan,
    Theme.of(context).colorScheme.selectableColorBlue,
    Theme.of(context).colorScheme.selectableColorInidigo,
    Theme.of(context).colorScheme.selectableColorDeepPurple,
    Theme.of(context).colorScheme.selectableColorPurple,
    Theme.of(context).colorScheme.selectableColorRed,
    Theme.of(context).colorScheme.selectableColorOrange,
    Theme.of(context).colorScheme.selectableColorYellow,
    Theme.of(context).colorScheme.selectableColorDeepOrange,
    Theme.of(context).colorScheme.selectableColorBrown,
    Theme.of(context).colorScheme.selectableColorGrey,
    Theme.of(context).colorScheme.selectableColorBlueGrey,
  ];
}

List<Color> selectableAccentColors(context) {
  return [
    Theme.of(context).colorScheme.selectableColorGreen,
    Theme.of(context).colorScheme.selectableColorCyan,
    Theme.of(context).colorScheme.selectableColorBlue,
    Theme.of(context).colorScheme.selectableColorInidigo,
    Theme.of(context).colorScheme.selectableColorDeepPurple,
    Theme.of(context).colorScheme.selectableColorPurple,
    Theme.of(context).colorScheme.selectableColorRed,
    Theme.of(context).colorScheme.selectableColorOrange,
    Theme.of(context).colorScheme.selectableColorYellow,
    Theme.of(context).colorScheme.selectableColorGrey,
    Theme.of(context).colorScheme.selectableColorBlueGrey,
  ];
}

const ColorFilter greyScale = ColorFilter.matrix(<double>[
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
]);

Future<String?> getAccentColorSystemString() async {
  if (supportsSystemColor() && appStateSettings["accentSystemColor"] == true) {
    SystemTheme.fallbackColor = Colors.blue;
    await SystemTheme.accentColor.load();
    Color accentColor = SystemTheme.accentColor.accent;
    if (accentColor.toString() == "Color(0xff80cbc4)") {
      // A default cyan color returned from an unsupported accent color Samsung device
      return null;
    }
    print("System color loaded");
    return toHexString(accentColor);
  } else {
    return null;
  }
}

Future<bool> systemColorByDefault() async {
  if (getPlatform() == PlatformOS.isAndroid) {
    if (supportsSystemColor()) {
      int? androidVersion = await getAndroidVersion();
      print("Android version: " + androidVersion.toString());
      if (androidVersion != null && androidVersion >= 12) {
        return true;
      }
    }
    return false;
  }
  return supportsSystemColor();
}

bool supportsSystemColor() {
  return defaultTargetPlatform.supportsAccentColor &&
      kIsWeb != true &&
      getPlatform() != PlatformOS.isIOS;
}

bool isGrayScale(Color color, {int threshold = 10}) {
  int red = color.red;
  int green = color.green;
  int blue = color.blue;

  return (red - green).abs() <= threshold &&
      (red - blue).abs() <= threshold &&
      (green - blue).abs() <= threshold;
}

ColorScheme getColorScheme(Brightness brightness) {
  if (isGrayScale(
    getSettingConstants(appStateSettings)["accentColor"],
    threshold: 15,
  )) {
    return getGrayScaleColorScheme(brightness);
  }
  if (brightness == Brightness.light) {
    return ColorScheme.fromSeed(
      seedColor: getSettingConstants(appStateSettings)["accentColor"],
      brightness: Brightness.light,
      background: appStateSettings["materialYou"]
          ? lightenPastel(getSettingConstants(appStateSettings)["accentColor"],
              amount: 0.91)
          : Colors.white,
    );
  } else {
    return ColorScheme.fromSeed(
      seedColor: getSettingConstants(appStateSettings)["accentColor"],
      brightness: Brightness.dark,
      background: appStateSettings["forceFullDarkBackground"] == true
          ? Colors.black
          : appStateSettings["materialYou"]
              ? darkenPastel(
                  getSettingConstants(appStateSettings)["accentColor"],
                  amount: 0.92)
              : Colors.black,
    );
  }
}

ColorScheme getGrayScaleColorScheme(Brightness brightness) {
  if (brightness == Brightness.light) {
    return ColorScheme(
      brightness: Brightness.light,
      primary: Colors.blueGrey[700]!,
      onPrimary: Colors.white,
      primaryContainer: Colors.blueGrey[300]!,
      onPrimaryContainer: Colors.black,
      secondary: Colors.blueGrey[800]!,
      onSecondary: Colors.white,
      secondaryContainer: Colors.blueGrey[100]!,
      onSecondaryContainer: Colors.black,
      tertiary: Colors.blueGrey[500]!,
      onTertiary: Colors.white,
      tertiaryContainer: Colors.teal[100],
      onTertiaryContainer: Colors.blueGrey[900]!,
      error: const Color(0xFFE11D48), // Rose 600
      onError: Colors.white,
      errorContainer: const Color(0xFFFFE4E6), // Rose 100
      onErrorContainer: const Color(0xFF881337), // Rose 900
      surface: const Color(0xFFF8FAFC), // Slate 50
      onSurface: const Color(0xFF0F172A), // Slate 900
      background: appStateSettings["materialYou"]
          ? const Color(0xFFF1F5F9)
          : Colors.white,
      onBackground: const Color(0xFF0F172A),
      surfaceVariant: const Color(0xFFF1F5F9), // Slate 100
      onSurfaceVariant: const Color(0xFF334155), // Slate 700
      outline: const Color(0xFF94A3B8), // Slate 400
      outlineVariant: const Color(0xFFCBD5E1), // Slate 300
      shadow: const Color(0x1F0F172A),
      scrim: Colors.black.withOpacity(0.4),
      inverseSurface: const Color(0xFF1E293B),
      onInverseSurface: Colors.white,
      inversePrimary: const Color(0xFF94A3B8),
      surfaceTint: Colors.blueGrey[700],
    );
  } else {
    return ColorScheme(
      brightness: Brightness.dark,
      primary: Colors.blueGrey[200]!,
      onPrimary: Colors.black,
      primaryContainer: const Color(0xFF334155),
      onPrimaryContainer: Colors.white,
      secondary: const Color(0xFF94A3B8),
      onSecondary: Colors.black,
      secondaryContainer: const Color(0xFF1E293B),
      onSecondaryContainer: Colors.white,
      tertiary: Colors.blueGrey[300],
      onTertiary: Colors.black,
      tertiaryContainer: Colors.blueGrey[700],
      onTertiaryContainer: Colors.blueGrey[200]!,
      error: const Color(0xFFF43F5E), // Rose 500
      onError: Colors.black,
      errorContainer: const Color(0xFF881337),
      onErrorContainer: const Color(0xFFFFE4E6),
      surface: const Color(0xFF0F172A), // Slate 900
      onSurface: const Color(0xFFF8FAFC), // Slate 50
      background: appStateSettings["forceFullDarkBackground"] == true
          ? Colors.black
          : appStateSettings["materialYou"]
              ? const Color(0xFF020617) // Slate 950
              : const Color(0xFF0F172A), // Slate 900
      onBackground: const Color(0xFFF8FAFC),
      surfaceVariant: const Color(0xFF1E293B), // Slate 800
      onSurfaceVariant: const Color(0xFFCBD5E1), // Slate 300
      outline: const Color(0xFF64748B), // Slate 500
      outlineVariant: const Color(0xFF334155), // Slate 700
      shadow: Colors.black,
      scrim: Colors.black.withOpacity(0.6),
      inverseSurface: const Color(0xFFF8FAFC),
      onInverseSurface: const Color(0xFF0F172A),
      inversePrimary: Colors.blueGrey[800],
      surfaceTint: Colors.blueGrey[200],
    );
  }
}

SystemUiOverlayStyle getSystemUiOverlayStyle(
    AppColors? colors, Brightness brightness) {
  if (brightness == Brightness.light) {
    return SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      systemStatusBarContrastEnforced: false,
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: kIsWeb ? Colors.black : Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: getBottomNavbarBackgroundColor(
        colorScheme: getColorScheme(brightness),
        brightness: Brightness.light,
        lightDarkAccent: colors?.colors["lightDarkAccent"] ?? Colors.white,
      ),
    );
  } else {
    return SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      systemStatusBarContrastEnforced: false,
      statusBarIconBrightness: Brightness.light,
      statusBarColor: kIsWeb ? Colors.black : Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarColor: getBottomNavbarBackgroundColor(
        colorScheme: getColorScheme(brightness),
        brightness: Brightness.dark,
        lightDarkAccent: colors?.colors["lightDarkAccent"] ?? Colors.black,
      ),
    );
  }
}

Color getBottomNavbarBackgroundColor({
  required ColorScheme colorScheme,
  required Brightness brightness,
  required Color lightDarkAccent,
}) {
  if (getPlatform() == PlatformOS.isIOS) {
    return brightness == Brightness.light
        ? lightenPastel(colorScheme.secondaryContainer,
            amount: appStateSettings["materialYou"] ? 0.4 : 0.55)
        : darkenPastel(colorScheme.secondaryContainer,
            amount: appStateSettings["materialYou"] ? 0.4 : 0.55);
  } else if (appStateSettings["materialYou"] == true) {
    if (brightness == Brightness.light) {
      return lightenPastel(
        colorScheme.secondaryContainer,
        amount: 0.4,
      );
    } else {
      return darkenPastel(
        colorScheme.secondaryContainer,
        amount: 0.45,
      );
    }
  } else {
    return lightDarkAccent;
  }
}

// For Android widget hex color code conversion
String colorToHex(Color color) {
  Color opaqueColor = color.withAlpha(255);
  String hexString = opaqueColor.value.toRadixString(16).padLeft(6, '0');
  return "#" + hexString.substring(2);
}

class CustomColorTheme extends StatelessWidget {
  const CustomColorTheme(
      {required this.child, required this.accentColor, super.key});
  final Widget child;
  final Color? accentColor;
  @override
  Widget build(BuildContext context) {
    if (accentColor == null) return child;

    ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: accentColor!,
      brightness: determineBrightnessTheme(context),
      background: determineBrightnessTheme(context) == Brightness.dark
          ? (appStateSettings["forceFullDarkBackground"] == true
              ? Colors.black
              : appStateSettings["materialYou"]
                  ? darkenPastel(accentColor!, amount: 0.92)
                  : Colors.black)
          : appStateSettings["materialYou"]
              ? lightenPastel(accentColor!, amount: 0.91)
              : Colors.white,
    );
    return Theme(
      data: generateThemeDataWithExtension(
        accentColor: accentColor!,
        brightness: Theme.of(context).brightness,
        themeData: Theme.of(context).copyWith(
          colorScheme: colorScheme,
        ),
      ),
      child: child,
    );
  }
}

ThemeData generateThemeDataWithExtension(
    {required ThemeData themeData,
    required Brightness brightness,
    required Color accentColor}) {
  AppColors colors = getAppColors(
    accentColor: accentColor,
    brightness: brightness,
    themeData: themeData,
  );

  return themeData.copyWith(
    extensions: <ThemeExtension<dynamic>>[colors],
    appBarTheme: AppBarTheme(
      systemOverlayStyle: getSystemUiOverlayStyle(colors, brightness),
    ),
  );
}

ThemeData getLightTheme() {
  Brightness brightness = Brightness.light;
  ThemeData themeData = ThemeData(
    // pageTransitionsTheme: PageTransitionsTheme(builders: {
    //   // the page route animation is set in pushRoute() - functions.dart
    //   TargetPlatform.android: appStateSettings["iOSNavigation"]
    //       ? CupertinoPageTransitionsBuilder()
    //       : ZoomPageTransitionsBuilder(),
    //   TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    // }),
    fontFamily: appStateSettings["font"],
    fontFamilyFallback: ['Inter'],
    colorScheme: getColorScheme(brightness),
    useMaterial3: true,
    applyElevationOverlayColor: false,
    typography: Typography.material2014(),
    splashColor: getPlatform() == PlatformOS.isIOS
        ? Colors.transparent
        : appStateSettings["materialYou"]
            ? darkenPastel(
                    lightenPastel(
                        getSettingConstants(appStateSettings)["accentColor"],
                        amount: 0.8),
                    amount: 0.2)
                .withOpacity(0.5)
            : null,
  );
  return generateThemeDataWithExtension(
    themeData: themeData,
    brightness: brightness,
    accentColor: getSettingConstants(appStateSettings)["accentColor"],
  );
}

ThemeData getDarkTheme() {
  Brightness brightness = Brightness.dark;
  ThemeData themeData = ThemeData(
    // pageTransitionsTheme: PageTransitionsTheme(builders: {
    //   // the page route animation is set in pushRoute() - functions.dart
    //   TargetPlatform.android: appStateSettings["iOSNavigation"]
    //       ? CupertinoPageTransitionsBuilder()
    //       : ZoomPageTransitionsBuilder(),
    //   TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    // }),
    fontFamily: appStateSettings["font"],
    fontFamilyFallback: ['Inter'],
    colorScheme: getColorScheme(brightness),
    useMaterial3: true,
    typography: Typography.material2014(),
    splashColor: getPlatform() == PlatformOS.isIOS
        ? Colors.transparent
        : appStateSettings["materialYou"]
            ? darkenPastel(
                    lightenPastel(
                        getSettingConstants(appStateSettings)["accentColor"],
                        amount: 0.86),
                    amount: 0.1)
                .withOpacity(0.2)
            : null,
  );
  return generateThemeDataWithExtension(
    themeData: themeData,
    brightness: brightness,
    accentColor: getSettingConstants(appStateSettings)["accentColor"],
  );
}

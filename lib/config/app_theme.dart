import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _blue = Color(0xFF4A8DFF);
  static const _cyan = Color(0xFF59E1FF);

  static ThemeData lightTheme() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.lexendTextTheme(base.textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: _blue,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFD7E3FF),
        onPrimaryContainer: const Color(0xFF001B3E),
        secondary: _cyan,
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFD1E4FF),
        onSecondaryContainer: const Color(0xFF001D36),
        tertiary: const Color(0xFF23B0B0),
        onTertiary: Colors.white,
        tertiaryContainer: const Color(0xFFD9EAEA),
        onTertiaryContainer: const Color(0xFF002020),
        error: const Color(0xFFBA1A1A),
        onError: Colors.white,
        errorContainer: const Color(0xFFFFDAD6),
        onErrorContainer: const Color(0xFF410002),
        surface: const Color(0xFFF9FAFF),
        onSurface: const Color(0xFF191C20),
        surfaceContainer: Colors.white,
        surfaceContainerHigh: const Color(0xFFF0F4F8),
        surfaceContainerLowest: Colors.white,
        outline: const Color(0xFF73777F),
        outlineVariant: const Color(0xFFC3C7CF),
      ),
      scaffoldBackgroundColor: Colors.transparent,
      fontFamilyFallback: const ['Poppins', 'SF Pro Display', 'Roboto'],
      textTheme: textTheme.apply(
        bodyColor: const Color(0xFF191C20),
        displayColor: const Color(0xFF191C20),
      ),
      primaryTextTheme: textTheme,
      iconTheme: const IconThemeData(color: Color(0xFF43474E)),
      primaryIconTheme: const IconThemeData(color: Color(0xFF43474E)),
      actionIconTheme: const ActionIconThemeData(
        backButtonIconBuilder: _themedActionIcon,
        closeButtonIconBuilder: _themedActionIcon,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF191C20),
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Color(0xFF43474E)),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        selectedIconTheme: const IconThemeData(color: _blue, size: 28),
        unselectedIconTheme: const IconThemeData(
          color: Color(0xFF5B6A84),
          size: 24,
        ),
        labelType: NavigationRailLabelType.selected,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shadowColor: const Color(0x0F000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(
            color: Color(0xFFDDE2EA),
            width: 1,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: Colors.white.withValues(alpha: 0.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 3,
        backgroundColor: _blue,
        foregroundColor: Colors.white,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFDDE2EA),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFC3C7CF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFC3C7CF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _blue, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xFF73777F)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFDDE2EA), width: 1),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFDDE2EA), width: 1),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return const Color(0xFF73777F);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _blue;
          }
          return const Color(0xFFDDE2EA);
        }),
      ),
    );
  }

  static ThemeData darkTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.lexendTextTheme(base.textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _blue,
        secondary: _cyan,
        surface: Color(0x66172135),
        onSurface: Color(0xFFEAF2FF),
      ),
      scaffoldBackgroundColor: Colors.transparent,
      fontFamilyFallback: const ['Poppins', 'SF Pro Display', 'Roboto'],
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: const IconThemeData(color: Color(0xFFE1ECFF)),
      primaryIconTheme: const IconThemeData(color: Color(0xFFE1ECFF)),
      actionIconTheme: const ActionIconThemeData(
        backButtonIconBuilder: _themedActionIcon,
        closeButtonIconBuilder: _themedActionIcon,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: const Color(0x332A3550),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        selectedIconTheme: const IconThemeData(color: _blue, size: 28),
        unselectedIconTheme: const IconThemeData(
          color: Color(0xFF9EB4D2),
          size: 24,
        ),
        labelType: NavigationRailLabelType.selected,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0x4D223152),
        shadowColor: Colors.black.withValues(alpha: 0.25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: const Color(0x402A3A63),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.15),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x4D2C3B65),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _cyan, width: 1.2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xB227365A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: const Color(0xBF27385F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _blue;
          }
          return const Color(0xFF8CA0BE);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF669FFF);
          }
          return const Color(0xFF4A5875);
        }),
      ),
    );
  }

  static Widget _themedActionIcon(BuildContext context) {
    return Icon(
      Icons.arrow_back,
      color: Theme.of(context).colorScheme.onSurface,
      size: 22,
    );
  }
}

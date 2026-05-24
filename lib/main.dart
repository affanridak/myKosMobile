import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controllers/theme_controller.dart';
import 'views/auth/splash_screen.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ThemeController());
  runApp(const MyApp());
}

// Helper: buat TextTheme Poppins yang menggantikan semua style bawaan
TextTheme _poppinsTextTheme(TextTheme base) {
  return GoogleFonts.poppinsTextTheme(base);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    // ── Light ──────────────────────────────────────────────────────────────
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );
    final lightText = _poppinsTextTheme(ThemeData.light().textTheme);

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      colorScheme: lightColorScheme,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: lightColorScheme.surface,
      cardColor: lightColorScheme.surface,
      shadowColor: Colors.black,
      dividerColor: lightColorScheme.outline,
      textTheme: lightText,
      primaryTextTheme: lightText,

      appBarTheme: AppBarTheme(
        backgroundColor: lightColorScheme.surface,
        foregroundColor: lightColorScheme.onSurface,
        elevation: 1,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: lightColorScheme.onSurface,
        ),
        toolbarTextStyle: GoogleFonts.poppins(
          color: lightColorScheme.onSurface,
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: lightColorScheme.surface,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: lightColorScheme.onSurface,
        ),
        contentTextStyle: GoogleFonts.poppins(
          color: lightColorScheme.onSurface,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.poppins(
          color: lightColorScheme.onSurface.withAlpha(120),
        ),
        labelStyle: GoogleFonts.poppins(color: lightColorScheme.onSurface),
      ),

      chipTheme: ChipThemeData(labelStyle: GoogleFonts.poppins()),

      popupMenuTheme: PopupMenuThemeData(textStyle: GoogleFonts.poppins()),

      snackBarTheme: SnackBarThemeData(contentTextStyle: GoogleFonts.poppins()),
    );

    // ── Dark ───────────────────────────────────────────────────────────────
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    );
    final darkText = _poppinsTextTheme(ThemeData.dark().textTheme);

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: darkColorScheme,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: darkColorScheme.surface,
      cardColor: darkColorScheme.surface,
      shadowColor: Colors.black,
      dividerColor: darkColorScheme.outline,
      textTheme: darkText,
      primaryTextTheme: darkText,

      appBarTheme: AppBarTheme(
        backgroundColor: darkColorScheme.surface,
        foregroundColor: darkColorScheme.onSurface,
        elevation: 1,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: darkColorScheme.onSurface,
        ),
        toolbarTextStyle: GoogleFonts.poppins(color: darkColorScheme.onSurface),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: darkColorScheme.surface,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: darkColorScheme.onSurface,
        ),
        contentTextStyle: GoogleFonts.poppins(color: darkColorScheme.onSurface),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.poppins(
          color: darkColorScheme.onSurface.withAlpha(120),
        ),
        labelStyle: GoogleFonts.poppins(color: darkColorScheme.onSurface),
      ),

      chipTheme: ChipThemeData(labelStyle: GoogleFonts.poppins()),

      popupMenuTheme: PopupMenuThemeData(textStyle: GoogleFonts.poppins()),

      snackBarTheme: SnackBarThemeData(contentTextStyle: GoogleFonts.poppins()),
    );

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MyKost',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeController.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,
        home: const SplashScreen(),
      ),
    );
  }
}

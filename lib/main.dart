import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'supabase_config.dart';
import 'screen/blog_home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add global error handler to prevent crashes in production
  FlutterError.onError = (FlutterErrorDetails details) {
    print('Flutter Error: ${details.exception}');
    // In production, this logs errors without showing them to users
  };

  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    print('Supabase initialization error: $e');
    // Continue app even if Supabase fails
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HBTinsights',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: GoogleFonts.inter().fontFamily,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
            .copyWith(
              headlineLarge: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
              headlineMedium: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.25,
              ),
              headlineSmall: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
              titleLarge: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
              titleMedium: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.15,
              ),
              titleSmall: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
              bodyLarge: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.15,
                height: 1.5,
              ),
              bodyMedium: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.25,
                height: 1.4,
              ),
              bodySmall: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.4,
                height: 1.3,
              ),
              labelLarge: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
              labelMedium: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
              labelSmall: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const BlogHomePage(),
    );
  }
}

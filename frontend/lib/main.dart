import 'package:flutter/material.dart';
import 'package:frontend/image_upscaler_screen.dart';
import 'package:google_fonts/google_fonts.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RealScale SR',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[100],
        cardColor: Colors.white,
        textTheme: GoogleFonts.poppinsTextTheme(textTheme).apply(bodyColor: Colors.black87),
        primaryTextTheme: GoogleFonts.poppinsTextTheme(textTheme).apply(bodyColor: Colors.black87),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).primaryTextTheme),
      ),

      themeMode: _themeMode,
      home: ImageUpscalerScreen(
        themeMode: _themeMode,
        onThemeChanged: _changeTheme,
      ),
    );
  }
}

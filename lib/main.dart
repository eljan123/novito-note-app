import 'package:flutter/material.dart';
import 'screens/main_page.dart';

void main() {
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Novito',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        // Dark gray for note widgets
        cardTheme: const CardTheme(
          color: Color(0xFF212121), 
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Poppins', color: Colors.white),
          bodyMedium: TextStyle(fontFamily: 'Poppins', color: Colors.white70),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.orange,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      home: const MainPage(),
    );
  }
} 
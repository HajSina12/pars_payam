import 'package:flutter/material.dart';
import 'chat_screen.dart';

void main() {
  runApp(const ParsPayamApp());
}

class ParsPayamApp extends StatelessWidget {
  const ParsPayamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'پارس پیام',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1D2733), // رنگ پس‌زمینه تلگرام
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF242F3D),
          elevation: 1,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF64B5F6),
          secondary: Color(0xFF2B5278),
        ),
      ),
      home: const ChatScreen(),
    );
  }
}
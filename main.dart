import 'package:flutter/material.dart';
import 'package:tasbeeh/tasbeeh_home_page.dart';

void main() => runApp(TasbeehApp());

class TasbeehApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black,
                offset: Offset(0, 5),
              ),
            ],
          ),
        ),
      ),
      home:TasbeehHomePage(), // Ensure TasbeehHomePage is const for performance
    );
  }
}

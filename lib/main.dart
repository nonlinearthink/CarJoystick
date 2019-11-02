import 'package:flutter/material.dart';
import 'home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Control Center for my car",
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        primaryColorBrightness: Brightness.dark,
      ),
      home: HomePage(title: "Control Center"),
    );
  }
}

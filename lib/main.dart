import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const CuttingPlannerApp());
}

class CuttingPlannerApp extends StatelessWidget {
  const CuttingPlannerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'РезальНяш',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
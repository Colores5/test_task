import 'package:flutter/material.dart';
import 'package:test_task/test_task_app.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FirmwareListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

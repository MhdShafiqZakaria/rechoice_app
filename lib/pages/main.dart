import 'package:flutter/material.dart';
//import 'package:rechoice_app/auth/login_or_register.dart';
import 'package:rechoice_app/pages/dashboard.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: LoginOrRegister(),
      home: Dashboard()
    );
  }
}

import 'package:flutter/material.dart';
import 'package:rechoice_app/pages/auth/authenticate.dart';
import 'package:rechoice_app/pages/auth/loading_page.dart';
import 'package:rechoice_app/pages/auth/login_or_register.dart';
import 'package:rechoice_app/pages/landing.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});


  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authService,
      builder: (context, authService, child) {
        return StreamBuilder(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            Widget widget;
            if (snapshot.connectionState == ConnectionState.waiting) {
              widget = LoadingPage();
            } else if (snapshot.hasData) {
              widget = LandingPage();
            } else {
              widget = LoginOrRegister();
            }
            return widget;
          },
        );
      },
    );
  }
}

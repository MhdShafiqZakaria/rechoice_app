import 'package:flutter/material.dart';

class Mytextfield extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  const Mytextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.blue),
          ),
          fillColor: Colors.white,
          filled: true,
          hintText: hintText,
        ),
      ),
    );
  }
}

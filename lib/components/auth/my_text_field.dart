import 'package:flutter/material.dart';

class Mytextfield extends StatefulWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  final IconData icon;
  final bool showVisibilityToggle;

  const Mytextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.icon,
    this.showVisibilityToggle = false,
  });

  @override
  State<Mytextfield> createState() => _MytextfieldState();
}

class _MytextfieldState extends State<Mytextfield> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();

    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.showVisibilityToggle
              ? _isObscured
              : widget.obscureText,
          decoration: InputDecoration(
            prefixIcon: Icon(
              widget.icon,
              color: const Color.fromARGB(255, 217, 206, 206),
            ),
            suffixIcon: widget.showVisibilityToggle
                ? IconButton(
                    icon: Icon(
                      _isObscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  )
                : null,
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
            hintText: widget.hintText,
          ),
        ),
      ),
    );
  }
}

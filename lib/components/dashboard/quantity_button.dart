import 'package:flutter/material.dart';

class QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const QuantityButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

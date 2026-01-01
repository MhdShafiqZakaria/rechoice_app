import 'dart:io';

import 'package:flutter/material.dart';

Widget buildItemImage(String imagePath) {
  if (imagePath.isEmpty) {
    return Image.asset('assets/images/placeholder.png');
  }
  
  // Local file path
  if (imagePath.startsWith('/')) {
    final file = File(imagePath);
    if (file.existsSync()) {
      return Image.file(file);
    }
  }
  
  // Network URL
  if (imagePath.startsWith('http')) {
    return Image.network(
      imagePath,
      errorBuilder: (context, error, stack) {
        return Image.asset('assets/images/placeholder.png');
      },
    );
  }
  
  // Fallback
  return Image.asset('assets/images/placeholder.png');
}
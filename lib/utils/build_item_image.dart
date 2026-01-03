import 'dart:io';

import 'package:flutter/material.dart';

Widget buildItemImage(String imagePath, double width) {
    if (imagePath.isEmpty) {
      return Center(
        child: Icon(Icons.image_outlined, size: 60, color: Colors.grey),
      );
    }

    if (imagePath.startsWith('assets/images')) {
      return Image.asset(
        imagePath,
        width: width,
        height: 180,
        fit: BoxFit.fill,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.image_outlined, size: 60, color: Colors.grey),
      );
    }
    // Local file path
    if (imagePath.startsWith('/')) {
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: width,
          height: 180,
          fit: BoxFit.cover,
        );
      }
    }

    // Network URL
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width:width,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(Icons.image_outlined, size: 60, color: Colors.grey),
        ),
      );
    }

    // Fallback
    return Center(
      child: Icon(Icons.image_outlined, size: 60, color: Colors.grey),
    );
  }

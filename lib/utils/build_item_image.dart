import 'dart:io';
import 'package:flutter/material.dart';

Widget buildItemImage(String imagePath, double width) {
  print('🖼️ buildItemImage called');
  print('   Path: $imagePath');
  print('   Empty: ${imagePath.isEmpty}');
  print('   Starts with /: ${imagePath.startsWith('/')}');
  print('   Starts with http: ${imagePath.startsWith('http')}');
  
  if (imagePath.isEmpty) {
    print('   ❌ Showing fallback: empty path');
    return Center(
      child: Icon(Icons.image_outlined, size: 60, color: Colors.grey),
    );
  }

  // Asset images
  if (imagePath.startsWith('assets/')) {
    print('   ✅ Loading asset image');
    return Image.asset(
      imagePath,
      width: width,
      height: 180,
      fit: BoxFit.cover,
      errorBuilder: (_, __, error) {
        print('   ❌ Asset load failed: $error');
        return Center(child: Icon(Icons.image_outlined, size: 60, color: Colors.grey));
      },
    );
  }

  // Network URLs
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    print('   ✅ Loading network image');
    return Image.network(
      imagePath,
      width: width,
      height: 180,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          print('   ✅ Network image loaded');
          return child;
        }
        print('   ⏳ Loading network image...');
        return Center(child: CircularProgressIndicator());
      },
      errorBuilder: (_, __, error) {
        print('   ❌ Network load failed: $error');
        return Center(child: Icon(Icons.image_outlined, size: 60, color: Colors.grey));
      },
    );
  }

  // Local file paths
  print('   ✅ Attempting to load file');
  final file = File(imagePath);
  print('   File path: ${file.path}');
  
  return FutureBuilder<bool>(
    future: file.exists(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        print('   ⏳ Checking if file exists...');
        return Center(child: CircularProgressIndicator());
      }
      
      final exists = snapshot.data ?? false;
      print('   File exists: $exists');
      
      if (!exists) {
        print('   ❌ File not found');
        return Center(child: Icon(Icons.image_outlined, size: 60, color: Colors.grey));
      }
      
      return Image.file(
        file,
        width: width,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (_, __, error) {
          print('   ❌ File load failed: $error');
          return Center(child: Icon(Icons.image_outlined, size: 60, color: Colors.grey));
        },
      );
    },
  );
}
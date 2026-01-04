import 'dart:io';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

class LocalStorageService {
  static const String _imageBoxName = 'item_images';
  late Box<String> _imageBox;
  bool _isInitialized = false;

  final _initLock = Lock();
  final _saveLocks = <String, Lock>{};

  Future<void> init() async {
    if (_isInitialized) return;

    await _initLock.synchronized(() async {
      if (_isInitialized) return;
      await Hive.initFlutter();
      _imageBox = await Hive.openBox<String>(_imageBoxName);

      _isInitialized = true;
      // Fixed: Get appDir before using it
      final appDir = await getApplicationDocumentsDirectory();
      print('=== STORAGE PATHS ===');
      print('App directory: ${appDir.path}');
      print('Hive box: ${_imageBox.path}');
      print('Images folder: ${appDir.path}/item_images');
      print('====================');
    });
  }

  Future<String> saveItemImage(File imageFile, String itemId) async {
    final lock = _saveLocks.putIfAbsent(itemId, () => Lock());
    try {
      return await lock.synchronized(() async {
        if (!_isInitialized) await init();

        final appDir = await getApplicationDocumentsDirectory();
        final imageDir = Directory(path.join(appDir.path, 'item_images'));

        if (!await imageDir.exists()) {
          await imageDir.create(recursive: true);
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = '${itemId}_$timestamp.jpg';
        final savedPath = path.join(imageDir.path, fileName);

        await imageFile.copy(savedPath);
        await _imageBox.put(itemId, savedPath);

        return savedPath;
      });
    } finally {
      _saveLocks.remove(itemId);
    }
  }

  String? getItemImagePath(String itemId) {
    if (!_isInitialized) return null;
    return _imageBox.get(itemId);
  }

  File? getItemImageFile(String itemId) {
    if (!_isInitialized) return null;
    final imagePath = getItemImagePath(itemId);
    if (imagePath == null) return null;

    final file = File(imagePath);
    return file.existsSync() ? file : null;
  }

  Future<void> deleteItemImage(String itemId) async {
    final lock = _saveLocks.putIfAbsent(itemId, () => Lock());
    try {
      await lock.synchronized(() async {
        if (!_isInitialized) await init();

        final imagePath = getItemImagePath(itemId);
        if (imagePath != null) {
          final file = File(imagePath);
          if (await file.exists()) await file.delete();
          await _imageBox.delete(itemId);
        }
      });
    } finally {
      _saveLocks.remove(itemId);
    }
  }

  Future<List<String>> saveMultipleImages(
    List<File> imageFiles,
    String itemId,
  ) async {
    final lock = _saveLocks.putIfAbsent(itemId, () => Lock());
    try {
      return await lock.synchronized(() async {
        if (!_isInitialized) await init();

        final appDir = await getApplicationDocumentsDirectory();
        final imageDir = Directory(path.join(appDir.path, 'item_images'));

        if (!await imageDir.exists()) {
          await imageDir.create(recursive: true);
        }

        final savedPaths = <String>[];
        for (var i = 0; i < imageFiles.length; i++) {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = '${itemId}_${i}_$timestamp.jpg';
          final savedPath = path.join(imageDir.path, fileName);

          await imageFiles[i].copy(savedPath);
          savedPaths.add(savedPath);
        }

        if (savedPaths.isNotEmpty) {
          await _imageBox.put(itemId, savedPaths.first);
        }

        return savedPaths;
      });
    } finally {
      _saveLocks.remove(itemId);
    }
  }

  List<String> getAllItemIds() {
    if (!_isInitialized) return [];
    return _imageBox.keys.cast<String>().toList();
  }

  int get imageCount => _isInitialized ? _imageBox.length : 0;

  bool hasImage(String itemId) {
    if (!_isInitialized) return false;
    return _imageBox.containsKey(itemId);
  }

  Future<void> clearAll() async {
    if (!_isInitialized) await init();

    // Delete all files
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(path.join(appDir.path, 'item_images'));

    if (await imageDir.exists()) {
      await imageDir.delete(recursive: true);
    }

    // Clear Hive
    await _imageBox.clear();
  }

  Future<void> cleanupOrphanedImages(List<String> activeItemIds) async {
    if (!_isInitialized) await init();

    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(path.join(appDir.path, 'item_images'));

    if (!await imageDir.exists()) return;

    // Clean Hive entries
    final allKeys = _imageBox.keys.cast<String>().toList();
    for (var key in allKeys) {
      if (!activeItemIds.contains(key)) {
        final imagePath = _imageBox.get(key);
        if (imagePath != null) {
          final file = File(imagePath);
          if (await file.exists()) await file.delete();
        }
        await _imageBox.delete(key);
      }
    }

    // Clean orphaned files
    await for (var entity in imageDir.list()) {
      if (entity is File) {
        final fileName = path.basename(entity.path);
        final itemId = fileName.split('_').first;

        if (!activeItemIds.contains(itemId)) {
          await entity.delete();
        }
      }
    }
  }

  Future<int> getTotalStorageSize() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(path.join(appDir.path, 'item_images'));

    if (!await imageDir.exists()) return 0;

    int totalSize = 0;
    await for (var entity in imageDir.list()) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }

    return totalSize;
  }

  String formatStorageSize(int bytes) {
    if (bytes < 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      await _imageBox.close();
      _isInitialized = false;
    }
  }
}

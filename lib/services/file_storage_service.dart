import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';

class FileStorageService {
  static const String _webBoxName = 'web_files';

  Future<String> get _localPath async {
    if (kIsWeb) return '';
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File?> _localFile(String filename) async {
    if (kIsWeb) return null;
    final path = await _localPath;
    return File('$path/$filename');
  }

  Future<void> writeFile(String filename, String content) async {
    if (kIsWeb) {
      final box = await Hive.openBox<String>(_webBoxName);
      await box.put(filename, content);
      return;
    }
    final file = await _localFile(filename);
    await file?.writeAsString(content);
  }

  Future<String> readFile(String filename) async {
    if (kIsWeb) {
      final box = await Hive.openBox<String>(_webBoxName);
      return box.get(filename) ?? '';
    }
    try {
      final file = await _localFile(filename);
      if (file == null) return '';
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      return '';
    }
  }

  Future<bool> deleteFile(String filename) async {
    if (kIsWeb) {
      final box = await Hive.openBox<String>(_webBoxName);
      await box.delete(filename);
      return true;
    }
    try {
      final file = await _localFile(filename);
      if (file == null) return false;
      await file.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> listFiles() async {
    if (kIsWeb) {
      final box = await Hive.openBox<String>(_webBoxName);
      return box.keys.cast<String>().toList();
    }
    try {
      final path = await _localPath;
      final dir = Directory(path);
      if (!await dir.exists()) return [];
      final files = dir.listSync();
      return files
          .where((item) => item is File)
          .map((item) => item.path.split(Platform.pathSeparator).last)
          .toList();
    } catch (e) {
      return [];
    }
  }
}
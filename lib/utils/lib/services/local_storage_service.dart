import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class LocalStorageService {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<void> exportToFile(String data, String filename) async {
    final path = await _localPath;
    final file = File('$path/$filename');
    await file.writeAsString(data);
    
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Backup First Aid Stock Manager',
    );
  }

  static Future<String?> importFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        return await file.readAsString();
      }
    } catch (e) {
      debugPrint('Error importing file: $e');
    }
    return null;
  }
}

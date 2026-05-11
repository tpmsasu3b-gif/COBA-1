import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsProvider extends ChangeNotifier {
  AppSettings _settings = AppSettings();

  AppSettings get settings => _settings;

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('app_settings');
      if (settingsJson != null) {
        _settings = AppSettings.fromJson(jsonDecode(settingsJson));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_settings', jsonEncode(_settings.toJson()));
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    await updateSettings(_settings.copyWith(isDarkMode: !_settings.isDarkMode));
  }

  Future<void> setLowStockThreshold(int value) async {
    await updateSettings(_settings.copyWith(lowStockThreshold: value));
  }

  Future<void> setExpiryWarningDays(int days) async {
    await updateSettings(_settings.copyWith(expiryWarningDays: days));
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stock_history.dart';

class HistoryProvider extends ChangeNotifier {
  List<StockHistory> _history = [];

  List<StockHistory> get history => List.unmodifiable(_history);

  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('stock_history') ?? [];
      _history = historyJson
          .map((json) => StockHistory.fromJson(jsonDecode(json)))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  Future<void> addHistory({
    required String itemId,
    required String itemName,
    required int change,
    required int currentStock,
    String? notes,
  }) async {
    final entry = StockHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemId: itemId,
      itemName: itemName,
      change: change,
      currentStock: currentStock,
      timestamp: DateTime.now(),
      notes: notes,
    );

    _history.insert(0, entry);
    
    // Keep only last 100 entries
    if (_history.length > 100) {
      _history = _history.sublist(0, 100);
    }

    await _saveHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('stock_history');
    notifyListeners();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _history.map((h) => jsonEncode(h.toJson())).toList();
    await prefs.setStringList('stock_history', historyJson);
  }
}

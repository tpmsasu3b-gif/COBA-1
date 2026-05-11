import 'package:flutter/foundation.dart';

enum ItemCategory {
  perban('Perban & Plester', '🩹', Colors.orange),
  obat('Obat-obatan', '💊', Colors.green),
  alat('Alat Medis', '🩺', Colors.blue),
  cairan('Cairan', '💧', Colors.cyan),
  lainnya('Lainnya', '📦', Colors.purple);

  final String label;
  final String emoji;
  final Color color;

  const ItemCategory(this.label, this.emoji, this.color);
}

enum StockStatus {
  ok('Stok Aman', Colors.green),
  warning('Stok Rendah', Colors.orange),
  danger('Habis/Kadaluarsa', Colors.red);

  final String label;
  final Color color;

  const StockStatus(this.label, this.color);
}

class FirstAidItem {
  final String id;
  final String name;
  final ItemCategory category;
  final String unit;
  int stock;
  final int minStock;
  final DateTime? expiryDate;
  final String? notes;
  final DateTime createdAt;
  DateTime updatedAt;

  FirstAidItem({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.stock,
    required this.minStock,
    this.expiryDate,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  StockStatus get status {
    if (stock <= 0 || isExpired) return StockStatus.danger;
    if (stock <= minStock || isNearExpiry) return StockStatus.warning;
    return StockStatus.ok;
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now().subtract(const Duration(days: 1)));
  }

  bool get isNearExpiry {
    if (expiryDate == null) return false;
    final warningDate = DateTime.now().add(const Duration(days: 30));
    return expiryDate!.isBefore(warningDate) && !isExpired;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'unit': unit,
        'stock': stock,
        'minStock': minStock,
        'expiryDate': expiryDate?.toIso8601String(),
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory FirstAidItem.fromJson(Map<String, dynamic> json) => FirstAidItem(
        id: json['id'],
        name: json['name'],
        category: ItemCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => ItemCategory.lainnya,
        ),
        unit: json['unit'],
        stock: json['stock'],
        minStock: json['minStock'],
        expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
        notes: json['notes'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  FirstAidItem copyWith({
    String? id,
    String? name,
    ItemCategory? category,
    String? unit,
    int? stock,
    int? minStock,
    DateTime? expiryDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FirstAidItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      expiryDate: expiryDate ?? this.expiryDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

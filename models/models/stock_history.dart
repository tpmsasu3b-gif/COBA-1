class StockHistory {
  final String id;
  final String itemId;
  final String itemName;
  final int change;
  final int currentStock;
  final DateTime timestamp;
  final String? notes;

  StockHistory({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.change,
    required this.currentStock,
    required this.timestamp,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemId': itemId,
        'itemName': itemName,
        'change': change,
        'currentStock': currentStock,
        'timestamp': timestamp.toIso8601String(),
        'notes': notes,
      };

  factory StockHistory.fromJson(Map<String, dynamic> json) => StockHistory(
        id: json['id'],
        itemId: json['itemId'],
        itemName: json['itemName'],
        change: json['change'],
        currentStock: json['currentStock'],
        timestamp: DateTime.parse(json['timestamp']),
        notes: json['notes'],
      );
}

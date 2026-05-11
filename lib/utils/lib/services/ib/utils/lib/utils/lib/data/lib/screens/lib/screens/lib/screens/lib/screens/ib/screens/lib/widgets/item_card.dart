import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/first_aid_item.dart';
import '../utils/helpers.dart';

class ItemCard extends StatelessWidget {
  final FirstAidItem item;
  final Function(int delta) onStockChanged;
  final VoidCallback onTap;

  const ItemCard({
    super.key,
    required this.item,
    required this.onStockChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = item.status;
    final isExpired = item.isExpired;
    final isNearExpiry = item.isNearExpiry;

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onTap(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
        ],
      ),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: status.color,
                  width: 4,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: status.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          item.category.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.category.label} · ${item.stock} ${item.unit}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (item.expiryDate != null)
                            Text(
                              'Exp: ${Helpers.formatDate(item.expiryDate)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isExpired
                                    ? Colors.red
                                    : isNearExpiry
                                        ? Colors.orange
                                        : Colors.grey[600],
                                fontWeight: isExpired || isNearExpiry
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Stock Counter
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${item.stock}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: status.color,
                          ),
                        ),
                        Text(
                          item.unit,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildCounterButton(
                              Icons.remove,
                              () => onStockChanged(-1),
                              Colors.red,
                            ),
                            const SizedBox(width: 8),
                            _buildCounterButton(
                              Icons.add,
                              () => onStockChanged(1),
                              Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Badges
                if (isExpired || isNearExpiry || item.stock <= item.minStock)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        if (isExpired)
                          _buildBadge('KADALUARSA', Colors.red),
                        if (!isExpired && isNearExpiry)
                          _buildBadge('MAU KADALUARSA', Colors.orange),
                        if (item.stock <= item.minStock && item.stock > 0)
                          _buildBadge('STOK RENDAH', Colors.orange),
                        if (item.stock == 0)
                          _buildBadge('STOK HABIS', Colors.red),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onTap, Color color) {
    return Material(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8,  

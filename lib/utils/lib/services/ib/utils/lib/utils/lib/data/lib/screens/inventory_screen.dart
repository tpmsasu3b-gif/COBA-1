import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/first_aid_item.dart';
import '../providers/inventory_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/item_card.dart';
import '../widgets/search_bar.dart';
import '../widgets/empty_state.dart';
import 'add_item_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = '';
  ItemCategory? _selectedCategory;
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        final filteredItems = provider.searchItems(
          _searchQuery,
          category: _selectedCategory,
          status: _filterStatus == 'all' ? null : _filterStatus,
        );

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 180,
                floating: true,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🩹 First Aid Box',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Stock Manager',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Stats Row
                            Row(
                              children: [
                                _buildStatChip(
                                  'Aman',
                                  provider.okCount,
                                  Colors.green,
                                ),
                                const SizedBox(width: 8),
                                _buildStatChip(
                                  'Rendah',
                                  provider.warningCount,
                                  Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                _buildStatChip(
                                  'Bahaya',
                                  provider.dangerCount,
                                  Colors.red,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Search & Filters
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CustomSearchBar(
                        onChanged: (value) => setState(() => _searchQuery = value),
                        hint: 'Cari item P3K...',
                      ),
                      const SizedBox(height: 12),
                      // Category Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildCategoryChip(null, 'Semua'),
                            ...ItemCategory.values.map(
                              (cat) => _buildCategoryChip(cat, cat.label),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Status Filter
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildStatusChip('all', 'Semua'),
                            _buildStatusChip('low', 'Stok Rendah'),
                            _buildStatusChip('expired', 'Kadaluarsa'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Items List
              filteredItems.isEmpty
                  ? const SliverFillRemaining(
                      child: EmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: 'Tidak ada item',
                        subtitle: 'Tambahkan item P3K baru',
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = filteredItems[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ItemCard(
                                item: item,
                                onStockChanged: (delta) => _updateStock(item, delta),
                                onTap: () => _editItem(item),
                              ),
                            );
                          },
                          childCount: filteredItems.length,
                        ),
                      ),
                    ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addNewItem(),
            icon: const Icon(Icons.add),
            label: const Text('Tambah'),
          ),
        );
      },
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $count',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(ItemCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          setState(() => _selectedCategory = selected ? category : null);
        },
        selectedColor: const Color(0xFFE74C3C).withOpacity(0.2),
        checkmarkColor: const Color(0xFFE74C3C),
      ),
    );
  }

  Widget _buildStatusChip(String status, String label) {
    final isSelected = _filterStatus == status;
    Color color;
    switch (status) {
      case 'low':
        color = Colors.orange;
        break;
      case 'expired':
        color = Colors.red;
        break;
      default:
        color = const Color(0xFFE74C3C);
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          setState(() => _filterStatus = selected ? status : 'all');
        },
        selectedColor: color.withOpacity(0.2),
      ),
    );
  }

  void _updateStock(FirstAidItem item, int delta) async {
    try {
      await context.read<InventoryProvider>().updateStock(item.id, delta);
      await context.read<HistoryProvider>().addHistory(
        itemId: item.id,
        itemName: item.name,
        change: delta,
        currentStock: item.stock + delta,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} ${delta > 0 ? 'ditambah' : 'dikurangi'} ${delta.abs()} ${item.unit}'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _addNewItem() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddItemScreen()),
    );
  }

  void _editItem(FirstAidItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddItemScreen(item: item)),
    );
  }
}

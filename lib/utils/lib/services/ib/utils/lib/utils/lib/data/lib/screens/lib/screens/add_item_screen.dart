import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/first_aid_item.dart';
import '../providers/inventory_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class AddItemScreen extends StatefulWidget {
  final FirstAidItem? item;

  const AddItemScreen({super.key, this.item});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _minStockController = TextEditingController(text: '2');
  final _notesController = TextEditingController();

  ItemCategory _category = ItemCategory.perban;
  String _unit = 'Pcs';
  DateTime? _expiryDate;

  bool get isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final item = widget.item!;
      _nameController.text = item.name;
      _stockController.text = item.stock.toString();
      _minStockController.text = item.minStock.toString();
      _notesController.text = item.notes ?? '';
      _category = item.category;
      _unit = item.unit;
      _expiryDate = item.expiryDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Item' : 'Tambah Item'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteItem,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Item *',
                hintText: 'Contoh: Perban Gulung',
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama item wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category & Unit
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ItemCategory>(
                    value: _category,
                    decoration: const InputDecoration(
                      labelText: 'Kategori *',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: ItemCategory.values.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text('${cat.emoji} ${cat.label}'),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _category = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _unit,
                    decoration: const InputDecoration(
                      labelText: 'Satuan *',
                      prefixIcon: Icon(Icons.straighten_outlined),
                    ),
                    items: AppConstants.units.map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _unit = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stock & Min Stock
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stok Saat Ini *',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib diisi';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Harus angka';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _minStockController,
                    decoration: const InputDecoration(
                      labelText: 'Stok Minimum *',
                      prefixIcon: Icon(Icons.warning_amber_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib diisi';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Harus angka';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Expiry Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Tanggal Kadaluarsa'),
              subtitle: Text(
                _expiryDate != null
                    ? Helpers.formatDate(_expiryDate)
                    : 'Tidak ada',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_expiryDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _expiryDate = null),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit_calendar),
                    onPressed: _pickExpiryDate,
                  ),
                ],
              ),
            ),
            const Divider(),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan',
                hintText: 'Catatan tambahan...',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _saveItem,
              child: Text(isEditing ? 'Simpan Perubahan' : 'Tambah Item'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  void _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    final item = FirstAidItem(
      id: isEditing ? widget.item!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      category: _category,
      unit: _unit,
      stock: int.parse(_stockController.text),
      minStock: int.parse(_minStockController.text),
      expiryDate: _expiryDate,
      notes: _notesController.text.trim(),
    );

    final provider = context.read<InventoryProvider>();
    
    if (isEditing) {
      await provider.updateItem(item);
    } else {
      await provider.addItem(item);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Item diperbarui!' : 'Item ditambahkan!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _deleteItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Item?'),
        content: const Text('Item akan dihapus permanen. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<InventoryProvider>().deleteItem(widget.item!.id);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

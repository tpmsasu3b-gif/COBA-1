import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/inventory_provider.dart';
import '../services/local_storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          final settings = settingsProvider.settings;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Appearance
              const Text(
                'Tampilan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: SwitchListTile(
                  title: const Text('Mode Gelap'),
                  subtitle: const Text('Gunakan tema gelap'),
                  value: settings.isDarkMode,
                  onChanged: (_) => settingsProvider.toggleDarkMode(),
                  secondary: const Icon(Icons.dark_mode_outlined),
                ),
              ),
              const SizedBox(height: 24),

              // Stock Settings
              const Text(
                'Pengaturan Stok',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.warning_amber_outlined),
                      title: const Text('Batas Stok Rendah'),
                      subtitle: Text('${settings.lowStockThreshold} unit'),
                      trailing: SizedBox(
                        width: 100,
                        child: TextFormField(
                          initialValue: settings.lowStockThreshold.toString(),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            final intValue = int.tryParse(value);
                            if (intValue != null && intValue > 0) {
                              settingsProvider.setLowStockThreshold(intValue);
                            }
                          },
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: const Text('Peringatan Kadaluarsa'),
                      subtitle: Text('${settings.expiryWarningDays} hari sebelum'),
                      trailing: SizedBox(
                        width: 100,
                        child: TextFormField(
                          initialValue: settings.expiryWarningDays.toString(),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            final intValue = int.tryParse(value);
                            if (intValue != null && intValue > 0) {
                              settingsProvider.setExpiryWarningDays(intValue);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Data Management
              const Text(
                'Manajemen Data',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.download_outlined),
                      title: const Text('Export Data'),
                      subtitle: const Text('Simpan backup ke file JSON'),
                      onTap: () => _exportData(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.upload_outlined),
                      title: const Text('Import Data'),
                      subtitle: const Text('Pulihkan dari file JSON'),
                      onTap: () => _importData(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.refresh_outlined),
                      title: const Text('Muat Item Standar'),
                      subtitle: const Text('Tambahkan item P3K standar'),
                      onTap: () => _loadDefaultItems(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.delete_forever, color: Colors.red),
                      title: const Text('Reset Semua Data', style: TextStyle(color: Colors.red)),
                      subtitle: const Text('Hapus semua item dan riwayat'),
                      onTap: () => _resetData(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // About
              const Text(
                'Tentang',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Card(
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('First Aid Stock Manager'),
                  subtitle: Text('Versi 1.0.0\nAplikasi manajemen stok kotak P3K'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final provider = context.read<InventoryProvider>();
      final data = await provider.exportData();
      await LocalStorageService.exportToFile(
        data,
        'p3k-backup-${DateTime.now().toIso8601String().split('T')[0]}.json',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil diexport!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal export: $e')),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    try {
      final data = await LocalStorageService.importFromFile();
      if (data != null) {
        await context.read<InventoryProvider>().importData(data);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data berhasil diimport!')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal import: $e')),
        );
      }
    }
  }

  void _loadDefaultItems(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Muat Item Standar?'),
        content: const Text('Item standar P3K akan ditambahkan. Item yang sudah ada tidak akan terhapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Muat'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<InventoryProvider>().loadDefaultItems();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item standar dimuat!')),
        );
      }
    }
  }

  void _resetData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Semua Data?'),
        content: const Text('PERINGATAN: Semua data akan dihapus permanen!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<InventoryProvider>().resetAllData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua data direset')),
        );
      }
    }
  }
}

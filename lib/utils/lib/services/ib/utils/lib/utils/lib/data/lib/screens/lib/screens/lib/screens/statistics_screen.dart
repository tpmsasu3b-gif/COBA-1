import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/inventory_provider.dart';
import '../models/first_aid_item.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        final categoryData = _getCategoryData(provider.items);
        final statusData = _getStatusData(provider.items);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Statistik'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                Row(
                  children: [
                    _buildSummaryCard(
                      'Total Item',
                      provider.totalItems.toString(),
                      Icons.inventory_2,
                      Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _buildSummaryCard(
                      'Stok Aman',
                      provider.okCount.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildSummaryCard(
                      'Stok Rendah',
                      provider.warningCount.toString(),
                      Icons.warning,
                      Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _buildSummaryCard(
                      'Perlu Perhatian',
                      provider.dangerCount.toString(),
                      Icons.error,
                      Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Category Chart
                const Text(
                  'Distribusi Kategori',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: categoryData,
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Status Chart
                const Text(
                  'Status Stok',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      barGroups: statusData,
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const labels = ['Aman', 'Rendah', 'Bahaya'];
                              return Text(
                                labels[value.toInt()],
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _getCategoryData(List<FirstAidItem> items) {
    final Map<ItemCategory, int> counts = {};
    for (final item in items) {
      counts[item.category] = (counts[item.category] ?? 0) + 1;
    }

    return counts.entries.map((entry) {
      final color = entry.key.color;
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${entry.key.emoji}\n${entry.value}',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _getStatusData(List<FirstAidItem> items) {
    int ok = 0, warning = 0, danger = 0;
    for (final item in items) {
      switch (item.status) {
        case StockStatus.ok:
          ok++;
          break;
        case StockStatus.warning:
          warning++;
          break;
        case StockStatus.danger:
          danger++;
          break;
      }
    }

    return [
      BarChartGroupData(x: 0, barRods: [
        BarChartRodData(toY: ok.toDouble(), color: Colors.green, width: 30),
      ]),
      BarChartGroupData(x: 1, barRods: [
        BarChartRodData(toY: warning.toDouble(), color: Colors.orange, width: 30),
      ]),
      BarChartGroupData(x: 2, barRods: [
        BarChartRodData(toY: danger.toDouble(), color: Colors.red, width: 30),
      ]),
    ];
  }
}

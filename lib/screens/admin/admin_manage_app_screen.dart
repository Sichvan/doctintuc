// lib/screens/admin/admin_manage_app_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/categories.dart'; // Sử dụng để dịch tên thể loại

class AdminManageAppScreen extends StatefulWidget {
  static const routeName = '/admin-manage-app';
  const AdminManageAppScreen({super.key});

  @override
  State<AdminManageAppScreen> createState() => _AdminManageAppScreenState();
}

class _AdminManageAppScreenState extends State<AdminManageAppScreen> {
  late Future<void> _fetchStatsFuture;

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).token!;
    _fetchStatsFuture = Provider.of<AdminProvider>(context, listen: false)
        .fetchCategoryStats(token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Ứng dụng (Thống kê)'),
      ),
      body: FutureBuilder(
        future: _fetchStatsFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Consumer<AdminProvider>(
            builder: (ctx, adminProvider, _) {
              if (adminProvider.isLoadingCategoryStats) {
                return const Center(child: CircularProgressIndicator());
              }
              if (adminProvider.categoryStats == null) {
                return const Center(child: Text('Không thể tải dữ liệu thống kê.'));
              }

              final viewStats = adminProvider.categoryStats!['viewStats'] ?? [];
              final saveStats = adminProvider.categoryStats!['saveStats'] ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildChartCard(
                      context,
                      '📊 Thống kê lượt xem theo thể loại',
                      viewStats,
                      Colors.blueAccent,
                    ),
                    const SizedBox(height: 28),
                    _buildChartCard(
                      context,
                      '💾 Thống kê lượt lưu theo thể loại',
                      saveStats,
                      Colors.green,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Responsive chart card
  Widget _buildChartCard(
      BuildContext context, String title, List statsData, Color color) {
    if (statsData.isEmpty) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              const Text('Chưa có dữ liệu.'),
            ],
          ),
        ),
      );
    }

    final double maxCount =
    statsData.map<num>((e) => e['count'] as num).reduce(max).toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double chartHeight = max(180, constraints.maxWidth * 0.4);

        return Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: chartHeight,
                  child: BarChart(
                    BarChartData(
                      maxY: maxCount * 1.2,
                      alignment: BarChartAlignment.spaceAround,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.black87,
                          tooltipRoundedRadius: 6,
                          tooltipPadding: const EdgeInsets.all(8),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final categoryKey =
                            statsData[groupIndex]['category'];
                            final categoryName =
                                AppCategories.categories[categoryKey] ??
                                    categoryKey;
                            final count = rod.toY.toInt();

                            return BarTooltipItem(
                              '$categoryName\n$count lượt',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= statsData.length) {
                                return const SizedBox.shrink();
                              }
                              final categoryKey =
                              statsData[index]['category'];
                              final categoryName =
                                  AppCategories.categories[categoryKey] ??
                                      categoryKey;

                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 6,
                                child: Transform.rotate(
                                  angle: -pi / 6, // nghiêng 30° để dễ đọc
                                  child: SizedBox(
                                    width: constraints.maxWidth /
                                        (statsData.length > 4
                                            ? 3.5
                                            : statsData.length),
                                    child: Text(
                                      categoryName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval:
                        max(1, (maxCount / 4).roundToDouble()),
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.shade300,
                          strokeWidth: 0.8,
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          bottom: BorderSide(
                              color: Colors.grey.shade400, width: 1),
                        ),
                      ),
                      barGroups: statsData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: (data['count'] as num).toDouble(),
                              color: color,
                              width: min(18, constraints.maxWidth / 20),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
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
}

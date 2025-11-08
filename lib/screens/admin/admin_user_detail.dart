import 'dart:math';
import 'package:flutter/material.dart' hide Colors;
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/material.dart' as material show Colors;
import '../../utils/categories.dart'; // Import danh mục thể loại

// Danh sách màu cho biểu đồ
const List<Color> _chartColors = [
  material.Colors.blue,
  material.Colors.red,
  material.Colors.green,
  material.Colors.orange,
  material.Colors.purple,
  material.Colors.yellow,
  material.Colors.cyan,
  material.Colors.teal,
  material.Colors.pink,
  material.Colors.indigo,
  material.Colors.lime,
  material.Colors.amber,
];

class AdminUserDetailStatsScreen extends StatefulWidget {
  static const routeName = '/admin-user-detail-stats';
  const AdminUserDetailStatsScreen({super.key});

  @override
  State<AdminUserDetailStatsScreen> createState() =>
      _AdminUserDetailStatsScreenState();
}

class _AdminUserDetailStatsScreenState
    extends State<AdminUserDetailStatsScreen> {
  late Future<void> _fetchStatsFuture;
  late AppUser _user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _user = ModalRoute.of(context)!.settings.arguments as AppUser;
    final token = Provider.of<AuthProvider>(context, listen: false).token!;
    _fetchStatsFuture = Provider.of<AdminProvider>(context, listen: false)
        .fetchUserCategoryStats(_user.id, token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thống kê: ${_user.email}'),
      ),
      body: FutureBuilder(
        future: _fetchStatsFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Consumer<AdminProvider>(
            builder: (context, adminProvider, child) {
              if (adminProvider.isLoadingUserCategoryStats) {
                return const Center(child: CircularProgressIndicator());
              }
              if (adminProvider.errorUserCategoryStats != null) {
                return Center(
                    child: Text(adminProvider.errorUserCategoryStats!));
              }
              if (adminProvider.userCategoryStats == null) {
                return const Center(
                    child: Text('Không có dữ liệu thống kê.'));
              }

              final List<dynamic> viewStatsList =
                  adminProvider.userCategoryStats!['viewStats'] ?? [];
              final List<dynamic> saveStatsList =
                  adminProvider.userCategoryStats!['saveStats'] ?? [];

              if (viewStatsList.isEmpty && saveStatsList.isEmpty) {
                return const Center(
                    child: Text('Người dùng này chưa có hoạt động nào.'));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Lượt Xem Theo Thể Loại',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    _buildStatsChart(context, viewStatsList),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    Text(
                      'Lượt Lưu Theo Thể Loại',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    _buildStatsChart(context, saveStatsList),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Biểu đồ tròn responsive
  Widget _buildStatsChart(BuildContext context, List<dynamic> statsList) {
    if (statsList.isEmpty) {
      return const Center(
        heightFactor: 5,
        child: Text('Không có dữ liệu'),
      );
    }

    // Tổng số lượt
    final int total = statsList.fold(0, (sum, item) => sum + (item['count'] as int));
    if (total == 0) {
      return const Center(
        heightFactor: 5,
        child: Text('Không có dữ liệu'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double chartSize = min(constraints.maxWidth * 0.8, 300);
        final double radius = chartSize / 2.8;
        final double centerHole = radius / 2.5;

        final List<PieChartSectionData> sections = [];
        for (int i = 0; i < statsList.length; i++) {
          final stat = statsList[i];
          final int count = stat['count'];
          final double percentage = (count / total) * 100;
          final Color color = _chartColors[i % _chartColors.length];
          final bool showTitle = percentage >= 7.0;

          sections.add(
            PieChartSectionData(
              color: color,
              value: count.toDouble(),
              title: showTitle ? '${percentage.toStringAsFixed(1)}%' : '',
              radius: radius,
              titlePositionPercentageOffset: 0.7,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: material.Colors.white,
                shadows: [Shadow(color: material.Colors.black, blurRadius: 2)],
              ),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // Biểu đồ tròn
            Center(
              child: SizedBox(
                width: chartSize,
                height: chartSize,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: centerHole,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Danh sách chú thích (legend)
            Wrap(
              alignment: WrapAlignment.center,
              runSpacing: 6,
              spacing: 12,
              children: statsList.asMap().entries.map((entry) {
                final int index = entry.key;
                final stat = entry.value;
                final Color color = _chartColors[index % _chartColors.length];
                final String categoryKey = stat['category'];
                final String categoryName =
                    AppCategories.categories[categoryKey] ?? categoryKey;
                final int count = stat['count'];

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 14, height: 14, color: color),
                    const SizedBox(width: 4),
                    Text(
                      '$categoryName: $count',
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }
}

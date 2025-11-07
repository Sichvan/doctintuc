// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_data_provider.dart';
import '../widgets/article_list_item.dart';
import '../l10n/app_localizations.dart';

class HistoryScreen extends StatefulWidget {
  static const routeName = '/history';
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<void> _fetchHistoryFuture;

  @override
  void initState() {
    super.initState();
    // Tải lịch sử khi màn hình được mở
    _fetchHistoryFuture = Provider.of<UserDataProvider>(context, listen: false).fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    // Bây giờ 'l10n' sẽ được nhận diện
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        // Sử dụng l10n đã có của bạn
        title: Text(l10n.viewHistory),
      ),
      body: FutureBuilder(
        future: _fetchHistoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // TODO: Thêm key này vào file .arb
            return Center(child: Text('Lỗi khi tải lịch sử.'));
          } else {
            // Dùng Consumer để lấy dữ liệu đã được fetch
            return Consumer<UserDataProvider>(
              builder: (context, userData, child) {
                if (userData.history.isEmpty) {
                  return Center(
                    child: Text(
                      // TODO: Thêm key này vào file .arb
                      'Không có gì trong lịch sử của bạn.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                }

                // Hiển thị danh sách dùng ArticleListItem
                return ListView.builder(
                  itemCount: userData.history.length,
                  itemBuilder: (ctx, index) {
                    final article = userData.history[index];
                    return ArticleListItem(article: article);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
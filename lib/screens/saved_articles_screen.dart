// lib/screens/saved_articles_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_data_provider.dart';
import '../widgets/article_list_item.dart';
import '../l10n/app_localizations.dart';

class SavedArticlesScreen extends StatelessWidget {
  static const routeName = '/saved-articles';
  const SavedArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Bây giờ 'l10n' sẽ được nhận diện
    final l10n = AppLocalizations.of(context)!;

    final userData = context.watch<UserDataProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.savedArticles),
      ),
      body: userData.isLoadingSaved
          ? const Center(child: CircularProgressIndicator())
          : userData.savedArticles.isEmpty
          ? Center(
        child: Text(
          // TODO: Thêm key này vào file .arb
          'Bạn chưa lưu bài viết nào.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      )
          : ListView.builder(
        itemCount: userData.savedArticles.length,
        itemBuilder: (ctx, index) {
          final article = userData.savedArticles[index];
          return ArticleListItem(article: article);
        },
      ),
    );
  }
}
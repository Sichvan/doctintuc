// lib/widgets/article_list_item.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/display_article.dart';
import '../providers/auth_provider.dart';
import '../providers/user_data_provider.dart';
import '../screens/article_detail_admin_content_screen.dart';
import '../screens/article_detail_screen.dart';
import '../screens/auth_screen.dart';
import '../l10n/app_localizations.dart';

class ArticleListItem extends StatelessWidget {
  final DisplayArticle article;

  const ArticleListItem({
    Key? key,
    required this.article,
  }) : super(key: key);

  void _showLoginRequiredDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.loginRequiredTitle),
        content: Text(l10n.loginRequiredMessage),
        actions: [
          TextButton(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text(l10n.login),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushNamed(AuthScreen.routeName);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy provider
    final auth = context.watch<AuthProvider>();
    final userData = context.watch<UserDataProvider>();
    final l10n = AppLocalizations.of(context)!;

    // Kiểm tra trạng thái đã lưu
    final bool isSaved = userData.isSaved(article.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              // --- THÊM VÀO LỊCH SỬ KHI BẤM VÀO ---
              if (auth.isAuth) {
                context.read<UserDataProvider>().addToHistory(article);
              }
              // --- (kết thúc) ---

              // Điều hướng đến màn hình chi tiết
              if (article.isFromAdmin) {
                Navigator.pushNamed(
                  context,
                  ArticleDetailAdminContentScreen.routeName,
                  arguments: article,
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticleDetailScreen(
                      articleUrl: article.articleUrl,
                      articleTitle: article.title,
                      articleId: article.id,
                    ),
                  ),
                );
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hình ảnh
                if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
                  Image.network(
                    article.imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 200,
                        child: Icon(Icons.broken_image_outlined,
                            size: 50, color: Colors.grey),
                      );
                    },
                  ),
                // Tiêu đề và Nguồn
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article.sourceName,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Dải nút (Lưu, Bình luận)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // --- NÚT LƯU BÀI VIẾT (ĐÃ CẬP NHẬT) ---
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved ? Theme.of(context).primaryColor : null,
                  ),
                  tooltip: l10n.savedArticles,
                  onPressed: () {
                    if (!auth.isAuth) {
                      _showLoginRequiredDialog(context);
                      return;
                    }
                    // Gọi hàm toggle
                    context.read<UserDataProvider>().toggleSaveArticle(article);
                  },
                ),
                // --- NÚT BÌNH LUẬN (GIỮ NGUYÊN) ---
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  tooltip: 'Bình luận', // TODO: Thêm vào l10n
                  onPressed: () {
                    if (!auth.isAuth) {
                      _showLoginRequiredDialog(context);
                      return;
                    }
                    // TODO: Logic bình luận (sử dụng article.id)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('TODO: Xử lý bình luận')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/display_article.dart';
import '../providers/auth_provider.dart';
import '../providers/user_data_provider.dart';
import '../screens/article_detail_admin.dart';
import '../screens/article_detail.dart';
import '../screens/login_register.dart';
import '../l10n/app_localizations.dart';

class ArticleListItem extends StatelessWidget {
  final DisplayArticle article;

  const ArticleListItem({
    super.key,
    required this.article,
  });

  // Hàm private hiển thị dialog yêu cầu đăng nhập
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
    final auth = context.watch<AuthProvider>();
    final userData = context.watch<UserDataProvider>();
    final l10n = AppLocalizations.of(context)!;

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
              if (auth.isAuth) {
                context.read<UserDataProvider>().addToHistory(article);
              }

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // --- NÚT LƯU BÀI VIẾT ---
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved ? Theme.of(context).primaryColor : null,
                  ),
                  tooltip: l10n.savedArticles,
                  onPressed: () {
                    // Yêu cầu đăng nhập để LƯU
                    if (!auth.isAuth) {
                      _showLoginRequiredDialog(context);
                      return;
                    }
                    context.read<UserDataProvider>().toggleSaveArticle(article);
                  },
                ),
                // --- NÚT CHIA SẺ ---
                IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: l10n.shareArticle,
                  onPressed: () {

                    // === THÊM LOGIC YÊU CẦU ĐĂNG NHẬP ĐỂ CHIA SẺ ===
                    if (!auth.isAuth) {
                      _showLoginRequiredDialog(context);
                      return;
                    }
                    // ===============================================

                    String textToShare;
                    if (article.isFromAdmin) {
                      String contentSnippet = article.adminContent ?? '';
                      if (contentSnippet.length > 150) {
                        contentSnippet =
                        '${contentSnippet.substring(0, 150)}...';
                      }
                      textToShare =
                      '${article.title}\n\n$contentSnippet\n\n(${l10n.appName})';
                    } else {
                      textToShare = '${article.title}\n\n${article.articleUrl}';
                    }

                    final box = context.findRenderObject() as RenderBox?;

                    SharePlus.instance.share(
                      ShareParams(
                        text: textToShare,
                        subject: article.title,
                        sharePositionOrigin: box != null
                            ? box.localToGlobal(Offset.zero) & box.size
                            : null,
                      ),
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
import 'package:flutter/material.dart';
import '../models/display_article.dart';
import 'package:intl/intl.dart';

class ArticleDetailAdminContentScreen extends StatelessWidget {
  static const routeName = '/article-detail-admin';

  const ArticleDetailAdminContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final article =
    ModalRoute.of(context)!.settings.arguments as DisplayArticle;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          article.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${article.sourceName} - ${DateFormat('dd/MM/yyyy, HH:mm').format(article.pubDate)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  article.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 200,
                      child: Center(
                          child: Icon(Icons.broken_image_outlined,
                              size: 50, color: Colors.grey)),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),

            Text(
              article.adminContent ?? 'Không có nội dung chi tiết.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
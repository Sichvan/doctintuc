// lib/screens/article_detail.dart
import 'package:flutter/material.dart';
import 'package:readability/article.dart' as readability;
import 'package:readability/readability.dart' as readability;
import 'package:flutter_html/flutter_html.dart';

class ArticleDetailScreen extends StatefulWidget {
  final String articleUrl;
  final String articleTitle;
  final String articleId;

  const ArticleDetailScreen({
    super.key,
    required this.articleUrl,
    required this.articleTitle,
    required this.articleId,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late final Future<readability.Article?> _articleFuture;

  @override
  void initState() {
    super.initState();
    _articleFuture = readability.parseAsync(widget.articleUrl).then((article) {
      return article;
    }).catchError((error) {
      print('Readability Error: $error');
      return null;
    });
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.articleTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: FutureBuilder<readability.Article?>(
        future: _articleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                      'Không thể tải nội dung bài viết. Vui lòng thử lại.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _articleFuture = readability.parseAsync(widget.articleUrl)
                          .catchError((_) => null);
                    }),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          } else {
            final article = snapshot.data!;
            final title = article.title ?? widget.articleTitle;
            final content = article.content ?? '';
            final excerpt = article.excerpt ?? '';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isNotEmpty ? title : widget.articleTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (content.isNotEmpty)
                    Html(
                      data: content,
                      style: {
                        'body': Style(
                          fontSize: FontSize(16),
                          lineHeight: LineHeight.number(1.5),
                        ),
                      },
                      onLinkTap: (url, _, __) {
                        // TODO: Xử lý mở link (nếu cần)
                      },
                    )
                  else
                    const Text(
                      'Không có nội dung.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  if (excerpt.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Tóm tắt: $excerpt',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
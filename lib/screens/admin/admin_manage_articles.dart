import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/admin_article.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/categories.dart';
import 'admin_edit.dart';

class AdminManageArticlesScreen extends StatefulWidget {
  static const routeName = '/admin-manage-articles';
  const AdminManageArticlesScreen({super.key});

  @override
  State<AdminManageArticlesScreen> createState() =>
      _AdminManageArticlesScreenState();
}

class _AdminManageArticlesScreenState extends State<AdminManageArticlesScreen> {
  late Future<void> _fetchArticlesFuture;

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).token!;
    // Gọi hàm fetchArticles
    _fetchArticlesFuture =
        Provider.of<AdminProvider>(context, listen: false).fetchArticles(token);
  }

  // Hiển thị dialog lỗi
  Future<void> _showErrorDialog(String message) async {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  // Hiển thị dialog xác nhận xóa
  Future<void> _confirmDelete(String articleId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận Xóa'),
        content: Text('Bạn có chắc muốn xóa bài viết "$title"?'),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final token = Provider.of<AuthProvider>(context, listen: false).token!;
        await Provider.of<AdminProvider>(context, listen: false)
            .deleteArticle(articleId, token);
      } catch (e) {
        await _showErrorDialog(e.toString());
      }
    }
  }

  // Điều hướng đến trang Sửa/Thêm
  void _navigateToEditScreen(AdminArticle? article) {
    // --- SỬA LỖI ---
    // Truyền cả object 'article' (có thể null)
    Navigator.of(context)
        .pushNamed(AdminEditArticleScreen.routeName, arguments: article)
    // --- KẾT THÚC SỬA ---
        .then((_) {
      // Tự động refresh khi quay lại
      final token = Provider.of<AuthProvider>(context, listen: false).token!;
      setState(() {
        _fetchArticlesFuture =
            Provider.of<AdminProvider>(context, listen: false)
                .fetchArticles(token);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Bài viết'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToEditScreen(null), // Thêm mới
          ),
        ],
      ),
      body: FutureBuilder(
        future: _fetchArticlesFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Đã xảy ra lỗi khi tải: ${snapshot.error}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Nút thử lại
                      final token =
                      Provider.of<AuthProvider>(context, listen: false)
                          .token!;
                      setState(() {
                        _fetchArticlesFuture =
                            Provider.of<AdminProvider>(context, listen: false)
                                .fetchArticles(token);
                      });
                    },
                    child: const Text('Thử lại'),
                  )
                ],
              ),
            );
          }

          return Consumer<AdminProvider>(
            builder: (context, adminProvider, child) {
              // Chúng ta vẫn có thể dùng isLoadingArticles để hiển thị loading
              // khi xóa, thay vì dùng FutureBuilder
              if (adminProvider.isLoadingArticles &&
                  adminProvider.articles.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (adminProvider.articles.isEmpty) {
                return const Center(
                  child: Text('Chưa có bài viết nào do Admin tạo.'),
                );
              }

              return ListView.builder(
                itemCount: adminProvider.articles.length,
                itemBuilder: (ctx, index) {
                  final article = adminProvider.articles[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    child: ListTile(
                      title: Text(article.title),
                      subtitle: Text(
                          'Thể loại: ${AppCategories.categories[article.category] ?? article.category} | ${AppCategories.languages[article.language] ?? article.language}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit_outlined,
                                color: Theme.of(context).primaryColor),
                            onPressed: () =>
                                _navigateToEditScreen(article), // Sửa
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () =>
                                _confirmDelete(article.id, article.title),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}


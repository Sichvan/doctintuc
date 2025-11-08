import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/app_localizations_vi.dart';
import '../home.dart';
import 'admin_manage_app.dart';
import 'admin_manage_users.dart';
import 'admin_manage_articles.dart';

class AdminDashboardScreen extends StatelessWidget {
  static const routeName = '/admin-dashboard';

  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final l10n = AppLocalizationsVi(); // Khóa ngôn ngữ sang Tiếng Việt

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminDashboard),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme(!themeProvider.isDarkMode);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
            },
          ),
        ],
      ),
      // SỬA: Đổi từ GridView sang ListView
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          _buildDashboardListItem(
            context: context,
            icon: Icons.article_outlined,
            title: l10n.manageArticles, // Quản lý Bài viết
            onTap: () {
              Navigator.of(context)
                  .pushNamed(AdminManageArticlesScreen.routeName);
            },
          ),
          _buildDashboardListItem(
            context: context,
            icon: Icons.people_outline,
            title: l10n.manageUsers, // Quản lý Tài khoản
            onTap: () {
              Navigator.of(context)
                  .pushNamed(AdminManageUsersScreen.routeName);
            },
          ),
          _buildDashboardListItem(
            context: context,
            icon: Icons.bar_chart_outlined, // Icon biểu đồ
            title: l10n.manageApp, // Quản lý Ứng dụng
            onTap: () {
              Navigator.of(context).pushNamed(AdminManageAppScreen.routeName);
            },
          ),
          // ĐÃ XÓA "QUẢN LÝ BÌNH LUẬN"
        ],
      ),
    );
  }

  // SỬA: Widget helper mới cho dạng danh sách (List)
  Widget _buildDashboardListItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: Icon(
          icon,
          size: 40,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
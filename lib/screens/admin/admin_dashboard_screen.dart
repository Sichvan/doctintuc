import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';  // Import l10n
import '../home_screen.dart';
import 'admin_manage_users_screen.dart';
import 'admin_manage_articles_screen.dart';

class AdminDashboardScreen extends StatelessWidget {  // Đã extends StatelessWidget đúng
  static const routeName = '/admin-dashboard';

  const AdminDashboardScreen({super.key});  // Sửa constructor với super.key

  @override
  Widget build(BuildContext context) {  // build method đúng
    final themeProvider = Provider.of<ThemeProvider>(context);
    final l10n = AppLocalizations.of(context)!;  // Sử dụng l10n

    return Scaffold(  // Scaffold từ material.dart
      appBar: AppBar(
        title: Text(l10n.adminDashboard ?? 'Admin Dashboard'),  // Fallback nếu key chưa generate
        actions: [
          IconButton(
            icon: Icon(  // Icon từ material.dart
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,  // Icons từ material.dart
            ),
            onPressed: () {
              themeProvider.toggleTheme(!themeProvider.isDarkMode);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              // Sau logout, quay về Home
              Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);  // Import HomeScreen nếu cần
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardItem(
              context: context,
              icon: Icons.comment_bank_outlined,
              title: l10n.manageComments ?? 'Manage Comments',
              onTap: () {
                // TODO: Điều hướng đến trang quản lý bình luận
                // Navigator.of(context).pushNamed('/admin-comments');
              },
            ),
            _buildDashboardItem(
              context: context,
              icon: Icons.article_outlined,
              title: l10n.manageArticles ?? 'Manage Articles',
              onTap: () {
                Navigator.of(context).pushNamed(AdminManageArticlesScreen.routeName);
              },
            ),
            _buildDashboardItem(
              context: context,
              icon: Icons.people_outline,
              title: l10n.manageUsers ?? 'Manage Users',
              onTap: () {
                Navigator.of(context).pushNamed(AdminManageUsersScreen.routeName);
              },
            ),
            _buildDashboardItem(
              context: context,
              icon: Icons.settings_applications_outlined,
              title: l10n.manageApp ?? 'Manage App',
              onTap: () {
                // TODO: Điều hướng đến trang cài đặt chung
                // Navigator.of(context).pushNamed('/admin-settings');
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Widget con để xây dựng các ô chức năng cho dashboard
  Widget _buildDashboardItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
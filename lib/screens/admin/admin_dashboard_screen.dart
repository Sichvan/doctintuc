// screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
// SỬA 1: Import file Tiếng Việt
import '../../l10n/app_localizations_vi.dart';
import '../home_screen.dart';
import 'admin_manage_users_screen.dart';
import 'admin_manage_articles_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  static const routeName = '/admin-dashboard';

  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // SỬA 2: Khởi tạo AppLocalizationsVi() thay vì dùng context
    final l10n = AppLocalizationsVi(); // Khóa ngôn ngữ sang Tiếng Việt

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminDashboard), // Dùng l10n.adminDashboard
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
              title: l10n.manageComments, // Dùng l10n.manageComments
              onTap: () {
                // TODO: Điều hướng đến trang quản lý bình luận
              },
            ),
            _buildDashboardItem(
              context: context,
              icon: Icons.article_outlined,
              title: l10n.manageArticles, // Dùng l10n.manageArticles
              onTap: () {
                Navigator.of(context)
                    .pushNamed(AdminManageArticlesScreen.routeName);
              },
            ),
            _buildDashboardItem(
              context: context,
              icon: Icons.people_outline,
              title: l10n.manageUsers, // Dùng l10n.manageUsers
              onTap: () {
                Navigator.of(context)
                    .pushNamed(AdminManageUsersScreen.routeName);
              },
            ),
            _buildDashboardItem(
              context: context,
              icon: Icons.settings_applications_outlined,
              title: l10n.manageApp, // Dùng l10n.manageApp
              onTap: () {
                // TODO: Điều hướng đến trang cài đặt chung
              },
            ),
          ],
        ),
      ),
    );
  }

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
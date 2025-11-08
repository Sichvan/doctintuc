import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Providers
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
// Screens
import '../screens/login_register.dart';
import '../screens/home.dart';
import '../screens/saved.dart';
import '../screens/history.dart';
import '../screens/admin/admin.dart';  // Import thêm
import '../l10n/app_localizations.dart';  // Import l10n

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

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
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Center( // 👈 Thêm dòng này để căn giữa nội dung
              child: Text(
                l10n.settingsAndMenu,
                textAlign: TextAlign.center, // 👈 Giúp căn giữa cả trong trường hợp text dài
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold, // 👌 tùy chọn: cho tiêu đề nổi bật hơn
                ),
              ),
            ),
          ),

          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                title: Text(l10n.darkMode),
                secondary: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
                value: themeProvider.isDarkMode,
                onChanged: (bool value) {
                  context.read<ThemeProvider>().toggleTheme(value);
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.switchLanguage),
            onTap: () {
              context.read<LanguageProvider>().toggleLanguage();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_border),
            title: Text(l10n.savedArticles),
            onTap: () {
              if (auth.isAuth) {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(SavedArticlesScreen.routeName);
              } else {
                _showLoginRequiredDialog(context);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(l10n.viewHistory),
            onTap: () {
              if (auth.isAuth) {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(HistoryScreen.routeName);
              } else {
                _showLoginRequiredDialog(context);
              }
            },
          ),
          // Item Admin Dashboard (chỉ hiển thị nếu là admin)
          if (auth.isAuth && auth.role == 'admin') ...[
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: Text(l10n.adminDashboard ?? 'Admin Dashboard'),  // Fallback
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AdminDashboardScreen.routeName);
              },
            ),
          ],
          const Divider(),
          ListTile(
            leading: Icon(auth.isAuth ? Icons.logout : Icons.login),
            title: Text(auth.isAuth ? l10n.logout : l10n.login),
            onTap: () {
              Navigator.pop(context);
              if (auth.isAuth) {
                context.read<AuthProvider>().logout();
                Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
              } else {
                Navigator.of(context).pushNamed(AuthScreen.routeName);
              }
            },
          ),
          if (auth.isAuth && auth.email != null)
            ListTile(
              leading: Icon(
                Icons.account_circle,
                color: Theme.of(context).disabledColor,
              ),
              title: Text(
                auth.email!,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).disabledColor,
                ),
              ),
              enabled: false,
            ),
        ],
      ),
    );
  }
}
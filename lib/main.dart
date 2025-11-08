import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/news_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_data_provider.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/article_detail_admin_content_screen.dart';
import 'screens/saved_articles_screen.dart';
import 'screens/history_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_manage_users_screen.dart';
import 'screens/admin/admin_manage_articles_screen.dart';
import 'screens/admin/admin_edit_article_screen.dart';
// THÊM IMPORT CHO MÀN HÌNH MỚI
import 'screens/admin/admin_manage_app_screen.dart';
// THÊM IMPORT CHO MÀN HÌNH MỚI
import 'screens/admin/admin_user_detail_stats_screen.dart';
// L10n
import 'l10n/app_localizations.dart';
// Theme
import 'theme/dark_light.dart'; // Giả sử file này tồn tại

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // --- CÁC PROVIDER ĐỘC LẬP ---
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        // --- CÁC PROVIDER PHỤ THUỘC (PROXY) ---
        ChangeNotifierProxyProvider<LanguageProvider, NewsProvider>(
          create: (_) => NewsProvider(),
          update: (_, lang, news) => news!
            ..fetchNewsByCategory(
              'top',
              lang.currentLocale.languageCode,
            ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserDataProvider>(
          create: (_) => UserDataProvider(),
          update: (_, auth, userData) => userData!..update(auth.token),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProv, _) {
          return MaterialApp(
            title: 'News App',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProv.themeMode,
            locale: context.watch<LanguageProvider>().currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('vi', ''),
            ],
            home: Consumer<AuthProvider>(
              builder: (ctx, auth, _) {
                if (!auth.isAuth) {
                  return FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) {
                      if (authResultSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const SplashScreen();
                      }
                      if (auth.isAuth) {
                        ctx.read<UserDataProvider>().fetchInitialSavedArticles();
                      }
                      return auth.isAuth
                          ? const HomeScreen()
                          : const AuthScreen();
                    },
                  );
                }
                return const HomeScreen();
              },
            ),
            // Routes: Đảm bảo tất cả return Widget
            routes: {
              AuthScreen.routeName: (ctx) => const AuthScreen(),
              HomeScreen.routeName: (ctx) => const HomeScreen(),
              ArticleDetailAdminContentScreen.routeName: (ctx) =>
              const ArticleDetailAdminContentScreen(),
              SavedArticlesScreen.routeName: (ctx) =>
              const SavedArticlesScreen(),
              HistoryScreen.routeName: (ctx) => const HistoryScreen(),
              // Admin routes
              AdminDashboardScreen.routeName: (ctx) =>
              const AdminDashboardScreen(),
              AdminManageUsersScreen.routeName: (ctx) =>
              const AdminManageUsersScreen(),
              AdminManageArticlesScreen.routeName: (ctx) =>
              const AdminManageArticlesScreen(),
              AdminEditArticleScreen.routeName: (ctx) =>
              const AdminEditArticleScreen(),
              // THÊM ROUTE CHO MÀN HÌNH MỚI
              AdminManageAppScreen.routeName: (ctx) =>
              const AdminManageAppScreen(),
              // THÊM ROUTE CHO MÀN HÌNH MỚI
              AdminUserDetailStatsScreen.routeName: (ctx) =>
              const AdminUserDetailStatsScreen(),
            },
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/news_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_data_provider.dart';
import 'screens/home.dart';
import 'screens/login_register.dart';
import 'screens/splash.dart';
import 'screens/article_detail_admin.dart';
import 'screens/saved.dart';
import 'screens/history.dart';
import 'screens/admin/admin.dart';
import 'screens/admin/admin_manage_users.dart';
import 'screens/admin/admin_manage_articles.dart';
import 'screens/admin/admin_edit.dart';
// THÊM IMPORT CHO MÀN HÌNH MỚI
import 'screens/admin/admin_manage_app.dart';
// THÊM IMPORT CHO MÀN HÌNH MỚI
import 'screens/admin/admin_user_detail.dart';
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
            // === SỬA ĐỔI LOGIC TẠI ĐÂY ===
            home: Consumer<AuthProvider>(
              builder: (ctx, auth, _) {
                // Nếu đã đăng nhập, vào thẳng HomeScreen
                if (auth.isAuth) {
                  return const HomeScreen();
                }

                // Nếu chưa, vẫn chạy tryAutoLogin
                return FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) {
                    // 1. Trong khi chờ, hiển thị Splash Screen
                    if (authResultSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const SplashScreen();
                    }

                    // 2. Sau khi chờ, kiểm tra xem autoLogin có thành công không
                    if (auth.isAuth) {
                      // Nếu thành công, tải dữ liệu user
                      ctx.read<UserDataProvider>().fetchInitialSavedArticles();
                    }

                    // 3. SỬA ĐỔI: LUÔN LUÔN đi đến HomeScreen
                    //    (thay vì đi đến AuthScreen nếu auth.isAuth là false)
                    return const HomeScreen();
                  },
                );
              },
            ),
            // === KẾT THÚC SỬA ĐỔI ===

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
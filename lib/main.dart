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

// L10n
import 'l10n/app_localizations.dart';

// Theme
import 'theme/dark_light.dart'; // Import theme của bạn

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

        // --- TRẢ LẠI ADMIN_PROVIDER VỀ DẠNG ĐƠN GIẢN ---
        // Bằng cách này, nó sẽ không bị lỗi và các trang admin
        // của bạn vẫn hoạt động như cũ (vì chúng tự lấy token
        // từ AuthProvider và truyền vào hàm)
        ChangeNotifierProvider(create: (_) => AdminProvider()),

        // --- CÁC PROVIDER PHỤ THUỘC (PROXY) ---

        // 1. NewsProvider (phụ thuộc vào LanguageProvider)
        ChangeNotifierProxyProvider<LanguageProvider, NewsProvider>(
          create: (_) => NewsProvider(),
          update: (_, lang, news) => news!
            ..fetchNewsByCategory(
                'top', lang.currentLocale.languageCode),
        ),

        // 2. UserDataProvider (MỚI - phụ thuộc vào AuthProvider)
        // Provider này sẽ tự động nhận token
        ChangeNotifierProxyProvider<AuthProvider, UserDataProvider>(
          create: (_) => UserDataProvider(),
          update: (_, auth, userData) => userData!..update(auth.token),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProv, _) {
          return MaterialApp(
            title: 'News App',

            // Theme
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProv.themeMode,

            // L10n
            locale: context.watch<LanguageProvider>().currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('vi', ''), // Vietnamese
            ],

            // Logic Home/Auth
            home: Consumer<AuthProvider>(
              builder: (ctx, auth, _) => auth.isAuth
                  ? const HomeScreen()
                  : FutureBuilder(
                future: auth.tryAutoLogin(),
                builder: (ctx, authResultSnapshot) {
                  if (authResultSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const SplashScreen();
                  }
                  if (auth.isAuth) {
                    ctx
                        .read<UserDataProvider>()
                        .fetchInitialSavedArticles();
                  }
                  return auth.isAuth
                      ? const HomeScreen()
                      : const AuthScreen();
                },
              ),
            ),

            // Routes
            routes: {
              AuthScreen.routeName: (ctx) => const AuthScreen(),
              HomeScreen.routeName: (ctx) => const HomeScreen(),
              ArticleDetailAdminContentScreen.routeName: (ctx) =>
              const ArticleDetailAdminContentScreen(),
              SavedArticlesScreen.routeName: (ctx) =>
              const SavedArticlesScreen(),
              HistoryScreen.routeName: (ctx) => const HistoryScreen(),

              // TÔI GIẢ SỬ BẠN CÓ MỘT ROUTE ADMIN NHƯ THẾ NÀY:
              // 'admin-home': (ctx) => AdminHomeScreen(),
              // 'admin-users': (ctx) => AdminUsersScreen(),
              // ... (Hãy đảm bảo route admin của bạn vẫn được đăng ký)
            },
          );
        },
      ),
    );
  }
}
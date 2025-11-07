// lib/screens/home_screen.dart
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/news_provider.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_drawer.dart';
import '../screens/auth_screen.dart';
import '../models/display_article.dart';
import '../l10n/app_localizations.dart';
import '../widgets/article_list_item.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, String> _categories = {};
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    final newCategories = {
      l10n.categoryTop: 'top',
      l10n.categoryPolitics: 'politics',
      l10n.categoryWorld: 'world',
      l10n.categoryBusiness: 'business',
      l10n.categoryScience: 'science',
      l10n.categoryEntertainment: 'entertainment',
      l10n.categorySports: 'sports',
      l10n.categoryCrime: 'crime',
      l10n.categoryEducation: 'education',
      l10n.categoryHealth: 'health',
      l10n.categoryOther: 'other',
      l10n.categoryTechnology: 'technology',
    };

    if (newCategories.length != _categories.length) {
      _categories = newCategories;
      _tabController.dispose();
      _tabController = TabController(length: _categories.length, vsync: this);
      _tabController.addListener(_handleTabSelection);
      _fetchInitialNews();
    } else {
      _categories = newCategories;
    }
  }

  void _fetchInitialNews() {
    if (_categories.isNotEmpty) {
      final initialCategory = _categories.values.first;
      final langCode =
          context.read<LanguageProvider>().currentLocale.languageCode;
      Provider.of<NewsProvider>(context, listen: false)
          .fetchNewsByCategory(initialCategory, langCode);
    }
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      _searchController.clear();
      final categoryKey = _categories.values.elementAt(_tabController.index);
      final langCode =
          context.read<LanguageProvider>().currentLocale.languageCode;
      Provider.of<NewsProvider>(context, listen: false)
          .fetchNewsByCategory(categoryKey, langCode);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

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
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: NavigationToolbar.kMiddleSpacing,
        title: Text(
          l10n.appName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchByTitle,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).dividerColor.withAlpha(50),
              ),
              onChanged: (value) {
                newsProvider.updateSearchQuery(value);
              },
            ),
          ),
          Container(
            color: Theme.of(context).primaryColor,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: _categories.keys.map((String key) {
                return Tab(text: key);
              }).toList(),
            ),
          ),
          Expanded(
            child: Consumer<NewsProvider>(
              builder: (context, newsProvider, child) {
                final List<DisplayArticle> newsList =
                    newsProvider.filteredNewsList;

                if (newsProvider.isLoading && newsList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (newsProvider.errorMessage != null && newsList.isEmpty) {
                  return Center(
                      child: Text(
                          l10n.errorFetchingData(newsProvider.errorMessage!)));
                }

                if (newsList.isEmpty) {
                  return Center(child: Text(l10n.noArticlesFound));
                }

                return ListView.builder(
                  itemCount: newsList.length,
                  itemBuilder: (context, index) {
                    final article = newsList[index];
                    return ArticleListItem(article: article);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
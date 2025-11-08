// lib/providers/news_provider.dart
import 'package:flutter/material.dart';
import '../models/news.dart';
import '../models/display_article.dart';
import '../models/admin_article.dart';
import '../services/api_service.dart';

class NewsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<DisplayArticle> _newsList = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = "";

  List<DisplayArticle> get filteredNewsList {
    if (_searchQuery.isEmpty) {
      return _newsList;
    } else {
      return _newsList
          .where((news) =>
          news.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchNewsByCategory(String category, String language) async {
    _isLoading = true;
    _errorMessage = null;
    _searchQuery = "";
    notifyListeners();

    try {
      List<DisplayArticle> combinedList = [];
      final apiNewsFuture = _apiService.fetchNews(category, language);
      final adminNewsFuture = _apiService.fetchPublicAdminArticles(category, language);

      final results = await Future.wait([apiNewsFuture, adminNewsFuture]);

      final List<News> apiNews = results[0] as List<News>;
      // SỬA: Truyền "category" vào
      combinedList.addAll(apiNews.map((news) => DisplayArticle.fromNews(news, category)));

      final List<dynamic> adminNewsData = results[1] as List<dynamic>;
      final List<AdminArticle> adminNews = adminNewsData.map((data) => AdminArticle.fromJson(data)).toList();
      combinedList.addAll(adminNews.map((article) => DisplayArticle.fromAdminArticle(article)));

      combinedList.sort((a, b) => b.pubDate.compareTo(a.pubDate));

      _newsList = combinedList;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
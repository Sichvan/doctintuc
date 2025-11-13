import 'package:flutter/material.dart';
import '../models/news.dart';
import '../models/display_article.dart';
import '../models/admin_article.dart';
import '../services/api.dart';

class NewsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<DisplayArticle> _newsList = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = "";

  // Getter cho danh sách tin tức đã được lọc (Logic tìm kiếm)
  List<DisplayArticle> get filteredNewsList {
    if (_searchQuery.isEmpty) {
      return _newsList;
    } else {
      // Lọc không phân biệt chữ hoa, chữ thường dựa trên title
      return _newsList
          .where((news) =>
          news.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Cập nhật truy vấn tìm kiếm và thông báo cho Consumer
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Fetch tin tức theo danh mục
  Future<void> fetchNewsByCategory(
      String category,
      String language, {
        bool resetSearch = true,
      }) async {
    _isLoading = true;
    _errorMessage = null;

    // Chỉ reset tìm kiếm khi thật sự cần (ví dụ khi đổi tab)
    if (resetSearch) {
      _searchQuery = "";
    }

    notifyListeners();

    try {
      List<DisplayArticle> combinedList = [];

      final apiNewsFuture = _apiService.fetchNews(category, language);
      final adminNewsFuture =
      _apiService.fetchPublicAdminArticles(category, language);

      final results = await Future.wait([apiNewsFuture, adminNewsFuture]);

      final List<News> apiNews = results[0] as List<News>;
      combinedList.addAll(
          apiNews.map((news) => DisplayArticle.fromNews(news, category)));

      final List<dynamic> adminNewsData = results[1] as List<dynamic>;
      final List<AdminArticle> adminNews = adminNewsData
          .map((data) => AdminArticle.fromJson(data))
          .toList();
      combinedList.addAll(
          adminNews.map((article) => DisplayArticle.fromAdminArticle(article)));

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

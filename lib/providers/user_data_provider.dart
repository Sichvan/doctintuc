// providers/user_data_provider.dart
import 'package:flutter/material.dart';
import '../services/api.dart';
import '../models/display_article.dart';

class UserDataProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  String? _token;

  // Dùng Set để kiểm tra isSaved(id) cực nhanh (O(1))
  Set<String> _savedArticleIds = {};
  List<DisplayArticle> _savedArticlesList = [];
  List<DisplayArticle> _historyList = [];

  bool _isLoadingSaved = false;
  bool _isLoadingHistory = false;

  // Getters
  bool get isLoadingSaved => _isLoadingSaved;
  bool get isLoadingHistory => _isLoadingHistory;
  List<DisplayArticle> get savedArticles => _savedArticlesList;
  List<DisplayArticle> get history => _historyList;

  // Kiểm tra 1 bài viết đã lưu hay chưa
  bool isSaved(String articleId) {
    return _savedArticleIds.contains(articleId);
  }

  // Nhận token từ AuthProvider
  void update(String? token) {
    _token = token;
    if (_token != null) {
      // Khi có token (đăng nhập), tải dữ liệu ban đầu
      fetchInitialSavedArticles();
    } else {
      // Khi không có token (đăng xuất), xóa dữ liệu
      _savedArticleIds = {};
      _savedArticlesList = [];
      _historyList = [];
      notifyListeners();
    }
  }

  // Tải danh sách bài viết đã lưu
  Future<void> fetchInitialSavedArticles() async {
    if (_token == null) return;
    _isLoadingSaved = true;
    notifyListeners();
    try {
      final List<dynamic> data = await _apiService.getSavedArticles(_token!);
      _savedArticlesList = data.map((item) => DisplayArticle.fromSavedJson(item)).toList();
      // Cập nhật Set để check nhanh
      _savedArticleIds = _savedArticlesList.map((a) => a.id).toSet();
    } catch (e) {
      print(e); // TODO: Xử lý lỗi
    } finally {
      _isLoadingSaved = false;
      notifyListeners();
    }
  }

  // Tải danh sách lịch sử (chỉ khi người dùng vào trang Lịch sử)
  Future<void> fetchHistory() async {
    if (_token == null) return;
    _isLoadingHistory = true;
    notifyListeners();
    try {
      final List<dynamic> data = await _apiService.getHistory(_token!);
      _historyList = data.map((item) => DisplayArticle.fromSavedJson(item)).toList();
    } catch (e) {
      print(e); // TODO: Xử lý lỗi
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  // Hàm chính để Lưu/Bỏ lưu
  Future<void> toggleSaveArticle(DisplayArticle article) async {
    if (_token == null) return;

    final articleId = article.id;
    final bool currentlySaved = isSaved(articleId);

    // Cập nhật UI ngay lập tức để có cảm giác mượt
    if (currentlySaved) {
      _savedArticleIds.remove(articleId);
      _savedArticlesList.removeWhere((a) => a.id == articleId);
    } else {
      _savedArticleIds.add(articleId);
      _savedArticlesList.insert(0, article); // Thêm vào đầu ds
    }
    notifyListeners();

    // Gọi API
    try {
      if (currentlySaved) {
        // Bỏ lưu
        await _apiService.unsaveArticle(_token!, articleId);
      } else {
        // Lưu
        await _apiService.saveArticle(_token!, article.toSaveJson());
      }
    } catch (e) {
      // Nếu API lỗi, hoàn tác lại UI
      if (currentlySaved) {
        _savedArticleIds.add(articleId);
        _savedArticlesList.insert(0, article);
      } else {
        _savedArticleIds.remove(articleId);
        _savedArticlesList.removeWhere((a) => a.id == articleId);
      }
      notifyListeners();
      // TODO: Hiển thị lỗi cho người dùng
      print(e);
    }
  }

  // Thêm vào lịch sử
  Future<void> addToHistory(DisplayArticle article) async {
    if (_token == null) return;
    try {
      // Chỉ gọi API, không cần cập nhật state
      // vì state lịch sử chỉ tải khi vào trang
      await _apiService.addHistory(_token!, article.toSaveJson());
    } catch (e) {
      print(e);
    }
  }
}
// SỬA: Xóa import 'dart:convert' không dùng
import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/admin_article.dart';
import '../services/api.dart';

class AdminProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State cho Quản lý User
  List<AppUser> _users = [];
  bool _isLoadingUsers = false;
  String? _errorUsers;
  List<AppUser> get users => _users;
  bool get isLoadingUsers => _isLoadingUsers;
  String? get errorUsers => _errorUsers;

  // State cho Thống kê User
  Map<String, dynamic>? _userStats;
  Map<String, dynamic>? get userStats => _userStats;

  // State cho Quản lý Bài viết
  List<AdminArticle> _articles = [];
  bool _isLoadingArticles = false;
  String? _errorArticles;
  List<AdminArticle> get articles => _articles;
  bool get isLoadingArticles => _isLoadingArticles;
  String? get errorArticles => _errorArticles;

  // State cho Thống kê Thể loại
  Map<String, dynamic>? _categoryStats;
  Map<String, dynamic>? get categoryStats => _categoryStats;
  bool _isLoadingCategoryStats = false;
  bool get isLoadingCategoryStats => _isLoadingCategoryStats;

  // --- STATE MỚI CHO THỐNG KÊ USER CỤ THỂ ---
  Map<String, dynamic>? _userCategoryStats;
  Map<String, dynamic>? get userCategoryStats => _userCategoryStats;
  bool _isLoadingUserCategoryStats = false;
  bool get isLoadingUserCategoryStats => _isLoadingUserCategoryStats;
  String? _errorUserCategoryStats;
  String? get errorUserCategoryStats => _errorUserCategoryStats;
  // ------------------------------------------


  // --- HÀM QUẢN LÝ USER ---
  Future<void> fetchUserStats(String token) async {
    try {
      _userStats = await _apiService.adminFetchUserStats(token);
    } catch (e) {
      // SỬA: Dùng debugPrint
      debugPrint('Lỗi khi tải thống kê User: $e');
      _userStats = null;
    }
    notifyListeners();
  }

  Future<void> fetchUsers(String token) async {
    _isLoadingUsers = true;
    _errorUsers = null;
    notifyListeners();
    try {
      final List<dynamic> usersData = await _apiService.adminFetchUsers(token);
      _users = usersData.map((data) => AppUser.fromJson(data)).toList();
    } catch (e) {
      _errorUsers = e.toString();
    } finally {
      _isLoadingUsers = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(String userId, String token) async {
    try {
      await _apiService.adminDeleteUser(userId, token);
      _users.removeWhere((user) => user.id == userId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // --- HÀM QUẢN LÝ BÀI VIẾT ---
  Future<void> fetchArticles(String token) async {
    _isLoadingArticles = true;
    _errorArticles = null;
    notifyListeners();
    try {
      final List<dynamic> articlesData =
      await _apiService.adminFetchArticles(token);
      _articles =
          articlesData.map((data) => AdminArticle.fromJson(data)).toList();
    } catch (e) {
      _errorArticles = e.toString();
    } finally {
      _isLoadingArticles = false;
      notifyListeners();
    }
  }

  Future<void> addArticle(
      Map<String, dynamic> articleData, String token) async {
    final newArticleMap = await _apiService.adminAddArticle(articleData, token);
    final newArticle = AdminArticle.fromJson(newArticleMap);
    _articles.insert(0, newArticle);
    notifyListeners();
  }

  Future<void> updateArticle(String articleId,
      Map<String, dynamic> articleData, String token) async {
    final updatedArticleMap =
    await _apiService.adminUpdateArticle(articleId, articleData, token);
    final updatedArticle = AdminArticle.fromJson(updatedArticleMap);
    final index = _articles.indexWhere((a) => a.id == updatedArticle.id);
    if (index != -1) {
      _articles[index] = updatedArticle;
      notifyListeners();
    }
  }

  Future<void> deleteArticle(String articleId, String token) async {
    await _apiService.adminDeleteArticle(articleId, token);
    _articles.removeWhere((article) => article.id == articleId);
    notifyListeners();
  }

  // --- HÀM QUẢN LÝ THỐNG KÊ THỂ LOẠI ---
  Future<void> fetchCategoryStats(String token) async {
    _isLoadingCategoryStats = true;
    notifyListeners();
    try {
      // Đây là hàm đã báo lỗi
      _categoryStats = await _apiService.adminFetchCategoryStats(token);
    } catch (e) {
      // SỬA: Dùng debugPrint
      debugPrint('Lỗi khi tải thống kê thể loại: $e');
      _categoryStats = null;
    } finally {
      _isLoadingCategoryStats = false;
      notifyListeners();
    }
  }

  // --- HÀM MỚI: LẤY THỐNG KÊ CỦA 1 USER ---
  Future<void> fetchUserCategoryStats(String userId, String token) async {
    _isLoadingUserCategoryStats = true;
    _errorUserCategoryStats = null;
    _userCategoryStats = null; // Xóa dữ liệu cũ
    notifyListeners();
    try {
      _userCategoryStats =
      await _apiService.adminFetchUserCategoryStats(userId, token);
    } catch (e) {
      debugPrint('Lỗi khi tải thống kê của user $userId: $e');
      _errorUserCategoryStats = e.toString();
      _userCategoryStats = null;
    } finally {
      _isLoadingUserCategoryStats = false;
      notifyListeners();
    }
  }
}
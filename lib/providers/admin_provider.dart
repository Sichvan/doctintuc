// providers/admin_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/admin_article.dart';
import '../services/api_service.dart';

class AdminProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State cho Quản lý User
  List<AppUser> _users = [];
  bool _isLoadingUsers = false;
  String? _errorUsers;
  List<AppUser> get users => _users;
  bool get isLoadingUsers => _isLoadingUsers;
  String? get errorUsers => _errorUsers;

  // === THÊM MỚI: State cho Thống kê User ===
  Map<String, dynamic>? _userStats;
  Map<String, dynamic>? get userStats => _userStats;
  // =====================================

  // State cho Quản lý Bài viết
  List<AdminArticle> _articles = [];
  bool _isLoadingArticles = false;
  String? _errorArticles;
  List<AdminArticle> get articles => _articles;
  bool get isLoadingArticles => _isLoadingArticles;
  String? get errorArticles => _errorArticles;

  // === HÀM MỚI: Lấy Thống kê User ===
  Future<void> fetchUserStats(String token) async {
    try {
      _userStats = await _apiService.adminFetchUserStats(token);
    } catch (e) {
      // Không làm crash app nếu chỉ thống kê lỗi
      print('Lỗi khi tải thống kê: $e');
      _userStats = null;
    }
    notifyListeners();
  }
  // ==================================

  // --- HÀM QUẢN LÝ USER ---
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
}
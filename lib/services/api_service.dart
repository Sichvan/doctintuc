import 'package:http/http.dart' as http;
import '../models/news.dart'; // Giữ lại import này cho hàm fetchNews
import 'dart:convert'; // Import này cần thiết cho json.decode/encode

class ApiService {
  //  static const String _baseUrl = 'http://10.0.2.2:5000/api';
//  static const String _baseUrl = 'http://10.200.151.26:5000/api';
  static const String _baseUrl = 'http://192.168.1.25:5000/api';


  // --- Hàm gốc cho User ---
  Future<List<News>> fetchNews(String category, String language) async {
    final url = '$_baseUrl/news?category=$category&language=$language';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return newsFromJson(response.body);
    } else {
      // print('API Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load news');
    }
  }

  // Lấy bài viết của Admin (công khai) đã lọc
  Future<List<dynamic>> fetchPublicAdminArticles(
      String category, String language) async {
    final url =
        '$_baseUrl/articles/public?category=$category&language=$language';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    return _handleResponse(response) as List<dynamic>;
  }

  // --- HÀM CHO ADMIN (BẢO MẬT) ---

  // Helper private để xử lý response, trả về dynamic
  dynamic _handleResponse(http.Response response) {
    final responseData = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseData;
    } else {
      throw (responseData['msg'] ??
          responseData['errors']?[0]['msg'] ??
          'Đã xảy ra lỗi');
    }
  }

  // --- Quản lý User ---
  Future<List<dynamic>> adminFetchUsers(String token) async {
    final url = '$_baseUrl/admin/users';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );
    return _handleResponse(response) as List<dynamic>;
  }

  Future<dynamic> adminDeleteUser(String userId, String token) async {
    final url = '$_baseUrl/admin/users/$userId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );
    return _handleResponse(response);
  }

  // --- Quản lý Bài viết ---
  Future<List<dynamic>> adminFetchArticles(String token) async {
    final url = '$_baseUrl/articles';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );
    return _handleResponse(response) as List<dynamic>;
  }

  Future<dynamic> adminAddArticle(
      Map<String, dynamic> articleData, String token) async {
    final url = '$_baseUrl/articles';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
      body: json.encode(articleData),
    );
    return _handleResponse(response);
  }

  Future<dynamic> adminUpdateArticle(
      String articleId, Map<String, dynamic> articleData, String token) async {
    final url = '$_baseUrl/articles/$articleId';
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
      body: json.encode(articleData),
    );
    return _handleResponse(response);
  }

  Future<dynamic> adminDeleteArticle(String articleId, String token) async {
    final url = '$_baseUrl/articles/$articleId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );
    return _handleResponse(response);
  }

  // --- User Data (Lưu, Lịch sử) ---
  Future<List<dynamic>> getSavedArticles(String token) async {
    final url = '$_baseUrl/user/saved';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );
    return _handleResponse(response) as List<dynamic>;
  }

  Future<List<dynamic>> getHistory(String token) async {
    final url = '$_baseUrl/user/history';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );
    return _handleResponse(response) as List<dynamic>;
  }

  Future<dynamic> saveArticle(
      String token, Map<String, dynamic> articleData) async {
    final url = '$_baseUrl/user/save';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
      body: json.encode(articleData),
    );
    return _handleResponse(response);
  }

  Future<dynamic> unsaveArticle(String token, String articleId) async {
    final url = '$_baseUrl/user/unsave';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
      body: json.encode({'articleId': articleId}),
    );
    return _handleResponse(response);
  }

  Future<dynamic> addHistory(
      String token, Map<String, dynamic> articleData) async {
    final url = '$_baseUrl/user/history';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
      body: json.encode(articleData),
    );
    return _handleResponse(response);
  }

  // --- Admin Thống kê ---
  Future<Map<String, dynamic>> adminFetchUserStats(String token) async {
    final url = '$_baseUrl/admin/user-stats';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );
    return _handleResponse(response) as Map<String, dynamic>;
  }

  // === HÀM BỊ THIẾU MÀ BẠN CẦN THÊM ===
  Future<Map<String, dynamic>> adminFetchCategoryStats(String token) async {
    final url = '$_baseUrl/admin/category-stats'; // URL của API mới
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );
    return _handleResponse(response) as Map<String, dynamic>;
  }

  // === HÀM MỚI CHO THỐNG KÊ 1 USER ===
  Future<Map<String, dynamic>> adminFetchUserCategoryStats(
      String userId, String token) async {
    final url = '$_baseUrl/admin/user-category-stats/$userId'; // URL của API mới
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );
    return _handleResponse(response) as Map<String, dynamic>;
  }
}
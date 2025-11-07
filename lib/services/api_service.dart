import 'package:http/http.dart' as http;
import '../models/news.dart'; // Giữ lại import này cho hàm fetchNews
import 'dart:convert'; // Thêm import này

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:5000/api';

  // --- Hàm gốc cho User ---
  Future<List<News>> fetchNews(String category, String language) async {
    final url = '$_baseUrl/news?category=$category&language=$language';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return newsFromJson(response.body);
    } else {
      print('API Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load news');
    }
  }

  // --- THÊM HÀM MỚI (CÔNG KHAI) ---
  // Lấy bài viết của Admin (công khai) đã lọc
  Future<List<dynamic>> fetchPublicAdminArticles(
      String category, String language) async {
    // Gửi category và language làm query params
    final url =
        '$_baseUrl/articles/public?category=$category&language=$language';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    // Sử dụng _handleResponse đã có
    return _handleResponse(response) as List<dynamic>;
  }


  // --- HÀM CHO ADMIN (BẢO MẬT) ---

  // Helper private để xử lý response, trả về dynamic
  dynamic _handleResponse(http.Response response) {
    final responseData = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseData;
    } else {
      // Ném lỗi với message từ server (bao gồm cả lỗi validation)
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
    // Ép kiểu sang List<dynamic>
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
    // URL này lấy TẤT CẢ bài viết để admin quản lý
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

  // Lấy danh sách lịch sử
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

  // Lưu 1 bài viết
  Future<dynamic> saveArticle(String token, Map<String, dynamic> articleData) async {
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

  // Bỏ lưu 1 bài viết
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

  // Thêm vào lịch sử
  Future<dynamic> addHistory(String token, Map<String, dynamic> articleData) async {
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

}


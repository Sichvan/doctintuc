import '../models/news.dart';
import '../models/admin_article.dart';

class DisplayArticle {
  final String id;
  final String title;
  final String? imageUrl;
  final String sourceName;
  final DateTime pubDate;
  final bool isFromAdmin;
  final String articleUrl;
  final String? adminContent;

  DisplayArticle({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.sourceName,
    required this.pubDate,
    required this.isFromAdmin,
    required this.articleUrl,
    this.adminContent,
  });

  DisplayArticle.fromNews(News news)
      : id = news.link,
        title = news.title,
        imageUrl = news.imageUrl,
        sourceName = news.sourceName,
        pubDate = news.pubDate ?? DateTime.now(),
        isFromAdmin = false,
        articleUrl = news.link,
        adminContent = null;

  DisplayArticle.fromAdminArticle(AdminArticle article)
      : id = article.id,
        title = article.title,
        imageUrl = article.imageUrl,
        sourceName = article.sourceName,
        pubDate = article.createdAt,
        isFromAdmin = true,
        articleUrl = '',
        adminContent = article.content;

  factory DisplayArticle.fromSavedJson(Map<String, dynamic> json) {
    return DisplayArticle(
      id: json["articleId"], // Lưu ý: id lấy từ articleId
      title: json["title"],
      imageUrl: json["imageUrl"],
      sourceName: json["sourceName"],
      // pubDate có thể null từ API, nên parse cẩn thận
      pubDate: json["pubDate"] == null ? DateTime.now() : DateTime.parse(json["pubDate"]),
      isFromAdmin: json["isFromAdmin"],
      articleUrl: json["articleUrl"] ?? '',
      adminContent: json["adminContent"],
    );
  }

  // THÊM hàm MỚI:
  // Dùng để gửi dữ liệu lên API khi lưu hoặc thêm lịch sử
  Map<String, dynamic> toSaveJson() => {
    "articleId": id,
    "title": title,
    "imageUrl": imageUrl,
    "sourceName": sourceName,
    "pubDate": pubDate.toIso8601String(),
    "isFromAdmin": isFromAdmin,
    "articleUrl": articleUrl,
    "adminContent": adminContent,
  };
}


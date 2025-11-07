import 'dart:convert';

List<AdminArticle> adminArticleFromJson(String str) =>
    List<AdminArticle>.from(
        json.decode(str).map((x) => AdminArticle.fromJson(x)));

class AdminArticle {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final String language;
  final String category;
  final String sourceName;
  final String authorEmail;
  final DateTime createdAt;

  AdminArticle({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.language,
    required this.category,
    required this.sourceName,
    required this.authorEmail,
    required this.createdAt,
  });

  factory AdminArticle.fromJson(Map<String, dynamic> json) {
    String email = 'Không rõ';
    if (json["author"] != null) {
      if (json["author"] is Map<String, dynamic>) {
        email = json["author"]["email"] ?? 'Không rõ';
      } else if (json["author"] is String) {
        email = 'Admin (ID: ${json["author"]})';
      }
    }

    return AdminArticle(
      id: json["_id"],
      title: json["title"],
      content: json["content"],
      imageUrl: json["imageUrl"],
      language: json["language"],
      category: json["category"],
      sourceName: json["sourceName"] ?? 'Tin tức Admin',
      authorEmail: email,
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }

  Map<String, dynamic> toSendJson() => {
    "title": title,
    "content": content,
    "imageUrl": imageUrl,
    "language": language,
    "category": category,
  };
}


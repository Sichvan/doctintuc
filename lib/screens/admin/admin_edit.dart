import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/admin_article.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/categories.dart';

class AdminEditArticleScreen extends StatefulWidget {
  static const routeName = '/admin-edit-article';
  const AdminEditArticleScreen({super.key});

  @override
  State<AdminEditArticleScreen> createState() => _AdminEditArticleScreenState();
}

class _AdminEditArticleScreenState extends State<AdminEditArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  AdminArticle? _existingArticle;
  bool _isLoading = false;
  bool _didInit = false; // Cờ để tránh didChangeDependencies chạy lại

  // Controllers
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();

  // Giá trị cho Dropdowns
  String? _selectedLanguage;
  String? _selectedCategory;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Chỉ chạy 1 lần
    if (!_didInit) {
      // Lấy bài viết (nếu là chỉnh sửa)
      // --- SỬA LỖI ---
      // Nhận AdminArticle (Object) thay vì String
      final article =
      ModalRoute.of(context)!.settings.arguments as AdminArticle?;
      // --- KẾT THÚC SỬA ---

      if (article != null) {
        _isEditing = true;
        _existingArticle = article;
        _titleController.text = article.title;
        _contentController.text = article.content;
        _imageUrlController.text = article.imageUrl ?? '';
        _selectedLanguage = article.language;
        _selectedCategory = article.category;
      } else {
        // Giá trị mặc định khi tạo mới
        _selectedLanguage = AppCategories.languages.keys.first;
        _selectedCategory = AppCategories.categories.keys.first;
      }
      _didInit = true; // Đánh dấu đã init
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // Hàm Submit Form
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return; // Dừng nếu form không hợp lệ
    }
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    // Tạo Map dữ liệu
    final Map<String, dynamic> articleData = {
      'title': _titleController.text,
      'content': _contentController.text,
      'imageUrl': _imageUrlController.text,
      'language': _selectedLanguage,
      'category': _selectedCategory,
    };

    try {
      if (_isEditing) {
        // Cập nhật
        await adminProvider.updateArticle(
            _existingArticle!.id, articleData, token!);
      } else {
        // Thêm mới
        await adminProvider.addArticle(articleData, token!);
      }

      if (mounted) {
        Navigator.of(context).pop(); // Quay về trang danh sách
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lưu thất bại: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa Bài viết' : 'Thêm Bài viết'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _submitForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Tiêu đề
                TextFormField(
                  controller: _titleController,
                  decoration:
                  const InputDecoration(labelText: 'Tiêu đề'),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Tiêu đề không được trống'
                      : null,
                ),
                const SizedBox(height: 16),

                // Ngôn ngữ (Dropdown)
                DropdownButtonFormField<String>(
                  value: _selectedLanguage,
                  decoration:
                  const InputDecoration(labelText: 'Ngôn ngữ'),
                  items: AppCategories.languages.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key, // 'vi'
                      child: Text(entry.value), // 'Tiếng Việt'
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedLanguage = value);
                  },
                  validator: (value) =>
                  value == null ? 'Vui lòng chọn ngôn ngữ' : null,
                ),
                const SizedBox(height: 16),

                // Thể loại (Dropdown)
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration:
                  const InputDecoration(labelText: 'Thể loại'),
                  // Cho phép dropdown cuộn
                  isExpanded: true,
                  items: AppCategories.categories.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key, // 'top'
                      child: Text(entry.value), // 'Tin nóng'
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value);
                  },
                  validator: (value) =>
                  value == null ? 'Vui lòng chọn thể loại' : null,
                ),
                const SizedBox(height: 16),

                // Link ảnh
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                      labelText: 'Link Hình ảnh (URL)'),
                ),
                const SizedBox(height: 16),

                // Nội dung
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Nội dung',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 10,
                  keyboardType: TextInputType.multiline,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Nội dung không được trống'
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


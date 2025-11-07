// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Báo lá cải';

  @override
  String get settingsAndMenu => 'Cài đặt & Menu';

  @override
  String get darkMode => 'Chế độ tối';

  @override
  String get switchLanguage => 'Chuyển ngôn ngữ';

  @override
  String get savedArticles => 'Bài báo đã lưu';

  @override
  String get viewHistory => 'Lịch sử xem';

  @override
  String get login => 'Đăng nhập';

  @override
  String errorFetchingData(String message) {
    return 'Lỗi khi tải dữ liệu: $message';
  }

  @override
  String get categoryTop => 'Tin nóng';

  @override
  String get categoryPolitics => 'Xã hội';

  @override
  String get categoryWorld => 'Thế giới';

  @override
  String get categoryBusiness => 'Kinh tế';

  @override
  String get categoryScience => 'Khoa học';

  @override
  String get categoryEntertainment => 'Văn hóa';

  @override
  String get categorySports => 'Thể thao';

  @override
  String get categoryEntertainment2 => 'Giải trí';

  @override
  String get categoryCrime => 'Pháp luật';

  @override
  String get categoryEducation => 'Giáo dục';

  @override
  String get categoryHealth => 'Sức khỏe';

  @override
  String get categoryOther => 'Nhà đất';

  @override
  String get categoryTechnology => 'Xe cộ';

  @override
  String get searchByTitle => 'Tìm kiếm theo tiêu đề...';

  @override
  String get noArticlesFound => 'Không tìm thấy bài viết nào.';

  @override
  String get loginRequiredTitle => 'Yêu cầu đăng nhập';

  @override
  String get loginRequiredMessage =>
      'Bạn phải đăng nhập để sử dụng chức năng này.';

  @override
  String get cancel => 'Hủy';

  @override
  String get register => 'Đăng ký';

  @override
  String get loginSuccess => 'Đăng nhập thành công!';

  @override
  String get registrationSuccessTitle => 'Đăng ký thành công';

  @override
  String get registrationSuccessMessage => 'Tài khoản của bạn đã được tạo';

  @override
  String get errorTitle => 'Lỗi';

  @override
  String get ok => 'OK';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get emailInvalid => 'Email không hợp lệ.';

  @override
  String get passwordInvalid => 'Mật khẩu phải có ít nhất 6 ký tự.';

  @override
  String get switchToRegister => 'Chưa có tài khoản? Đăng ký ngay';

  @override
  String get switchToLogin => 'Đã có tài khoản? Đăng nhập';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get emailMustBeGmail => 'Email phải có đuôi @gmail.com.';

  @override
  String get home => 'Trang chủ';

  @override
  String get adminDashboard => 'Bảng Điều Khiển Admin';

  @override
  String get manageArticles => 'Quản lý Bài viết';

  @override
  String get manageUsers => 'Quản lý Tài khoản';

  @override
  String get manageComments => 'Quản lý Bình luận';

  @override
  String get manageApp => 'Quản lý Ứng dụng';

  @override
  String get noAdminAccess => 'Bạn không có quyền truy cập admin.';
}

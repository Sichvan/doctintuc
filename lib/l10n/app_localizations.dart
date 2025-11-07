import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In vi, this message translates to:
  /// **'Báo lá cải'**
  String get appName;

  /// No description provided for @settingsAndMenu.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt & Menu'**
  String get settingsAndMenu;

  /// No description provided for @darkMode.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ tối'**
  String get darkMode;

  /// No description provided for @switchLanguage.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển ngôn ngữ'**
  String get switchLanguage;

  /// No description provided for @savedArticles.
  ///
  /// In vi, this message translates to:
  /// **'Bài báo đã lưu'**
  String get savedArticles;

  /// No description provided for @viewHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử xem'**
  String get viewHistory;

  /// No description provided for @login.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get login;

  /// No description provided for @errorFetchingData.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi khi tải dữ liệu: {message}'**
  String errorFetchingData(String message);

  /// No description provided for @categoryTop.
  ///
  /// In vi, this message translates to:
  /// **'Tin nóng'**
  String get categoryTop;

  /// No description provided for @categoryPolitics.
  ///
  /// In vi, this message translates to:
  /// **'Xã hội'**
  String get categoryPolitics;

  /// No description provided for @categoryWorld.
  ///
  /// In vi, this message translates to:
  /// **'Thế giới'**
  String get categoryWorld;

  /// No description provided for @categoryBusiness.
  ///
  /// In vi, this message translates to:
  /// **'Kinh tế'**
  String get categoryBusiness;

  /// No description provided for @categoryScience.
  ///
  /// In vi, this message translates to:
  /// **'Khoa học'**
  String get categoryScience;

  /// No description provided for @categoryEntertainment.
  ///
  /// In vi, this message translates to:
  /// **'Văn hóa'**
  String get categoryEntertainment;

  /// No description provided for @categorySports.
  ///
  /// In vi, this message translates to:
  /// **'Thể thao'**
  String get categorySports;

  /// No description provided for @categoryEntertainment2.
  ///
  /// In vi, this message translates to:
  /// **'Giải trí'**
  String get categoryEntertainment2;

  /// No description provided for @categoryCrime.
  ///
  /// In vi, this message translates to:
  /// **'Pháp luật'**
  String get categoryCrime;

  /// No description provided for @categoryEducation.
  ///
  /// In vi, this message translates to:
  /// **'Giáo dục'**
  String get categoryEducation;

  /// No description provided for @categoryHealth.
  ///
  /// In vi, this message translates to:
  /// **'Sức khỏe'**
  String get categoryHealth;

  /// No description provided for @categoryOther.
  ///
  /// In vi, this message translates to:
  /// **'Nhà đất'**
  String get categoryOther;

  /// No description provided for @categoryTechnology.
  ///
  /// In vi, this message translates to:
  /// **'Xe cộ'**
  String get categoryTechnology;

  /// No description provided for @searchByTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm theo tiêu đề...'**
  String get searchByTitle;

  /// No description provided for @noArticlesFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy bài viết nào.'**
  String get noArticlesFound;

  /// No description provided for @loginRequiredTitle.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu đăng nhập'**
  String get loginRequiredTitle;

  /// No description provided for @loginRequiredMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn phải đăng nhập để sử dụng chức năng này.'**
  String get loginRequiredMessage;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @register.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get register;

  /// No description provided for @loginSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập thành công!'**
  String get loginSuccess;

  /// No description provided for @registrationSuccessTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký thành công'**
  String get registrationSuccessTitle;

  /// No description provided for @registrationSuccessMessage.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản của bạn đã được tạo'**
  String get registrationSuccessMessage;

  /// No description provided for @errorTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi'**
  String get errorTitle;

  /// No description provided for @ok.
  ///
  /// In vi, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @email.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get password;

  /// No description provided for @emailInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Email không hợp lệ.'**
  String get emailInvalid;

  /// No description provided for @passwordInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu phải có ít nhất 6 ký tự.'**
  String get passwordInvalid;

  /// No description provided for @switchToRegister.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tài khoản? Đăng ký ngay'**
  String get switchToRegister;

  /// No description provided for @switchToLogin.
  ///
  /// In vi, this message translates to:
  /// **'Đã có tài khoản? Đăng nhập'**
  String get switchToLogin;

  /// No description provided for @logout.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get logout;

  /// No description provided for @emailMustBeGmail.
  ///
  /// In vi, this message translates to:
  /// **'Email phải có đuôi @gmail.com.'**
  String get emailMustBeGmail;

  /// No description provided for @home.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get home;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

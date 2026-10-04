import 'dart:ui';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../data/models/response_model/login_remote_response_model/login_response_model.dart';
import '../../../../config/l10n.dart';
import 'memory_cache_manager.dart';

class CacheManager {
  static final CacheManager _instance = CacheManager._private();

  static CacheManager get instance {
    return _instance;
  }

  late SharedPreferences _prefs;

  static const String keyOnboardingShown = "onboardingShown";
  static const String keyToken = "token";
  static const String keyUserId = "userId";
  static const String keyUserName = "userName";
  static const String keyFCMDeviceToken = "fcmDeviceToken";
  static const String keyUserMobile = "userMobile";
  static const String keyLanguage = "language";
  static const String keyGrade = "grade";
  static const String keySemester = "semester";
  static const String keyIsGuestMode = "isGuestMode";

  CacheManager._private();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await Hive.initFlutter();
  }

  //ANCHOR Logout
  Future<void> logout() async {
    await _prefs.remove(keyToken);
    await _prefs.remove(keyUserId);
    await _prefs.remove(keyLanguage);
    await _prefs.remove(keyUserName);
    await _prefs.remove(keyUserMobile);
    await _prefs.remove(keyFCMDeviceToken);
    await _prefs.remove(keyGrade);
    await _prefs.remove(keySemester);
    await _prefs.remove(keyIsGuestMode);
  }

  void setOnBoardingShown(bool language) async {
    await _prefs.setBool(keyOnboardingShown, language);
  }

  bool getOnBoardingShown() {
    return _prefs.getBool(keyOnboardingShown) ?? false;
  }

  Future<void> setAuthToken(String? token) async {
    await _prefs.setString(keyToken, token ?? '');
  }

  String getAuthToken() {
    return _prefs.getString(keyToken) ?? "";
  }

  Future<void> setLanguage(String language) async {
    MemoryCacheManager.instance.setLanguage(language);
    await _prefs.setString(keyLanguage, language);
  }

  String? getLanguage() {
    return _prefs.getString(keyLanguage);
  }

  //notification
  void setNotification(bool value) async => await _prefs.setBool('notification', value);
  bool? getNotification() => _prefs.getBool('notification');

  //dark
  Future<void> setDarkMode(bool value) async => await _prefs.setBool('dark', value);
  bool? getDarkMode() => _prefs.getBool('dark');

  Future<void> setUserId(String? userId) async {
    await _prefs.setString(keyUserId, userId ?? '');
  }

  String getUserId() {
    return _prefs.getString(keyUserId) ?? '';
  }

  Future<void> setUserName(String? userName) async {
    await _prefs.setString(keyUserName, userName ?? '');
  }

  String getUserName() {
    return _prefs.getString(keyUserName) ?? '';
  }

  Future<void> setFCMDeviceToken(String? deviceToken) async {
    await _prefs.setString(keyFCMDeviceToken, deviceToken ?? '');
  }

  String getFCMDeviceToken() {
    return _prefs.getString(keyFCMDeviceToken) ?? '';
  }

  Future<void> setUserMobile(String? userMobile) async {
    await _prefs.setString(keyUserMobile, userMobile ?? '');
  }

  String getUserMobile() {
    return _prefs.getString(keyUserMobile) ?? '';
  }

  Future<void> setGrade(int? grade) async {
    if (grade != null) {
      await _prefs.setInt(keyGrade, grade);
    } else {
      await _prefs.remove(keyGrade);
    }
  }

  int? getGrade() {
    return _prefs.getInt(keyGrade);
  }

  Future<void> setSemester(int? semester) async {
    if (semester != null) {
      await _prefs.setInt(keySemester, semester);
    } else {
      await _prefs.remove(keySemester);
    }
  }

  int? getSemester() {
    return _prefs.getInt(keySemester);
  }

  Future<void> setUserData(LoginResponseModel? data) async {
    if (data == null) return;

    await Future.wait([
      setAuthToken(data.token),
      if (data.user?.id != null) setUserId(data.user!.id.toString()),
      if (data.user?.name != null) setUserName(data.user!.name!),
      if (data.user?.phone != null) setUserMobile(data.user!.phone!),
      if (data.user?.language != null) setLanguage(data.user!.language!),
    ]);
  }

  // Guest mode
  Future<void> setGuestMode(bool isGuest) async {
    await _prefs.setBool(keyIsGuestMode, isGuest);
  }

  bool isGuestMode() {
    return _prefs.getBool(keyIsGuestMode) ?? false;
  }
}

extension CacheManagerExtension on CacheManager {
  Locale getSavedLocale() {
    return getLanguage() == 'ar' ? L10n.langAr : L10n.langEn;
  }
}

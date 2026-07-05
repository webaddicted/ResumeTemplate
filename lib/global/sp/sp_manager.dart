import 'package:template/global/sp/sp_const.dart';
import 'package:template/global/sp/sp_helper.dart';
import 'package:template/global/sp/encrypted_sp_helper.dart';

class SPManager {
  static Future<bool> setTheme(bool isDark) async =>
      SPHelper.setPreference(SPConst.isThemeDark, isDark);

  static bool getTheme() =>
      SPHelper.getPreference(SPConst.isThemeDark, false) ?? false;

  static Future<bool> setOnboarding(bool shown) async =>
      SPHelper.setPreference(SPConst.isOnBoardingShow, shown);

  static bool getOnboarding() =>
      SPHelper.getPreference(SPConst.isOnBoardingShow, false) ?? false;

  static Future<bool> setLoggedIn(bool value) async =>
      SPHelper.setPreference(SPConst.isLoggedIn, value);

  static bool isLoggedIn() =>
      SPHelper.getPreference(SPConst.isLoggedIn, false) ?? false;

  static Future<bool> setUserEmail(String email) async =>
      SPHelper.setPreference(SPConst.userEmail, email);

  static String getUserEmail() =>
      SPHelper.getPreference(SPConst.userEmail, '') ?? '';

  static Future<bool> setScreenshotEnabled(bool enabled) async =>
      SPHelper.setPreference(SPConst.screenshotEnabled, enabled);

  static bool getScreenshotEnabled() =>
      SPHelper.getPreference(SPConst.screenshotEnabled, false) ?? false;

  static Future<bool> clearPref() async => SPHelper.clearPreference();

  static Future<bool> setSecure(String key, String value) async =>
      EncryptedSpHelper.setSecure(key, value);

  static String? getSecure(String key) => EncryptedSpHelper.getSecure(key);

  static Future<bool> setSecureUserId(String userId) async =>
      setSecure(SPConst.userId, userId);

  static String getSecureUserId() => getSecure(SPConst.userId) ?? '';
}

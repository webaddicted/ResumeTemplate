import 'dart:convert';

import 'package:template/global/sp/sp_helper.dart';
import 'package:template/global/utils/global_utility.dart';

/// Lightweight secure storage — base64 obfuscation without extra crypto deps.
class EncryptedSpHelper {
  static Future<void> init() async {}

  static String encrypt(String plainText) =>
      base64Encode(utf8.encode(plainText));

  static String decrypt(String cipherText) =>
      utf8.decode(base64Decode(cipherText));

  static Future<bool> setSecure(String key, String value) async {
    try {
      return await SPHelper.setPreference(key, encrypt(value));
    } catch (e) {
      printLog(msg: 'EncryptedSpHelper setSecure: $e');
      return false;
    }
  }

  static String? getSecure(String key, {String defaultValue = ''}) {
    try {
      final stored = SPHelper.getPreference<String>(key, defaultValue);
      if (stored == null || stored.isEmpty) return stored;
      return decrypt(stored);
    } catch (e) {
      printLog(msg: 'EncryptedSpHelper getSecure: $e');
      return defaultValue.isEmpty ? null : defaultValue;
    }
  }
}

import 'package:template/global/utils/global_utility.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SPHelper {
  static SharedPreferences? sp;
  static Future<void> init() async {
    sp ??= await SharedPreferences.getInstance();
  }
  static T? getPreference<T>(String key, T defaultValue) {
    try {
      if (defaultValue is String) {
        return sp?.getString(key) as T? ?? defaultValue;
      } else if (defaultValue is bool) {
        return sp?.getBool(key) as T? ?? defaultValue;
      } else if (defaultValue is int) {
        return sp?.getInt(key) as T? ?? defaultValue;
      } else if (defaultValue is double) {
        return sp?.getDouble(key) as T? ?? defaultValue;
      } else if (defaultValue is List<String>) {
        return sp?.getStringList(key) as T? ?? defaultValue;
      } else {
        return defaultValue;
      }
    } catch (e) {
      printLog(msg:"SP helper getPreference: $key $defaultValue $e");
    }
    return defaultValue;
  }

  static Future<bool> setPreference<T>(String key, T value) async {
    try {
      if (value is String) {
        return await sp?.setString(key, value) ?? false;
      } else if (value is bool) {
        return await sp?.setBool(key, value) ?? false;
      } else if (value is int) {
        return await sp?.setInt(key, value) ?? false;
      } else if (value is double) {
        return await sp?.setDouble(key, value) ?? false;
      } else if (value is List<String>) {
        return await sp?.setStringList(key, value) ?? false;
      }
    } catch (e) {
      printLog(msg:"SP helper setPreference: $key $e");
    }
    return false;
  }

  static Future<Set<String>?> getAllKeys() async {
    try {
      return sp?.getKeys();
    } catch (e) {
      printLog(msg:e.toString());
    }
    return null;
  }

  static Future<bool> removeKey(String key) async {
    try {
      return await sp?.remove(key) ?? false;
    } catch (e) {
      printLog(msg:e.toString());
    }
    return false;
  }

  static Future<bool> clearPreference() async {
    try {
      return await sp?.clear() ?? false;
    } catch (e) {
      printLog(msg:e.toString());
    }
    return false;
  }

  static Future<bool?> keyExist(String key) async {
    try {
      return sp?.containsKey(key);
    } catch (e) {
      printLog(msg:e.toString());
    }
    return null;
  }

  /// Batch operations for better performance
  static Future<bool> setBatch(Map<String, dynamic> values) async {
    try {
      bool allSuccess = true;
      for (final entry in values.entries) {
        final success = await setPreference(entry.key, entry.value);
        if (!success) allSuccess = false;
      }
      return allSuccess;
    } catch (e) {
      printLog(msg:"SP helper setBatch error: $e");
      return false;
    }
  }

  static Map<String, dynamic> getBatch(List<String> keys, Map<String, dynamic> defaults) {
    final Map<String, dynamic> result = {};
    try {
      for (final key in keys) {
        final defaultValue = defaults[key];
        result[key] = getPreference(key, defaultValue);
      }
    } catch (e) {
      printLog(msg:"SP helper getBatch error: $e");
    }
    return result;
  }

  /// Get preference synchronously (use carefully)
  static T? getPreferenceSync<T>(String key, T defaultValue) {
    try {
      if (sp == null) return defaultValue;
      
      if (defaultValue is String) {
        return sp!.getString(key) as T? ?? defaultValue;
      } else if (defaultValue is bool) {
        return sp!.getBool(key) as T? ?? defaultValue;
      } else if (defaultValue is int) {
        return sp!.getInt(key) as T? ?? defaultValue;
      } else if (defaultValue is double) {
        return sp!.getDouble(key) as T? ?? defaultValue;
      } else if (defaultValue is List<String>) {
        return sp!.getStringList(key) as T? ?? defaultValue;
      } else {
        return defaultValue;
      }
    } catch (e) {
      printLog(msg:"SP helper getPreferenceSync: $key $defaultValue $e");
    }
    return defaultValue;
  }
}

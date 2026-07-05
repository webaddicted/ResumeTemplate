import 'package:flutter/foundation.dart';

/// Cross-platform helpers — safe to import on web (no dart:io).
class PlatformHelper {
  PlatformHelper._();

  static bool get isWeb => kIsWeb;

  static bool get isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static bool get isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static bool get isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);

  /// Runs [action] only when [condition] is true; otherwise returns [orElse].
  static Future<T?> runWhen<T>({
    required bool condition,
    required Future<T> Function() action,
    T? orElse,
  }) async {
    if (!condition) return orElse;
    return action();
  }

  /// Runs [action] only on mobile (Android/iOS).
  static Future<T?> onMobile<T>(Future<T> Function() action, {T? orElse}) =>
      runWhen(condition: isMobile, action: action, orElse: orElse);

  /// Runs [action] only on Android.
  static Future<T?> onAndroid<T>(Future<T> Function() action, {T? orElse}) =>
      runWhen(condition: isAndroid, action: action, orElse: orElse);

  /// Runs [action] only on iOS.
  static Future<T?> onIOS<T>(Future<T> Function() action, {T? orElse}) =>
      runWhen(condition: isIOS, action: action, orElse: orElse);
}

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Safe env read — returns [fallback] when dotenv is not loaded or key is missing.
/// Use this instead of `dotenv.env[key]` (which throws if dotenv is not initialized).
String envOr(String key, String fallback) {
  if (!dotenv.isInitialized) return fallback;
  return dotenv.env[key] ?? fallback;
}

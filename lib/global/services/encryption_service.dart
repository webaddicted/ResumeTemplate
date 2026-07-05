import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// On-device text obfuscation for local storage helpers.
///
/// Uses base64 encoding to avoid extra crypto dependencies. For production
/// secrets at rest, pair with platform keychains or a dedicated crypto package.
class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  bool _ready = false;

  Future<void> init() async {
    _ready = true;
  }

  String encryptText(String plain) {
    _ensureReady();
    return base64Encode(utf8.encode(plain));
  }

  String decryptText(String cipher) {
    _ensureReady();
    return utf8.decode(base64Decode(cipher));
  }

  Future<String> getFilePath(String fileName) async {
    if (Platform.isAndroid) {
      final downloads = Directory('/storage/emulated/0/Download');
      if (await downloads.exists()) return '${downloads.path}/$fileName';
    }
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$fileName';
  }

  void _ensureReady() {
    if (!_ready) {
      throw StateError('EncryptionService not initialized');
    }
  }
}

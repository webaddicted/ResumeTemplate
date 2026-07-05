import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

bool isEmpty(String? value) =>
    value == null || value.isEmpty || value == 'null';

Color colorFromHex(String hexColor) {
  final hex = hexColor.replaceAll('#', '');
  return Color(int.parse('FF$hex', radix: 16));
}

final Logger _logger = Logger(
  printer: PrettyPrinter(methodCount: 0, errorMethodCount: 5),
);

void printLog({required String msg}) {
  if (kDebugMode) _logger.d(msg);
}

Future<void> launchUrlString(String url) async {
  final uri = Uri.tryParse(url);
  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

Future<void> imagePickDialog(void Function(File file, String? base64) onPicked) async {
  await Get.dialog(
    AlertDialog(
      title: const Text('Select image'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () {
              Get.back();
              _pickImage(ImageSource.camera, onPicked);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () {
              Get.back();
              _pickImage(ImageSource.gallery, onPicked);
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> _pickImage(
  ImageSource source,
  void Function(File file, String? base64) onPicked,
) async {
  final picked = await ImagePicker().pickImage(source: source, imageQuality: 70);
  if (picked == null) return;
  final file = File(picked.path);
  final bytes = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    minWidth: 800,
    minHeight: 800,
    quality: 70,
  );
  final encoded = bytes != null ? base64Encode(bytes) : null;
  onPicked(file, encoded != null ? 'data:image/jpeg;base64,$encoded' : null);
}

void back<T>([T? result]) => Get.back<T>(result: result);

bool isDarkMode() => Get.isDarkMode;

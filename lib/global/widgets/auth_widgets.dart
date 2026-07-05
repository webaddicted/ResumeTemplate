import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:template/global/constant/color_const.dart';
import 'package:template/global/theme/text_style.dart';

class AuthWidgets {
  AuthWidgets._();

  static void showLogoutDialog({required VoidCallback onConfirm}) {
    Get.dialog(
      AlertDialog(
        title: Text('Logout', style: AppTextStyle.titleMedium),
        content: Text('Are you sure you want to logout?', style: AppTextStyle.bodySmall),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  static Widget loginButton({required VoidCallback onPressed, bool loading = false}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConst.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: loading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Text('Continue', style: AppTextStyle.titleMedium.copyWith(color: Colors.white)),
      ),
    );
  }
}

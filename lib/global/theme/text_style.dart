import 'package:flutter/material.dart';
import 'package:template/global/constant/color_const.dart';

class AppTextStyle {
  // Standard font sizes — mandatory on every screen (flutter-ai-ui-skill)
  // 14px: body, titles, buttons, inputs, nav | 12px: captions, subtitles, small labels
  // 16–18px: section/page headers only | 20–32px: hero/splash only
  static const double fontSize12 = 12;
  static const double fontSize14 = 14;
  static const double fontSize16 = 16;
  static const double fontSize18 = 18;
  static const double fontSize20 = 20;
  static const double fontSize24 = 24;
  static const double fontSize32 = 32;

  // Display Styles — hero / splash only
  static TextStyle displayLarge = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.1,
  );

  static TextStyle displayMedium = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.2,
  );

  static TextStyle displaySmall = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );

  // Headline Styles — page / section headers
  static TextStyle headlineLarge = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );

  static TextStyle headlineMedium = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
  );

  static TextStyle headlineSmall = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
  );

  // Title Styles — 14px (body tier: list titles, dialog labels, card headers)
  static TextStyle titleLarge = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static TextStyle titleMedium = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle titleSmall = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );

  // Body Styles
  static TextStyle bodyLarge = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.5,
  );

  static TextStyle bodyMedium = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.4,
  );

  static TextStyle bodySmall = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.3,
  );

  // Label Styles
  static TextStyle labelLarge = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle labelMedium = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.3,
  );

  static TextStyle labelSmall = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.2,
  );

  // Legacy styles for backward compatibility
  static TextStyle normalBlack8 = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize12,
    fontWeight: FontWeight.normal,
  );

  static TextStyle normalBlack10 = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize12,
    fontWeight: FontWeight.normal,
  );

  static TextStyle normalBlack12 = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize12,
    fontWeight: FontWeight.normal,
  );

  static TextStyle normalGrey12 = TextStyle(
    color: ColorConst.greyColor,
    fontSize: fontSize12,
    fontWeight: FontWeight.normal,
  );

  // Specialized Styles
  static TextStyle caption = TextStyle(
    color: ColorConst.greyColor,
    fontSize: fontSize12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.2,
  );

  static TextStyle overline = TextStyle(
    color: ColorConst.greyColor,
    fontSize: fontSize12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.0,
  );

  // Button Text Styles
  static TextStyle buttonText = TextStyle(
    color: Colors.white,
    fontSize: fontSize14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );

  // Card Title Styles
  static TextStyle cardTitle = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
  );

  static TextStyle cardSubtitle = TextStyle(
    color: ColorConst.greyColor,
    fontSize: fontSize12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.3,
  );

  // Navigation Styles
  static TextStyle navTitle = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.3,
  );

  static TextStyle navSubtitle = TextStyle(
    color: ColorConst.greyColor,
    fontSize: fontSize12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.3,
  );

  // Form Styles
  static TextStyle inputLabel = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle inputHint = TextStyle(
    color: ColorConst.greyColor,
    fontSize: fontSize14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.4,
  );

  static TextStyle inputText = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.4,
  );

  // Error Styles
  static TextStyle errorText = TextStyle(
    color: ColorConst.redColor,
    fontSize: fontSize12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.3,
  );

  // Success Styles
  static TextStyle successText = TextStyle(
    color: ColorConst.greenColor,
    fontSize: fontSize12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.3,
  );

  // Warning Styles
  static TextStyle warningText = TextStyle(
    color: ColorConst.yellowColor,
    fontSize: fontSize12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.3,
  );
}

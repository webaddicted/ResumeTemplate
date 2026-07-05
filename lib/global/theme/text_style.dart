import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:template/global/constant/color_const.dart';

class AppTextStyle {
  // Modern Typography Scale - Further Reduced sizes
  static const double fontSize8 = kIsWeb ? 4 : 7;
  static const double fontSize10 = kIsWeb ? 6 : 9;
  static const double fontSize12 = kIsWeb ? 8 : 11;
  static const double fontSize14 = kIsWeb ? 10 : 13;
  static const double fontSize16 = kIsWeb ? 12 : 15;
  static const double fontSize18 = kIsWeb ? 14 : 17;
  static const double fontSize20 = kIsWeb ? 16 : 19;
  static const double fontSize24 = kIsWeb ? 20 : 23;
  static const double fontSize28 = kIsWeb ? 24 : 27;
  static const double fontSize32 = kIsWeb ? 28 : 31;
  static const double fontSize36 = kIsWeb ? 32 : 35;
  static const double fontSize48 = kIsWeb ? 44 : 47;

  // Display Styles
  static TextStyle displayLarge = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize48,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.1,
  );

  static TextStyle displayMedium = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize36,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.2,
  );

  static TextStyle displaySmall = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );

  // Headline Styles
  static TextStyle headlineLarge = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );

  
  static TextStyle headlineMedium = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
  );

  static TextStyle headlineSmall = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
  );

  // Title Styles
  static TextStyle titleLarge = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize16,
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
    fontSize: fontSize16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
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
    fontSize: fontSize14,
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
    fontSize: fontSize10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.2,
  );

  // Legacy styles for backward compatibility
  static TextStyle normalBlack8 = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize8,
    fontWeight: FontWeight.normal,
  );

  static TextStyle normalBlack10 = TextStyle(
    color: ColorConst.blackColor,
    fontSize: fontSize10,
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
    fontSize: fontSize10,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.2,
  );

  static TextStyle overline = TextStyle(
    color: ColorConst.greyColor,
    fontSize: fontSize8,
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
    fontSize: fontSize16,
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
    fontSize: fontSize18,
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

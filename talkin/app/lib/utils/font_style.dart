import 'dart:ui';

import 'package:google_fonts/google_fonts.dart';

class AppFontStyle {
  static fontStyleW400({required double fontSize, required Color fontColor, double? height}) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      color: fontColor,
      height: height,
      fontWeight: FontWeight.w400,
    );
  }

  static fontStyleKaushanW400({required double fontSize, required Color fontColor, FontWeight? font}) {
    return GoogleFonts.kaushanScript(
      fontSize: fontSize,
      color: fontColor,
      fontWeight: font ?? FontWeight.w400,
    );
  }

  static fontStyleLato700({required double fontSize, required Color fontColor}) {
    return GoogleFonts.lato(
      fontSize: fontSize,
      color: fontColor,
      fontWeight: FontWeight.w900,
      fontStyle: FontStyle.italic,
    );
  }

  static fontStyleW500({required double fontSize, required Color fontColor, TextDecoration? textDecoration, double? height, Color? decorationColor}) {
    return GoogleFonts.poppins(
        fontSize: fontSize,
        color: fontColor,
        height: height,
        fontWeight: FontWeight.w500,
        decoration: textDecoration,
        decorationColor: decorationColor);
  }

  static fontStyleW600({
    required double fontSize,
    required Color fontColor,
    TextDecoration? textDecoration,
    Color? decorationColor,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      color: fontColor,
      fontWeight: FontWeight.w600,
      decoration: textDecoration,
      decorationColor: decorationColor,
    );
  }

  static fontStyleW700({
    required double fontSize,
    required Color fontColor,
    TextDecoration? textDecoration,
    Color? decorationColor,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      color: fontColor,
      fontWeight: FontWeight.w700,
      decoration: textDecoration,
      decorationColor: decorationColor,
    );
  }

  static fontStyleW800({
    required double fontSize,
    required Color fontColor,
    TextDecoration? textDecoration,
    Color? decorationColor,
    double? letterSpace,
  }) {
    return GoogleFonts.poppins(
        fontSize: fontSize,
        color: fontColor,
        fontWeight: FontWeight.w800,
        decoration: textDecoration,
        decorationColor: decorationColor,
        letterSpacing: letterSpace);
  }

  static fontStyleW900({required double fontSize, required Color fontColor}) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      color: fontColor,
      fontWeight: FontWeight.w900,
    );
  }
}

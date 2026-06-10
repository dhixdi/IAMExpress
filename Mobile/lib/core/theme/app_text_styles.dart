import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle displayLarge = GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle headlineMedium = GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle titleMedium = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle bodyLarge = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static TextStyle bodyMedium = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static TextStyle bodySmall = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMuted);
  static TextStyle labelSmall = GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary);
}

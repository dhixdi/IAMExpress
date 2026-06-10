import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

({Color bg, Color text, Color border}) getStatusColors(String status) {
  return switch (status) {
    'Created' => (bg: AppColors.statusCreatedBg, text: AppColors.statusCreatedText, border: AppColors.statusCreatedBorder),
    'Received at Warehouse' => (bg: AppColors.statusReceivedBg, text: AppColors.statusReceivedText, border: AppColors.statusReceivedBorder),
    'Assigned to Linehaul' => (bg: AppColors.statusLinehaulBg, text: AppColors.statusLinehaulText, border: AppColors.statusLinehaulBorder),
    'Picked Up' => (bg: AppColors.statusPickedUpBg, text: AppColors.statusPickedUpText, border: AppColors.statusPickedUpBorder),
    'In Transit' => (bg: AppColors.statusTransitBg, text: AppColors.statusTransitText, border: AppColors.statusTransitBorder),
    'Arrived at Warehouse' => (bg: AppColors.statusArrivedBg, text: AppColors.statusArrivedText, border: AppColors.statusArrivedBorder),
    'Assigned to Courier' => (bg: AppColors.statusCourierBg, text: AppColors.statusCourierText, border: AppColors.statusCourierBorder),
    'Out For Delivery' => (bg: AppColors.statusOutDelivBg, text: AppColors.statusOutDelivText, border: AppColors.statusOutDelivBorder),
    'Delivered' => (bg: AppColors.statusDeliveredBg, text: AppColors.statusDeliveredText, border: AppColors.statusDeliveredBorder),
    'Failed Delivery' => (bg: AppColors.statusFailedBg, text: AppColors.statusFailedText, border: AppColors.statusFailedBorder),
    _ => (bg: AppColors.statusCreatedBg, text: AppColors.statusCreatedText, border: AppColors.statusCreatedBorder),
  };
}

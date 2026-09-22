import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/font_style.dart';

class CustomRangePicker {
  static Future<DateTimeRange?> onShow(
    BuildContext context,
    DateTimeRange? initialDateRange,
  ) async {
    return await showRangePickerDialog(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      contentPadding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      context: context,
      slidersColor: AppColors.black,
      maxDate: DateTime.now(),
      selectedRange: initialDateRange,
      minDate: DateTime(1900, 1, 1),
      barrierColor: AppColors.black.withValues(alpha: 0.8),
      selectedCellsTextStyle: AppFontStyle.fontStyleW500(fontColor: AppColors.black, fontSize: 16),
      enabledCellsTextStyle: AppFontStyle.fontStyleW500(fontColor: AppColors.black, fontSize: 16),
      disabledCellsTextStyle: AppFontStyle.fontStyleW500(fontColor: AppColors.grey, fontSize: 16),
      singleSelectedCellTextStyle: AppFontStyle.fontStyleW500(fontColor: AppColors.white, fontSize: 14),
      singleSelectedCellDecoration: BoxDecoration(color: AppColors.appColor, shape: BoxShape.circle),
      currentDateTextStyle: AppFontStyle.fontStyleW500(
        fontColor: initialDateRange == null ? AppColors.white : AppColors.black,
        fontSize: 16,
      ),
      currentDateDecoration: BoxDecoration(
        color: initialDateRange == null ? AppColors.appColor : AppColors.transparent,
        shape: BoxShape.circle,
      ),
      daysOfTheWeekTextStyle: AppFontStyle.fontStyleW500(fontColor: AppColors.black.withValues(alpha: 0.6), fontSize: 14),
      leadingDateTextStyle: AppFontStyle.fontStyleW500(fontColor: AppColors.black, fontSize: 20),
      centerLeadingDate: true,
    );
  }
}

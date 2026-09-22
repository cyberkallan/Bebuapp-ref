import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:talk_in/custom/listeners/listener_photo_card.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/controller/edit_profile_screen_controller.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';

/// Photo with change action. Tapping opens a small source sheet.
class EditProfilePhoto extends StatelessWidget {
  const EditProfilePhoto({super.key, this.onAvatarStudio});
  final VoidCallback? onAvatarStudio;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(
      id: EditProfileController.idForm,
      builder: (c) {
        final local = c.pickImage;
        return Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 116,
                  height: 116,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: BebuTheme.pinkGradient,
                    boxShadow: [BoxShadow(color: BebuTheme.pink.withValues(alpha: 0.3), blurRadius: 26, offset: const Offset(0, 10))],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: BebuTheme.bg),
                    child: ClipOval(
                      child: local != null ? Image.file(File(local), fit: BoxFit.cover) : ListenerPhoto(image: c.profilePic, scrim: false, cacheWidth: 400),
                    ),
                  ),
                ),
                PressScale(
                  onTap: () => _sourceSheet(context, c),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(shape: BoxShape.circle, gradient: BebuTheme.pinkGradient, border: Border.all(color: BebuTheme.bg, width: 3)),
                    child: const Icon(Icons.photo_camera_rounded, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(local != null ? 'New photo selected' : 'Tap the camera to change your photo', style: BebuTheme.body(size: 12, color: BebuTheme.textFaint)),
          ],
        );
      },
    );
  }

  void _sourceSheet(BuildContext context, EditProfileController c) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(color: BebuTheme.bg, borderRadius: BorderRadius.vertical(top: Radius.circular(BebuTheme.radiusXl)), border: Border(top: BorderSide(color: BebuTheme.borderStrong))),
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.paddingOf(context).bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: BebuTheme.borderStrong, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 14),
            Text('Profile photo', style: BebuTheme.title(size: 17)),
            const SizedBox(height: 14),
            _SheetRow(icon: Icons.photo_library_rounded, color: BebuTheme.violet, label: 'Choose from gallery', onTap: () {
              Get.back();
              c.getImageFromGallery();
            }),
            _SheetRow(icon: Icons.photo_camera_rounded, color: BebuTheme.blue, label: 'Take a photo', onTap: () {
              Get.back();
              c.takePhoto();
            }),
            if (onAvatarStudio != null)
              _SheetRow(icon: Icons.auto_awesome_rounded, color: BebuTheme.pink, label: 'Use a 3D avatar instead', onTap: () {
                Get.back();
                onAvatarStudio!();
              }),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({required this.icon, required this.color, required this.label, required this.onTap});
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      scale: 0.985,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(BebuTheme.radiusMd), border: Border.all(color: BebuTheme.border)),
        child: Row(
          children: [
            Container(width: 38, height: 38, decoration: BoxDecoration(borderRadius: BorderRadius.circular(BebuTheme.radiusSm), color: color.withValues(alpha: 0.18)), child: Icon(icon, size: 19, color: color)),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: BebuTheme.label(size: 14))),
            Icon(Icons.chevron_right_rounded, color: BebuTheme.textFaint),
          ],
        ),
      ),
    );
  }
}

/// Section label + card.
class EditSection extends StatelessWidget {
  const EditSection({super.key, required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.fromLTRB(4, 0, 4, 8), child: Text(title, style: BebuTheme.label(size: 12, color: BebuTheme.textFaint))),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
          decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(BebuTheme.radiusLg), border: Border.all(color: BebuTheme.border)),
          child: Column(children: children),
        ),
      ],
    );
  }
}

/// Labelled text field row inside an [EditSection].
class EditField extends StatelessWidget {
  const EditField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.icon,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
    this.trailing,
    this.last = false,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
  });
  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? icon;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final Widget? trailing;
  final bool last;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              if (icon != null) ...[Icon(icon, size: 18, color: readOnly ? BebuTheme.textFaint : BebuTheme.pink), const SizedBox(width: 12)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: BebuTheme.body(size: 11, color: BebuTheme.textFaint)),
                    TextField(
                      controller: controller,
                      readOnly: readOnly,
                      onTap: onTap,
                      keyboardType: keyboardType,
                      onChanged: onChanged,
                      minLines: 1,
                      maxLines: maxLines,
                      maxLength: maxLength,
                      buildCounter: maxLength == null ? null : (_, {required currentLength, required isFocused, maxLength}) => isFocused ? Text('$currentLength/$maxLength', style: BebuTheme.body(size: 10.5, color: BebuTheme.textFaint)) : null,
                      style: BebuTheme.label(size: 15, color: readOnly && onTap == null ? BebuTheme.textMuted : BebuTheme.text),
                      cursorColor: BebuTheme.pink,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 6),
                        border: InputBorder.none,
                        hintText: hint,
                        hintStyle: BebuTheme.body(size: 15, color: BebuTheme.textFaint),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              if (readOnly && onTap != null) Icon(Icons.chevron_right_rounded, color: BebuTheme.textFaint),
              if (readOnly && onTap == null) Icon(Icons.lock_outline_rounded, size: 15, color: BebuTheme.textFaint),
            ],
          ),
        ),
        if (!last) Divider(height: 1, color: BebuTheme.border),
      ],
    );
  }
}

/// Male / female toggle, only persisted on save.
class EditGenderRow extends StatelessWidget {
  const EditGenderRow({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(
      id: Constant.idGenderSelect,
      builder: (c) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(Icons.wc_rounded, size: 18, color: BebuTheme.pink),
            const SizedBox(width: 12),
            Expanded(child: Text(EnumLocale.txtGenderIdentity.name.tr, style: BebuTheme.body(size: 13.5))),
            SizedBox(
              width: 170,
              child: SegmentedPill(
                height: 38,
                index: c.selectedIndex,
                onChanged: c.selectGender,
                segments: [SegmentItem(EnumLocale.txtMale.name.tr, Icons.male_rounded), SegmentItem(EnumLocale.txtFemale.name.tr, Icons.female_rounded)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Country picker row (flag + name).
class EditCountryRow extends StatelessWidget {
  const EditCountryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(
      id: Constant.idChangeCountry,
      builder: (c) => Column(
        children: [
          PressScale(
            scale: 0.99,
            onTap: () => c.onChangeCountry(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.public_rounded, size: 18, color: BebuTheme.pink),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(EnumLocale.txtSelectCountry.name.tr, style: BebuTheme.body(size: 11, color: BebuTheme.textFaint)),
                        const SizedBox(height: 4),
                        Text(
                          c.countryController.text.isEmpty ? 'Choose your country' : '${c.flagController.text}  ${c.countryController.text}',
                          style: BebuTheme.label(size: 15, color: c.countryController.text.isEmpty ? BebuTheme.textFaint : BebuTheme.text),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: BebuTheme.textFaint),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: BebuTheme.border),
        ],
      ),
    );
  }
}

/// Phone number with dial-code dropdown, themed.
class EditPhoneRow extends StatelessWidget {
  const EditPhoneRow({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(
      builder: (c) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.only(top: 22), child: Icon(Icons.phone_rounded, size: 18, color: BebuTheme.pink)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(EnumLocale.txtEnterMobileNumber.name.tr, style: BebuTheme.body(size: 11, color: BebuTheme.textFaint)),
                  Form(
                    key: c.formKey,
                    child: IntlPhoneField(
                      controller: c.mobileNumberCnt,
                      initialCountryCode: Database.selectedCountryCode,
                      showCountryFlag: true,
                      disableLengthCheck: true,
                      flagsButtonPadding: EdgeInsets.zero,
                      flagsButtonMargin: const EdgeInsets.only(right: 8),
                      dropdownIconPosition: IconPosition.trailing,
                      dropdownIcon: Icon(Icons.arrow_drop_down_rounded, color: BebuTheme.textMuted),
                      dropdownTextStyle: BebuTheme.label(size: 14),
                      style: BebuTheme.label(size: 15),
                      cursorColor: BebuTheme.pink,
                      keyboardType: TextInputType.phone,
                      pickerDialogStyle: PickerDialogStyle(
                        backgroundColor: BebuTheme.surface,
                        countryCodeStyle: BebuTheme.label(size: 13),
                        countryNameStyle: BebuTheme.body(size: 13.5),
                        searchFieldCursorColor: BebuTheme.pink,
                        searchFieldInputDecoration: InputDecoration(
                          hintText: EnumLocale.txtSearchCountryCode.name.tr,
                          hintStyle: BebuTheme.body(size: 14, color: BebuTheme.textFaint),
                          prefixIcon: Icon(Icons.search_rounded, color: BebuTheme.textFaint),
                          filled: true,
                          fillColor: BebuTheme.surface2,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(BebuTheme.radiusMd), borderSide: BorderSide.none),
                        ),
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(vertical: 6),
                        border: InputBorder.none,
                        hintText: '98765 43210',
                        hintStyle: BebuTheme.body(size: 15, color: BebuTheme.textFaint),
                      ),
                      onCountryChanged: (value) {
                        Database.onSetSelectedCountryCode(value.code);
                        Database.getDialCode();
                      },
                      onChanged: (phone) {
                        c.dialCode = phone.countryCode;
                        c.update([EditProfileController.idForm]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talk_in/custom/listeners/listener_photo_card.dart';
import 'package:talk_in/custom/motion/sfx.dart';
import 'package:talk_in/ui/user_flow/avatar_studio/api/avatar_studio_api.dart';
import 'package:talk_in/ui/user_flow/avatar_studio/model/avatar_studio_model.dart';
import 'package:talk_in/ui/user_flow/avatar_studio/widget/avatar_stage.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/api/edit_profile_api.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/controller/edit_profile_screen_controller.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

/// Profile picture flow used when the admin has the studio switched off (and
/// as the "use my photo" path when it is on): upload a photo, or pick one of
/// the three male / three female premade avatars.
class PhotoAvatarPicker extends StatefulWidget {
  const PhotoAvatarPicker({super.key, required this.presetsMale, required this.presetsFemale, this.allowUpload = true, this.onChanged});
  final List<AvatarItem> presetsMale;
  final List<AvatarItem> presetsFemale;
  final bool allowUpload;
  final VoidCallback? onChanged;

  @override
  State<PhotoAvatarPicker> createState() => _PhotoAvatarPickerState();
}

class _PhotoAvatarPickerState extends State<PhotoAvatarPicker> {
  bool _busy = false;
  String? _busyKey;

  Future<void> _pick(ImageSource source) async {
    if (_busy) return;
    final file = await ImagePicker().pickImage(source: source, imageQuality: 88, maxWidth: 1600);
    if (file == null) return;
    setState(() {
      _busy = true;
      _busyKey = 'upload';
    });
    final res = await EditProfileApi.callApi(
      uid: Database.loginUserFirebaseId,
      nickName: Database.loginUserNickName,
      gender: Database.loginUserGender,
      phoneNumber: Database.loginUserPhoneNumber,
      birthDate: Database.loginUserBirthDate,
      country: Database.country,
      countryFlag: Database.countryFlag,
      countryCode: Database.selectedCountryCode,
      fullName: Database.loginUserName,
      image: file.path,
    );
    if (!mounted) return;
    if (res?.status == true) {
      final pic = res?.user?.profilePic;
      if (pic != null && pic.isNotEmpty) await _applyPic(pic);
      Sfx.select();
      if (mounted) Utils.showToast(context, 'Photo updated');
      widget.onChanged?.call();
    } else {
      Sfx.deny();
      Utils.showToast(context, 'Could not upload the photo');
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _preset(AvatarItem p) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _busyKey = p.key;
    });
    final r = await AvatarStudioApi.usePreset(p.key);
    if (!mounted) return;
    if (r.ok) {
      final pic = r.data?['profilePic']?.toString() ?? p.image;
      await _applyPic(pic);
      Sfx.pop();
      widget.onChanged?.call();
    } else {
      Sfx.deny();
      Utils.showToast(context, r.message.isEmpty ? 'Could not update' : r.message);
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _applyPic(String pic) async {
    await Database.onSetLoginUserProfilePic(pic);
    Database.fetchLoginUserProfileModel?.user?.profilePic = pic;
    if (Get.isRegistered<EditProfileController>()) {
      final c = Get.find<EditProfileController>();
      c.profilePic = pic;
      c.update([Constant.idProfile]);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final current = Database.loginUserProfilePic;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 132,
            height: 132,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: BebuTheme.pinkGradient,
              boxShadow: [BoxShadow(color: BebuTheme.pink.withValues(alpha: 0.35), blurRadius: 30, offset: const Offset(0, 12))],
            ),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(shape: BoxShape.circle, color: BebuTheme.bg),
              child: ClipOval(
                child: _busy && _busyKey == 'upload'
                    ? Center(child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5, color: BebuTheme.pink)))
                    : ListenerPhoto(image: current, scrim: false, cacheWidth: 400),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (widget.allowUpload) ...[
          Row(
            children: [
              Expanded(child: _SourceButton(icon: Icons.photo_library_rounded, label: 'Gallery', color: BebuTheme.violet, onTap: () => _pick(ImageSource.gallery))),
              const SizedBox(width: 10),
              Expanded(child: _SourceButton(icon: Icons.photo_camera_rounded, label: 'Camera', color: BebuTheme.blue, onTap: () => _pick(ImageSource.camera))),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: Divider(color: BebuTheme.border)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('or pick a bebu avatar', style: BebuTheme.body(size: 12, color: BebuTheme.textFaint))),
              Expanded(child: Divider(color: BebuTheme.border)),
            ],
          ),
          const SizedBox(height: 14),
        ],
        _PresetRow(label: 'Male', items: widget.presetsMale, current: current, busyKey: _busy ? _busyKey : null, onTap: _preset),
        const SizedBox(height: 12),
        _PresetRow(label: 'Female', items: widget.presetsFemale, current: current, busyKey: _busy ? _busyKey : null, onTap: _preset),
      ],
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(BebuTheme.radiusMd), border: Border.all(color: BebuTheme.border)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 34, height: 34, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.18)), child: Icon(icon, size: 17, color: color)),
            const SizedBox(width: 10),
            Text(label, style: BebuTheme.label(size: 13.5)),
          ],
        ),
      ),
    );
  }
}

class _PresetRow extends StatelessWidget {
  const _PresetRow({required this.label, required this.items, required this.current, required this.busyKey, required this.onTap});
  final String label;
  final List<AvatarItem> items;
  final String current;
  final String? busyKey;
  final ValueChanged<AvatarItem> onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(label, style: BebuTheme.label(size: 12, color: BebuTheme.textFaint))),
        Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              Expanded(
                child: PressScale(
                  scale: 0.95,
                  onTap: () => onTap(items[i]),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: AnimatedContainer(
                      duration: BebuTheme.fast,
                      padding: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(BebuTheme.radiusMd),
                        gradient: current == items[i].image ? BebuTheme.pinkGradient : null,
                        color: current == items[i].image ? null : BebuTheme.border,
                      ),
                      child: Container(
                        decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(BebuTheme.radiusMd - 1.5)),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Padding(padding: const EdgeInsets.all(10), child: StudioImage(items[i], size: 90)),
                            if (busyKey == items[i].key) SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: BebuTheme.pink)),
                            if (current == items[i].image)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, gradient: BebuTheme.pinkGradient), child: const Icon(Icons.check_rounded, size: 13, color: Colors.white)),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (i != items.length - 1) const SizedBox(width: 10),
            ],
          ],
        ),
      ],
    );
  }
}

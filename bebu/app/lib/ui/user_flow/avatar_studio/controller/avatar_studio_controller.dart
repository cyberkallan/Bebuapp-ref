import 'package:get/get.dart';
import 'package:talk_in/custom/motion/sfx.dart';
import 'package:talk_in/ui/user_flow/avatar_studio/api/avatar_studio_api.dart';
import 'package:talk_in/ui/user_flow/avatar_studio/model/avatar_studio_model.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/controller/edit_profile_screen_controller.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/controller/my_wallet_controller.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';

/// Studio state: the server look, a local *draft* the user is composing, and
/// an optional *try-on* (a locked item previewed on the stage before buying).
class AvatarStudioController extends GetxController {
  static const idStage = 'studio.stage';
  static const idGrid = 'studio.grid';
  static const idBar = 'studio.bar';
  static const idCoins = 'studio.coins';

  static bool get enabledBySettings => Database.settingApiModel?.data?.avatarStudio?['enabled'] != false;
  static bool get photoUploadAllowed => Database.settingApiModel?.data?.avatarStudio?['allowPhotoUpload'] != false;

  StudioData? data;
  bool loading = true;
  bool failed = false;
  bool saving = false;
  bool unlocking = false;

  /// Bonus coins the last successful unlock paid back (0 when none).
  int lastBonus = 0;

  /// Coins the user gets back for unlocking [item] (0 for free/owned items).
  int bonusFor(AvatarItem item) => owns(item) ? 0 : (data?.settings.bonus.bonusFor(item.coins) ?? 0);

  StudioSlot slot = StudioSlot.avatar;
  String genderFilter = 'male';
  final Map<StudioSlot, String?> draft = {};
  AvatarItem? tryOn;

  /// Bumped every time the stage look changes so the view can pop the item in.
  int stageRevision = 0;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading = true;
    failed = false;
    update();
    final d = await AvatarStudioApi.fetchStudio();
    if (d == null) {
      failed = true;
      loading = false;
      update();
      return;
    }
    data = d;
    draft
      ..clear()
      ..addAll(d.equipped);
    // First visit: hand the user a complete free starter look so the stage is never empty.
    if (draft[StudioSlot.avatar] == null) {
      final g = d.gender.toLowerCase() == 'female' ? 'female' : 'male';
      genderFilter = g;
      draft[StudioSlot.avatar] = _firstFree(StudioSlot.avatar, gender: g)?.id;
      draft[StudioSlot.background] ??= _firstFree(StudioSlot.background)?.id;
      draft[StudioSlot.pet] ??= _firstFree(StudioSlot.pet)?.id;
    } else {
      genderFilter = d.byId(draft[StudioSlot.avatar])?.gender == 'female' ? 'female' : (d.gender.toLowerCase() == 'female' ? 'female' : 'male');
    }
    loading = false;
    update();
  }

  AvatarItem? _firstFree(StudioSlot s, {String? gender}) {
    for (final i in data!.items) {
      if (i.slot == s && i.isFree && (gender == null || i.gender == 'any' || i.gender == gender)) return i;
    }
    return null;
  }

  // ------------------------------------------------------------- queries

  bool owns(AvatarItem i) => i.isFree || (data?.unlocked.contains(i.id) ?? false);

  bool isEquippedOnStage(AvatarItem i) => stageItem(i.slot)?.id == i.id;

  /// What the stage shows for a slot: the try-on wins over the draft.
  AvatarItem? stageItem(StudioSlot s) {
    if (tryOn != null && tryOn!.slot == s) return tryOn;
    return data?.byId(draft[s]);
  }

  Map<StudioSlot, AvatarItem?> get stageLook => {for (final s in StudioSlot.values) s: stageItem(s)};

  List<AvatarItem> get visibleItems {
    final d = data;
    if (d == null) return const [];
    final list = d.items.where((i) => i.slot == slot).where((i) => slot != StudioSlot.avatar || i.gender == 'any' || i.gender == genderFilter).toList();
    list.sort((a, b) {
      // Owned first is noisy while shopping; keep catalog order, but pin equipped to the front.
      final ea = isEquippedOnStage(a) ? 0 : 1, eb = isEquippedOnStage(b) ? 0 : 1;
      if (ea != eb) return ea - eb;
      return a.sortOrder.compareTo(b.sortOrder);
    });
    return list;
  }

  bool get isDirty {
    final d = data;
    if (d == null) return false;
    if (!d.active) return true;
    for (final s in StudioSlot.values) {
      if ((draft[s] ?? '') != (d.equipped[s] ?? '')) return true;
    }
    return false;
  }

  int get unlockedCount => data?.unlocked.length ?? 0;
  int get totalPremium => data?.items.where((i) => !i.isFree).length ?? 0;

  // ------------------------------------------------------------- actions

  void selectSlot(StudioSlot s) {
    if (slot == s) return;
    slot = s;
    Sfx.tick();
    update([idGrid]);
  }

  void setGender(String g) {
    if (genderFilter == g) return;
    genderFilter = g;
    Sfx.tick();
    update([idGrid]);
  }

  void tapItem(AvatarItem item) {
    if (owns(item)) {
      tryOn = null;
      final same = draft[item.slot] == item.id;
      // Avatar and scene are mandatory; companions can be taken off with a second tap.
      if (same && item.slot != StudioSlot.avatar && item.slot != StudioSlot.background) {
        draft[item.slot] = null;
        Sfx.tick();
      } else if (!same) {
        draft[item.slot] = item.id;
        Sfx.pop();
      } else {
        Sfx.tick();
      }
    } else {
      if (tryOn?.id == item.id) {
        tryOn = null;
        Sfx.tick();
      } else {
        tryOn = item;
        Sfx.pop();
      }
    }
    stageRevision++;
    update([idStage, idGrid, idBar]);
  }

  void cancelTryOn() {
    if (tryOn == null) return;
    tryOn = null;
    stageRevision++;
    Sfx.tick();
    update([idStage, idGrid, idBar]);
  }

  /// Buys the try-on item. Returns the result so the view can celebrate or
  /// route to the wallet.
  Future<StudioResult> unlockTryOn() async {
    final item = tryOn;
    if (item == null || unlocking) return const StudioResult(ok: false);
    unlocking = true;
    update([idBar]);
    final r = await AvatarStudioApi.unlock(item.id);
    unlocking = false;
    if (r.ok) {
      data!.unlocked.add(item.id);
      lastBonus = r.data?['bonus'] is num ? (r.data!['bonus'] as num).toInt() : 0;
      if (r.coins != null) _setCoins(r.coins!);
      draft[item.slot] = item.id;
      tryOn = null;
      stageRevision++;
      Sfx.unlock();
    } else {
      if (r.coins != null) _setCoins(r.coins!);
      Sfx.deny();
    }
    update([idStage, idGrid, idBar, idCoins]);
    return r;
  }

  Future<StudioResult> saveLook() async {
    if (saving || data == null) return const StudioResult(ok: false);
    saving = true;
    update([idBar]);
    final r = await AvatarStudioApi.equip(draft, active: true);
    saving = false;
    if (r.ok) {
      data!.active = true;
      for (final s in StudioSlot.values) {
        data!.equipped[s] = draft[s];
      }
      final pic = r.data?['profilePic']?.toString();
      if (pic != null && pic.isNotEmpty) {
        await Database.onSetLoginUserProfilePic(pic);
        Database.fetchLoginUserProfileModel?.user?.profilePic = pic;
        if (Get.isRegistered<EditProfileController>()) Get.find<EditProfileController>().update([Constant.idProfile]);
      }
      Sfx.select();
    } else {
      Sfx.deny();
    }
    update([idBar]);
    return r;
  }

  void _setCoins(int coins) {
    data?.coins = coins;
    Database.onSetUserCoin(coins.toString());
    if (Get.isRegistered<MyWalletController>()) Get.find<MyWalletController>().update();
  }
}

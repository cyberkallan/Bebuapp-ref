import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/bottom_sheet/talk_now_button_bottom_sheet.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:talk_in/utils/database.dart';

/// One place that knows how to open chat, calls and profiles for a listener.
///
/// Mirrors the argument lists the legacy screens pass to
/// [TalkNowButtonBottomSheet] and the chat route, so the redesigned screens
/// behave identically to the originals.
class ListenerActions {
  ListenerActions._();

  static bool get _isListener => Database.fetchLoginUserProfileModel?.user?.isListener == true;

  static String get _callerId =>
      _isListener ? Database.fetchLoginUserProfileModel?.user?.listenerId ?? '' : Database.fetchLoginUserProfileModel?.user?.id ?? '';

  static void openProfile(TopListeners l) {
    Get.toNamed(AppRoutes.profileDetailScreenView, arguments: l.id);
  }

  /// [video] may be a `List<String>` or the JSON string some APIs return; the
  /// chat controller accepts both.
  static Future<dynamic>? openChat({
    required String? id,
    required String? name,
    required String? statusLabel,
    required String? image,
    required int? ratePrivateAudioCall,
    required int? ratePrivateVideoCall,
    required bool? isFake,
    required dynamic video,
    required bool? isAvailableForPrivateVideoCall,
    required bool? isAvailableForPrivateAudioCall,
  }) {
    return Get.toNamed(
      AppRoutes.personalChatScreen,
      arguments: [
        id,
        name,
        statusLabel,
        image,
        ratePrivateAudioCall,
        ratePrivateVideoCall,
        isFake,
        video,
        isAvailableForPrivateVideoCall,
        isAvailableForPrivateAudioCall,
      ],
    );
  }

  static Future<dynamic>? openChatFor(TopListeners l) => openChat(
        id: l.id,
        name: l.name,
        statusLabel: l.statusLabel,
        image: l.image,
        ratePrivateAudioCall: l.ratePrivateAudioCall,
        ratePrivateVideoCall: l.ratePrivateVideoCall,
        isFake: l.isFake,
        video: l.video,
        isAvailableForPrivateVideoCall: l.isAvailableForPrivateVideoCall,
        isAvailableForPrivateAudioCall: l.isAvailableForPrivateAudioCall,
      );

  /// Opens the existing call chooser (audio / video / chat).
  static void openTalkNow({
    required String? id,
    required String? name,
    required String? image,
    required int? ratePrivateAudioCall,
    required int? ratePrivateVideoCall,
    required bool? isFake,
    required List<String>? video,
    required String? audio,
    required bool? isAvailableForPrivateVideoCall,
    required bool? isAvailableForPrivateAudioCall,
    VoidCallback? chatOnTap,
    bool showMessage = true,
  }) {
    Get.bottomSheet(
      TalkNowButtonBottomSheet(
        chatOnTap: chatOnTap,
        showMessage: showMessage,
        availableForPrivateAudioCall: isAvailableForPrivateAudioCall ?? false,
        availableForPrivateVideoCall: isAvailableForPrivateVideoCall ?? false,
        fakeVideo: video ?? [],
        fakeAudio: audio ?? '',
        isFake: isFake ?? false,
        videoCallRatePrivate: (ratePrivateVideoCall ?? 0).toString(),
        audioCallRatePrivate: (ratePrivateAudioCall ?? 0).toString(),
        callerId: _callerId,
        receiverId: id ?? '',
        receiverName: name ?? '',
        receiverImage: image ?? '',
        callerName: Database.fetchLoginUserProfileModel?.user?.fullName ?? '',
        callerImage: Database.fetchLoginUserProfileModel?.user?.profilePic ?? '',
        callerRole: _isListener ? 'listener' : 'user',
        receiverRole: _isListener ? 'user' : 'listener',
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  static void openTalkNowFor(TopListeners l) => openTalkNow(
        id: l.id,
        name: l.name,
        image: l.image,
        ratePrivateAudioCall: l.ratePrivateAudioCall,
        ratePrivateVideoCall: l.ratePrivateVideoCall,
        isFake: l.isFake,
        video: l.video,
        audio: l.audio,
        isAvailableForPrivateVideoCall: l.isAvailableForPrivateVideoCall,
        isAvailableForPrivateAudioCall: l.isAvailableForPrivateAudioCall,
        chatOnTap: () => openChatFor(l),
      );

  static bool canCall(TopListeners l) =>
      l.isAvailableForPrivateAudioCall == true || l.isAvailableForPrivateVideoCall == true || l.isFake == true;
}

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/utils.dart'; // Importing Random class

class FakeOutgoingCallController extends GetxController {
  late List<dynamic> args;
  bool micMute = false;
  bool isSpeakerOn = true;
  bool cameraOff = false;
  bool cameraTurn = true;
  bool remoteVideoOff = true;
  bool remoteMicMute = false;
  bool isBackProfile = false;
  int remainingSeconds = 10;

  String? receiverImage;
  String? receiverName;
  String? callType;
  List<dynamic>? videoList; // List of videos passed as arguments
  String? audio; // List of videos passed as arguments

  String? selectedVideo;

  Widget? localView;
  Widget? remoteView;
  int? remoteViewID;
  int? localViewID;

  Timer? timer;

  StreamSubscription<bool>? subsProximity;
  bool isProximitySupported = false;
  bool isObjectNear = false;

  @override
  void onInit() async {
    args = Get.arguments as List<dynamic>;

    if (args.isNotEmpty) {
      receiverName = args[0]; // name
      receiverImage = args[1]; // image
      videoList = args[2];
      audio = args[3];
      callType = args[4]; // call type (audio/video)
    }
    isProximitySupported = await ProximityScreenLock.isProximityLockSupported();
    if (isProximitySupported) {
      await ProximityScreenLock.setActive(true);
      subsProximity = ProximityScreenLock.proximityStates.listen((objectDetected) {
        isObjectNear = objectDetected;
        // Optionally, log or update UI
        Utils.showLog("Proximity object detected: $isObjectNear");
      });
    }

    Utils.showLog("fake caller name $receiverName and image $receiverImage");
    Utils.showLog("call type fake call  $callType");
    Utils.showLog("fake audio call url  $audio");
    Utils.showLog("fake videoList  url  $videoList");

    FlutterRingtonePlayer().playNotification();
    startCallTimer();
    selectRandomVideo();
    super.onInit();
  }

  void selectRandomVideo() {
    if (videoList != null && videoList!.isNotEmpty) {
      Random random = Random();
      selectedVideo = videoList![random.nextInt(videoList!.length)]; // Select a random video
      Utils.showLog("Selected random video: $selectedVideo");
    }
  }

  // void startCallTimer() {
  //   timer = Timer(Duration(seconds: 10), () {
  //     Get.back();
  //     if (callType == 'audio') {
  //       Utils.showLog("fake call type >>>>>>>>>>> $callType");
  //
  //       Get.toNamed(AppRoutes.fakeAudioCall, arguments: [receiverName, receiverImage, audio]);
  //     } else {
  //       Utils.showLog("fake call type :::::::::: $callType");
  //
  //       Get.toNamed(AppRoutes.fakeVideoCall, arguments: [selectedVideo, isBackProfile]);
  //     }
  //   });
  //
  //   FlutterRingtonePlayer().play(
  //     fromAsset: AppAsset.retroRing,
  //     ios: IosSounds.glass,
  //     looping: true,
  //     volume: 100,
  //     asAlarm: false,
  //   );
  // }

  void startCallTimer() {
    FlutterRingtonePlayer().play(
      fromAsset: AppAsset.retroRing,
      // fromAsset: "assets/audio/retro_ring_24.mp3",
      // android: AndroidSounds.ringtone,
      ios: IosSounds.glass,
      looping: true,
      volume: 100,
      asAlarm: false,
    );

    remainingSeconds = 10;

    timer = Timer.periodic(Duration(seconds: 1), (t) {
      remainingSeconds--;
      update([Constant.idVideoCall]); // Notify UI to rebuild

      if (remainingSeconds <= 0) {
        t.cancel();
        FlutterRingtonePlayer().stop();

        Get.back();

        if (callType == 'audio') {
          Utils.showLog("fake call type >>>>>>>>>>> $callType");
          Get.toNamed(AppRoutes.fakeAudioCall, arguments: [receiverName, receiverImage, audio]);
        } else {
          Utils.showLog("fake call type :::::::::: $callType");
          Get.toNamed(AppRoutes.fakeVideoCall, arguments: [selectedVideo, isBackProfile]);
        }
      }
    });
  }

  void toggleMicMute() {
    micMute = !micMute;
    update([Constant.idVideoCall]);
    Utils.showLog("outgoing audio call micMute :: $micMute");
  }

  void toggleSpeaker() {
    isSpeakerOn = !isSpeakerOn;
    update([Constant.idVideoCall]);
    Utils.showLog("outgoing audio call isSpeakerOn :: $isSpeakerOn");
  }

  @override
  void dispose() {
    Utils.showLog("fake call timer cancelled");
    subsProximity?.cancel();
    ProximityScreenLock.setActive(false);

    FlutterRingtonePlayer().stop();
    timer?.cancel();
    super.dispose();
  }

  @override
  void onClose() {
    Utils.showLog("fake call timer cancelled onClose");
    subsProximity?.cancel();
    ProximityScreenLock.setActive(false);

    FlutterRingtonePlayer().stop();
    timer?.cancel();
    super.onClose();
  }
}

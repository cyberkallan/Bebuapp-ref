import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/utils.dart';

class OutgoingCallController extends GetxController with WidgetsBindingObserver {
  late Map<String, dynamic> args;
  bool micMute = false;
  bool isSpeakerOn = true;
  bool cameraOff = false;
  bool cameraTurn = true;
  bool remoteVideoOff = true;
  bool remoteMicMute = false;

  String? callerId;
  String? receiverId;
  String? callerImage;
  String? callerName;
  String? receiverName;
  String? receiverImage;
  String? callId;
  String? receiverRole;
  String? callType;
  String? callerRole;
  String? callMode;

  Widget? localView;
  Widget? remoteView;
  int? remoteViewID;
  int? localViewID;

  Timer? timer;
  int remainingSeconds = 30;

  StreamSubscription<bool>? subsProximity;
  bool isProximitySupported = false;
  bool isObjectNear = false;

  @override
  void onInit() async {
    Utils.showLog("onInit outgoing call controller");
    args = Get.arguments as Map<String, dynamic>;
    FlutterRingtonePlayer().playNotification();

    await getDataFromArgs();
    update([Constant.idVideoCall]);
    if (Get.currentRoute == AppRoutes.outgoingCallScreen || Get.currentRoute == AppRoutes.outgoingAudioCallScreen) {
      startCallTimer();
    }

    isProximitySupported = await ProximityScreenLock.isProximityLockSupported();
    if (isProximitySupported) {
      await ProximityScreenLock.setActive(true);
      subsProximity = ProximityScreenLock.proximityStates.listen((objectDetected) {
        isObjectNear = objectDetected;
        log("Proximity object detected audio outgoing call controller: $isObjectNear");
      });
    }

    super.onInit();
  }

  int selectedStarIndex = -1;

  getDataFromArgs() {
    callerId = args['callerId'];
    receiverId = args['receiverId'];
    callerImage = args['callerImage'];
    callerName = args['callerfullName'] ?? args['callernickName'];
    receiverName = args['receiverName'];
    receiverImage = args['receiverImage'];
    callId = args['callId'];
    receiverRole = args['receiverRole'];
    callerRole = args['callerRole'];
    callType = args['callType'];
    callMode = args['callMode'];

    log("callerId :: $callerId");
    log("receiverId :: $receiverId");
    log("callerImage :: $callerImage");
    log("callerName :: $callerName");
    log("receiverName ::;;;;;;;;;;;;;;;;;;;;;; $receiverName");
    log("receiverImage  :: $receiverImage");
    log("callId :: $callId");
    log("receiverRole :: $receiverRole");
    log("callerRole :: $callerRole");
    log("callType :: $callType");
  }

  void startCallTimer() {
    FlutterRingtonePlayer().play(
      fromAsset: AppAsset.retroRing,
      ios: IosSounds.glass,
      looping: true,
      volume: 100,
      asAlarm: false,
    );

    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        update();
      } else {
        t.cancel();
        emitCallTerminated();
      }
    });
  }

  void emitCallTerminated() {
    if (callerId != null && receiverId != null && callId != null && callType != null && callMode != null) {
      SocketEmit.emitCallerCallCut(
        callerId: callerId!,
        receiverId: receiverId!,
        callId: callId!,
        callType: callType!,
        callMode: callMode!,
        callerRole: callerRole ?? '',
        receiverRole: receiverRole ?? '',
      );
      log("Call Terminated Event Emitted");

      // Navigate back or end the call screen
      Get.back();
    }
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
    log("timer cancelled");
    FlutterRingtonePlayer().stop();

    subsProximity?.cancel();
    ProximityScreenLock.setActive(false);
    log("Proximity object detected audio outgoing call controller dispose : $isObjectNear");

    timer?.cancel();
    super.dispose();
  }

  @override
  void onClose() {
    log("timer cancelled onClose");
    FlutterRingtonePlayer().stop();
    subsProximity?.cancel();
    ProximityScreenLock.setActive(false);
    log("Proximity object detected audio outgoing call controller on close : $isObjectNear");

    timer?.cancel();
    super.onClose();
  }
}

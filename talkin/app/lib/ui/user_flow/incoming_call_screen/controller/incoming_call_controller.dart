import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/utils.dart';
import 'package:vibration/vibration.dart';

class IncomingCallController extends GetxController with WidgetsBindingObserver {
  late Map<String, dynamic> args;

  String? callerId;
  String? receiverId;
  String? callerImage;
  String? callerName;
  String? receiverName;
  String? receiverImage;
  String? callId;
  String? receiverRole;
  String? callType;
  String? callMode;
  String? callerRole;

  bool isCallResponse = false;
  AudioPlayer audioPlayer = AudioPlayer();
  Timer? vibrationTimer;
  Timer? ringingTimer;

  @override
  void onInit() async {
    args = Get.arguments as Map<String, dynamic>;
    getDataFromArgs();

    onStartVibration();
    onPlayAudio();
    onStartRingingTimer();
    WidgetsBinding.instance.addObserver(this);
    super.onInit();
  }

  @override
  void onClose() {
    vibrationTimer?.cancel();
    ringingTimer?.cancel();
    onPauseAudio();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  getDataFromArgs() {
    // Access map keys instead of list indices
    callerId = args['callerId'];
    receiverId = args['receiverId'];
    callerImage = args['callerImage'];
    callerName = args['callerfullName'] ?? args['callernickName']; // use fullName or nickName
    receiverName = args['receiverName'];
    receiverImage = args['receiverImage'];
    callId = args['callId'];
    receiverRole = args['receiverRole'];
    callMode = args['callMode'];
    callType = args['callType'];
    callerRole = args['callerRole'];

    log("callerId :: $callerId");
    log("receiverId :: $receiverId");
    log("callerImage :: $callerImage");
    log("callerName :: $callerName");
    log("receiverName :: $receiverName");
    log("receiverImage $receiverImage");
    log("callId :: $callId");
    log("receiverRole :: $receiverRole");
    log("callMode :: $callMode");
    log("callType :: $callType");
    log("callerRole :: $callerRole");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Utils.showLog("User Back To App...");
    }
    if (state == AppLifecycleState.inactive) {
      Utils.showLog("User Try To Exit...");
    }
  }

  void onStartVibration() {
    vibrationTimer = Timer.periodic(Duration(milliseconds: 500), (timer) => Vibration.vibrate(duration: 150, amplitude: 150));
  }

  void onPlayAudio() async {
    try {
      await audioPlayer.play(AssetSource(AppAsset.ringTone));
    } catch (e) {
      Utils.showLog("Audio Play Failed !! => $e");
    }
  }

  void onPauseAudio() {
    try {
      audioPlayer.pause();
    } catch (e) {
      Utils.showLog("Audio Pause Error => $e");
    }
  }

  void onStartRingingTimer() async {
    ringingTimer = Timer(
      Duration(seconds: 30),
      () {
        if (Get.currentRoute == AppRoutes.incomingCallScreen) {
          Utils.showLog("Call Auto Decline Success");
          onCallDecline();
          Get.back();
        }
        Utils.showLog("Start Ringing Timer => Back To Incoming Call");
      },
    );
  }

  Future<void> onCallDecline() async {
    Vibration.vibrate(duration: 50, amplitude: 128);
    await 50.milliseconds.delay();
    if (isCallResponse == false) {
      isCallResponse = true;
      if (isCallResponse == false) {
        isCallResponse = true;
        if (callerRole == "user") {
          SocketEmit.emitCallResponseProcessed(
            callerId: callerId ?? '',
            receiverId: receiverId ?? '',
            callId: callId ?? '',
            isAccept: false,
            callType: callType ?? '',
            callMode: callMode ?? '',
            callerRole: 'user',
            receiverRole: 'listener',
            receiverName: receiverName ?? '',
            receiverImage: receiverImage ?? '',
            callerName: callerName ?? '',
            callerImage: callerImage ?? '',
          );
          // Optionally, navigate or update UI here immediately
          Utils.showLog("Call decline , emit event sent");
        } else {
          SocketEmit.emitCallResponseProcessed(
            callerId: callerId ?? '',
            receiverId: receiverId ?? '',
            callId: callId ?? '',
            isAccept: false,
            callType: callType ?? '',
            callMode: callMode ?? '',
            callerRole: 'listener',
            receiverRole: 'user',
            receiverName: receiverName ?? '',
            receiverImage: receiverImage ?? '',
            callerName: callerName ?? '',
            callerImage: callerImage ?? '',
          );
        }
      }
    }
  }
}

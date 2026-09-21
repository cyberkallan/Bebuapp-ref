import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class VoiceCallController extends GetxController {
  dynamic args = Get.arguments;
  bool micMute = true;
  bool cameraOff = true;
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
  String? callMode;
  String? callerRole;

  Timer? timer;
  DateTime? startTime;
  DateTime? endTime;
  Duration? duration;
  int? minutes;
  int? seconds;
  String? finalDuration;
  String? formattedTime;

  Widget? localView;
  Widget? remoteView;
  int? remoteViewID;
  int? localViewID;
  bool isSpeakerOn = false;
  bool isMicMute = false;
  // bool isSpeakerOn = Get.arguments["speakerOn"] ?? "";
  // bool isMicMute = Get.arguments["micMute"] ?? "";

  StreamSubscription<bool>? subsProximity;
  bool isProximitySupported = false;
  bool isObjectNear = false;
  bool userEnabledSpeaker = false; // Only true if user taps speaker button

  @override
  void onInit() async {
    Utils.showLog("onInit voice call controller");

    args = Get.arguments as Map<String, dynamic>;

    ZegoExpressEngine.instance.muteMicrophone(isMicMute);
    ZegoExpressEngine.instance.setAudioRouteToSpeaker(isSpeakerOn);

    getDataFromArgs();
    await createEngine();
    startListenEvent();
    await loginRoom();

    // ✅ Default speaker ON (and mark that "user preference" is ON)
    isSpeakerOn = true;
    userEnabledSpeaker = true;
    await ZegoExpressEngine.instance.setAudioRouteToSpeaker(true);

    startTimer();

    // ✅ Proximity hookup
    isProximitySupported = await ProximityScreenLock.isProximityLockSupported();
    if (isProximitySupported) {
      await ProximityScreenLock.setActive(true);
      subsProximity = ProximityScreenLock.proximityStates.listen(
        _onProximityChanged,
        onError: (e) => log("Proximity stream error: $e"),
        cancelOnError: true,
      );
    }

    super.onInit();
  }

  int selectedStarIndex = -1;

  void _onProximityChanged(bool objectDetected) {
    isObjectNear = objectDetected;
    log("🔥 Proximity voice call screen controller: $objectDetected");

    if (objectDetected) {
      // Object near → Speaker OFF
      if (isSpeakerOn) {
        isSpeakerOn = false;
        userEnabledSpeaker = false;
        ZegoExpressEngine.instance.setAudioRouteToSpeaker(false);
        update([Constant.idSpeakerOpen, Constant.idVideoCall]);
      }
    } else {
      // Object away → Speaker restore (only if user had enabled)
      if (userEnabledSpeaker) {
        isSpeakerOn = true;
        ZegoExpressEngine.instance.setAudioRouteToSpeaker(true);
        update([Constant.idSpeakerOpen, Constant.idVideoCall]);
      }
    }
  }

  getDataFromArgs() {
    if (Get.arguments != null) {
      callId = Get.arguments["callId"] ?? "";
      callerId = Get.arguments["callerId"] ?? "";
      receiverId = Get.arguments["receiverId"] ?? "";
      receiverName = Get.arguments["receiverName"] ?? "";
      receiverImage = Get.arguments["receiverImage"] ?? "";
      callerName = Get.arguments["callerfullName"] ?? "";
      callerImage = Get.arguments["callerImage"] ?? "";
      callType = Get.arguments["callType"] ?? "";
      callMode = Get.arguments["callMode"] ?? "";
      callerRole = Get.arguments["callerRole"] ?? "";
      receiverRole = Get.arguments["receiverRole"] ?? "";
      // isMicMute = Get.arguments["micMute"] ?? "";
      // isSpeakerOn = Get.arguments["speakerOn"] ?? "";
    }

    log("callId ::$callId");
    log("callerId ::$callerId");
    log("receiverId ::$receiverId");
    log("receiverName ::$receiverName");
    log("receiverImage ::$receiverImage");
    log("callerName ::$callerName");
    log("callerImage ::$callerImage");
    log("callType ::$callType");
    log("callMode ::$callMode");
    log("callerRole ::$callerRole");
    log("receiverRole ::$receiverRole");
    log("isSpeakerOn ::$isSpeakerOn");
    log("isMicMute ::$isMicMute");
  }

  void startTimer() {
    startTime = DateTime.now();
    int elapsedSeconds = 0;
    coinCutEveryOneMinute();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedSeconds++;

      final minutes = elapsedSeconds ~/ 60;
      final seconds = elapsedSeconds % 60;

      formattedTime = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      log('Start timer :: $formattedTime');

      /// Every 60 seconds emit the coin deduction event
      if (elapsedSeconds % 60 == 0) {
        coinCutEveryOneMinute();
      }

      update([Constant.idVideoCall]);
    });
  }

  void stopTimer() {
    endTime = DateTime.now();
    timer?.cancel();
    timer = null;

    duration = endTime?.difference(startTime!);
    minutes = duration?.inMinutes.remainder(60);
    seconds = duration?.inSeconds.remainder(60);
    finalDuration = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    log('Call Duration :: $duration');
    log('Final Duration :: $finalDuration');
  }

  void coinCutEveryOneMinute() {
    if (callerId == Database.loginUserId) {
      SocketEmit.callCoinsDeducted(
        callerId: callerId.toString(),
        receiverId: receiverId.toString(),
        callId: callId.toString(),
        callType: callType.toString(),
        callMode: callMode.toString(),
        callerRole: callerRole.toString(),
        receiverRole: receiverRole.toString(),
      );

      return;
    }
  }

  onMicMute() {
    log("Mic Mute: $isMicMute");

    isMicMute = !isMicMute;
    ZegoExpressEngine.instance.muteMicrophone(isMicMute);

    update([Constant.idMicMute, Constant.idVideoCall]);
  }

  // void onSpeakerOn() {
  //   userEnabledSpeaker = true; // User manually enabled speaker
  //   isSpeakerOn = !isSpeakerOn;
  //   ZegoExpressEngine.instance.setAudioRouteToSpeaker(isSpeakerOn);
  //   log("🔊 Speaker turned ON by user");
  //   update([Constant.idSpeakerOpen, Constant.idVideoCall]);
  // }
  void onSpeakerOn() {
    if (isObjectNear) {
      return;
    }

    isSpeakerOn = !isSpeakerOn;
    userEnabledSpeaker = isSpeakerOn;
    ZegoExpressEngine.instance.setAudioRouteToSpeaker(isSpeakerOn);
    log("🔊 Speaker toggled by user: $isSpeakerOn");
    update([Constant.idSpeakerOpen, Constant.idVideoCall]);
  }

  Future<void> createEngine() async {
    log("Voice Call Create Engine");
    final appId = int.tryParse(Database.settingApiModel?.data?.zegoAppId?.toString() ?? '');
    final appSign = Database.settingApiModel?.data?.zegoAppSignIn?.toString();

    await ZegoExpressEngine.createEngineWithProfile(ZegoEngineProfile(
      appId ?? 0,
      // 1733802087,
      ZegoScenario.Default,
      appSign: kIsWeb ? null : appSign,
      // appSign: kIsWeb ? null : "4305690f3b56bea1ed5528d90f664a0e1272cf37211b75f7351ac9c22f2e235f",
    ));
  }

  void startListenEvent() {
    Constant.storage.write("isVideoCall", true);

    ZegoExpressEngine.onRoomUserUpdate = (roomID, updateType, List<ZegoUser> userList) {
      log('onRoomUserUpdate: roomID: $roomID, updateType: ${updateType.name}, userList: ${userList.map((e) => e.userID)}');
    };

    ZegoExpressEngine.onRemoteCameraStateUpdate = (streamID, state) {
      log("Camera is :: $state");

      if (state == ZegoRemoteDeviceState.Open) {
        remoteVideoOff = true;
      } else {
        remoteVideoOff = false;
      }
      update([Constant.idVideoCall]);
    };

    ZegoExpressEngine.onRemoteMicStateUpdate = (streamID, state) {
      log("Mic Mute is :: $state");

      if (state == ZegoRemoteDeviceState.Mute) {
        remoteMicMute = true;
      } else {
        remoteMicMute = false;
      }
      update([Constant.idVideoCall]);
    };

    ZegoExpressEngine.onRoomStreamUpdate = (roomID, updateType, List<ZegoStream> streamList, extendedData) {
      log('onRoomStreamUpdate: roomID: $roomID, updateType: $updateType, streamList: ${streamList.map((e) => e.streamID)}, extendedData: $extendedData');
      if (updateType == ZegoUpdateType.Add) {
        for (final stream in streamList) {
          startPlayStream(stream.streamID);
        }
      } else {
        for (final stream in streamList) {
          stopPlayStream(stream.streamID);
        }
      }
    };

    ZegoExpressEngine.onRoomStateUpdate = (roomID, state, errorCode, extendedData) {
      log('onRoomStateUpdate: roomID: $roomID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData');
    };

    ZegoExpressEngine.onPublisherStateUpdate = (streamID, state, errorCode, extendedData) {
      log('onPublisherStateUpdate: streamID: $streamID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData');
    };
  }

  void stopListenEvent() {
    log("Enter in stop listen event");
    Constant.storage.write("isVideoCall", false);

    ZegoExpressEngine.onRoomUserUpdate = null;
    ZegoExpressEngine.onRoomStreamUpdate = null;
    ZegoExpressEngine.onRoomStateUpdate = (roomID, state, errorCode, extendedData) {
      if (state == ZegoRoomState.Disconnected) {
        ZegoExpressEngine.instance.muteMicrophone(false);
        ZegoExpressEngine.instance.enableCamera(true);
        ZegoExpressEngine.instance.useFrontCamera(true);

        stopTimer();
      }
    };
    ZegoExpressEngine.onPublisherStateUpdate = null;
  }

  Future<void> startPlayStream(String streamID) async {
    await ZegoExpressEngine.instance.createCanvasView((viewID) {
      remoteViewID = viewID;
      ZegoCanvas canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
      ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
      log("Stream started playing for: $streamID");
    }).then((canvasViewWidget) {
      remoteView = canvasViewWidget;
      update([Constant.idVideoCall]);
    });
  }

  Future<void> stopPlayStream(String streamID) async {
    ZegoExpressEngine.instance.stopPlayingStream(streamID);
    if (remoteViewID != null) {
      ZegoExpressEngine.instance.destroyCanvasView(remoteViewID!);

      /// setState
      remoteViewID = null;
      remoteView = null;
      update([Constant.idVideoCall]);
    }
  }

  Future<ZegoRoomLoginResult> loginRoom() async {
    // await logoutRoom();
    final user = ZegoUser(
      Database.fetchLoginUserProfileModel?.user?.isListener == true ? Database.fetchLoginUserProfileModel?.user?.listenerId : Database.loginUserId,
      Database.loginUserName,
    );
    final roomID = callId;

    ZegoRoomConfig roomConfig = ZegoRoomConfig.defaultConfig()..isUserStatusNotify = true;

    return ZegoExpressEngine.instance.loginRoom(roomID!, user, config: roomConfig).then((ZegoRoomLoginResult loginRoomResult) {
      log('loginRoom: errorCode:${loginRoomResult.errorCode}, extendedData:${loginRoomResult.extendedData}');
      if (loginRoomResult.errorCode == 0) {
        startPreview();
        startPublish();
      } else {
        log("Login Room Failed Status Code :: ${loginRoomResult.errorCode}");
      }
      return loginRoomResult;
    });
  }

  Future<ZegoRoomLogoutResult> logoutRoom() async {
    stopPreview();
    stopPublish();
    return ZegoExpressEngine.instance.logoutRoom(callId);
  }

  Future<void> startPreview() async {
    await ZegoExpressEngine.instance.createCanvasView((viewID) {
      localViewID = viewID;
      ZegoCanvas previewCanvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
      ZegoExpressEngine.instance.startPreview(canvas: previewCanvas);
    }).then((canvasViewWidget) {
      ///SetState
      localView = canvasViewWidget;
      update([Constant.idVideoCall]);
    });
  }

  Future<void> stopPreview() async {
    ZegoExpressEngine.instance.stopPreview();
    if (localViewID != null) {
      await ZegoExpressEngine.instance.destroyCanvasView(localViewID!);

      ///setState
      localViewID = null;
      localView = null;
      update([Constant.idVideoCall]);
    }
  }

  Future<void> startPublish() async {
    String streamID = '${callId}_${Database.loginUserId}_call';

    return ZegoExpressEngine.instance.startPublishingStream(streamID);
  }

  Future<void> stopPublish() async {
    return ZegoExpressEngine.instance.stopPublishingStream();
  }

  void endCallDueToBackground() {
    log("endCallDueToBackground");
    SocketEmit.emitCallTerminated(
      callerId: callerId ?? '',
      receiverId: receiverId ?? '',
      callId: callId ?? '',
      callType: callType ?? '',
      callMode: callMode ?? '',
      callerRole: callerRole ?? '',
      receiverRole: receiverRole ?? '',
      receiverImage: receiverImage ?? '',
      receiverName: receiverName ?? '',
    );
    // Get.back(); // or navigate to a call ended screen
  }

  senseProximity() async {
    Utils.showLog("111111111111111111111111");
    isProximitySupported = await ProximityScreenLock.isProximityLockSupported();
    Utils.showLog("2222222222222222222222222");

    if (isProximitySupported) {
      Utils.showLog("3333333333333333333333333333333");

      await ProximityScreenLock.setActive(true);
      Utils.showLog("444444444444444444444444444444");

      Utils.showLog("5555555555555555555555555555555555555");

      subsProximity = ProximityScreenLock.proximityStates.listen(
        (objectDetected) {
          log("🔥 Proximity detected on CALLER: $objectDetected");
          isObjectNear = objectDetected;

          if (objectDetected && isSpeakerOn) {
            isSpeakerOn = false;
            ZegoExpressEngine.instance.setAudioRouteToSpeaker(false);
            update([Constant.idSpeakerOpen, Constant.idVideoCall]);
          }
        },
        onError: (error) {
          log("❌ Proximity Stream Error: $error");
        },
        onDone: () {
          log("❌ Proximity Stream Closed");
        },
        cancelOnError: true,
      );
    }
  }

  // @override
  // void onClose() {
  //   stopListenEvent();
  //
  //   logoutRoom();
  //
  //   stopTimer();
  //   subsProximity?.cancel();
  //   ProximityScreenLock.setActive(false);
  //   isProximitySupported = false;
  //   isObjectNear = false;
  //   log("Proximity object detected audio/voice call controller dispose : $isObjectNear");
  //
  //   super.onClose();
  // }
  @override
  void onClose() {
    log("onClose");
    stopListenEvent();
    logoutRoom();
    stopTimer();

    // ✅ Properly cleanup proximity sensor
    subsProximity?.cancel();
    subsProximity = null;

    // ✅ Force deactivate proximity sensor and unlock screen
    _cleanupProximitySensor();

    super.onClose();
  }

// ✅ Add this helper method to properly cleanup proximity sensor
  Future<void> _cleanupProximitySensor() async {
    log("✅ Cleaning up proximity sensor");
    ProximityScreenLock.proximityStates.listen((objectDetected) async {
      print(objectDetected ? 'Object detected' : 'No object detected');
    });
    try {
      await ProximityScreenLock.setActive(false);
      log("✅ Proximity sensor deactivated in onClose");
      ProximityScreenLock.proximityStates.listen((objectDetected) async {
        print(objectDetected ? 'Object detected' : 'No object detected');
      });
      // if (isProximitySupported) {
      //   await ProximityScreenLock.setActive(false);
      //   log("✅ Proximity sensor deactivated in onClose");
      // }

      isProximitySupported = false;
      isObjectNear = false;
      userEnabledSpeaker = false;

      log("✅ Proximity cleanup completed");
    } catch (e) {
      log("❌ Error cleaning up proximity sensor: $e");
    }
  }
}

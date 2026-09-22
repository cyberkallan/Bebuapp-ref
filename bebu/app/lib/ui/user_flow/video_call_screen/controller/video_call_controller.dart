import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/ui/host_flow/host_home_screen/api/host_coin_api.dart';
import 'package:talk_in/ui/host_flow/host_home_screen/model/listener_coin_model.dart';
import 'package:talk_in/ui/user_flow/home_screen/api/user_coin_api.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/user_coin_model.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/model/fetch_coin_plan.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class VideoCallController extends GetxController {
  List<CoinPlan> coinPlan = [];

  late Map<String, dynamic> args;

  bool cameraTurn = true;

  bool micMute = false;
  bool isCameraOff = false;

  bool remoteVideoOff = false;
  bool remoteMicMute = false;

  String? callId;
  String? callerImage;
  String? callerName;
  String? receiverName;
  String? receiverImage;
  String? designation;
  String? callerId;
  String? receiverId;
  String? callType;
  String? callMode;
  String? callerRole;
  String? receiverRole;

  int countTime = 0;

  Timer? timer;
  DateTime? startTime;
  DateTime? endTime;
  Duration? duration;
  int? minutes;
  int? seconds;
  String? finalDuration;
  String? formattedTime = "00:00";

  Widget? localView;
  Widget? remoteView;
  int? remoteViewID;
  int? localViewID;
  UserCoinModel? userCoinModel;
  ListenerCoinModel? listenerCoinModel;

  @override
  void onInit() async {
    args = Get.arguments as Map<String, dynamic>;
    getDataFromArgs();
    createEngine().then((_) {
      startListenEvent();
      loginRoom();
      startTimer();
    });
    userCoinModel = await UserCoinApi.callApi();
    Database.onSetUserCoin(userCoinModel?.coin.toString() ?? "0");
    update([Constant.idCoinUpdate]);

    listenerCoinModel = await HostCoinApi.callApi();
    Database.onSetListenerCoin(listenerCoinModel!.coin.toString());

    super.onInit();
  }

  @override
  void onClose() {
    log("video call controller close");
    stopListenEvent();

    logoutRoom();

    stopTimer();
    super.onClose();
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
    }

    log("callId ::$callId");
    log("callerId ::$callerId");
    log("receiverId ::$receiverId");
    log("receiverName ::$receiverName");
    log("receiverImage ::$receiverImage");
    log("callerName ::$callerName");
    log("callerImage ::$callerImage");
    log("callType ::$callType");
    log("callType ::$callMode");
    log("callerRole ::$callerRole");
    log("receiverRole ::$receiverRole");
    log("callMode ::$callMode");
  }

  Future<void> startTimer() async {
    startTime = DateTime.now();
    int elapsedSeconds = 0;

    coinCutEveryOneMinute();
    if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
      listenerCoinModel = await HostCoinApi.callApi();
      Database.onSetListenerCoin(listenerCoinModel!.coin.toString());
    } else {
      userCoinModel = await UserCoinApi.callApi();
      Database.onSetUserCoin(userCoinModel?.coin.toString() ?? "0");
      update([Constant.idCoinUpdate]);
    }

    update();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      elapsedSeconds++;

      final minutes = elapsedSeconds ~/ 60;
      final seconds = elapsedSeconds % 60;

      formattedTime = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      log('Start timer :: $formattedTime');

      /// Every 60 seconds emit the coin deduction event
      if (elapsedSeconds % 60 == 0) {
        coinCutEveryOneMinute();

        if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
          listenerCoinModel = await HostCoinApi.callApi();
          Database.onSetListenerCoin(listenerCoinModel!.coin.toString());
        } else {
          userCoinModel = await UserCoinApi.callApi();
          Database.onSetUserCoin(userCoinModel?.coin.toString() ?? "0");
        }

        log("user coin saved database  ${Database.userCoin}");
        log("listener coin saved database  ${Database.listenerCoin}");
        update();
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

  onMicMute() {
    micMute = !micMute;
    ZegoExpressEngine.instance.muteMicrophone(micMute);

    update([Constant.idMicMute, Constant.idVideoCall]);
  }

  onCameraOff() {
    Utils.showLog("***before******* $isCameraOff");

    if (isCameraOff) {
      ZegoExpressEngine.instance.enableCamera(true);
      isCameraOff = false;
    } else {
      ZegoExpressEngine.instance.enableCamera(false);
      isCameraOff = true;
    }

    Utils.showLog("****after****** $isCameraOff");

    update([Constant.idVideoTurn, Constant.idVideoCall]);
  }

  onCameraTurn() {
    cameraTurn = !cameraTurn;

    ZegoExpressEngine.instance.useFrontCamera(cameraTurn);
    update([Constant.idCameraTurn, Constant.idVideoCall]);
    // update();
  }

  Future<void> createEngine() async {
    final appId = int.tryParse(Database.settingApiModel?.data?.zegoAppId?.toString() ?? '');
    final appSign = Database.settingApiModel?.data?.zegoAppSignIn?.toString();

    await ZegoExpressEngine.createEngineWithProfile(ZegoEngineProfile(
      appId ?? 0,
      ZegoScenario.Default,
      appSign: kIsWeb ? null : appSign,
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
        remoteVideoOff = false;
      } else {
        remoteVideoOff = true;
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
    await logoutRoom();
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
    // ZegoExpressEngine.instance.stopPreview();
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

  void coinCutEveryOneMinute() async {
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

      update();
      return;
    }
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
}

import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/socket/socket_service.dart';
import 'package:talk_in/ui/host_flow/host_home_screen/api/host_coin_api.dart';
import 'package:talk_in/ui/host_flow/host_home_screen/controller/host_home_screen_controller.dart';
import 'package:talk_in/ui/host_flow/host_home_screen/model/listener_coin_model.dart';
import 'package:talk_in/ui/host_flow/host_personal_chat_screen/controller/host_personal_chat_screen_controller.dart';
import 'package:talk_in/ui/host_flow/host_personal_chat_screen/model/host_personal_chat_model.dart';
import 'package:talk_in/ui/user_flow/call_cut_screen/controller/call_cut_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/api/user_coin_api.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/user_coin_model.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/controller/personal_chat_screen_controller.dart';
import 'package:talk_in/ui/user_flow/video_call_screen/controller/video_call_controller.dart';
import 'package:talk_in/ui/user_flow/voice_call_screen/controller/voice_call_controller.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/socket_events.dart';
import 'package:talk_in/utils/socket_params.dart';
import 'package:talk_in/utils/utils.dart';

class SocketListen {
  static final Map<String, String> _latestMessageIdPerChat = {};
  static Timer? _seenEmitTimer;

  /// Binds every app-level handler to the current socket. Safe to call any
  /// number of times: each event is unbound first, so a re-created bottom bar
  /// (login, role switch, returning from a call) never doubles messages.
  static void registerListeners() {
    if (socket == null) return;
    _bindAll();
    // Re-bind after `socketConnect()` builds a new socket instance.
    SocketService.onConnected(_bindAll);
  }

  static void _bindAll() {
    final s = socket;
    if (s == null) return;
    Utils.showLog("Socket: binding listeners on ${s.id ?? 'pending'}");

    void bind(String event, dynamic Function(dynamic) handler) {
      s.off(event);
      s.on(event, handler);
    }

    bind(SocketEvents.sendMessage, handleSendMessage);
    bind(SocketEvents.markMessageSeen, handleMarkMessageSeen);

    bind(SocketEvents.callOutgoingRinging, handleCallOutgoingRinging);
    bind(SocketEvents.outGoingCall, handleOutGoingCall);
    bind(SocketEvents.incomingCall, handleIncomingCall);

    bind(SocketEvents.callResponseProcessed, handleCallResponseProcessed);
    bind(SocketEvents.callDeclined, handleCallDeclined);
    bind(SocketEvents.callAnswered, handleCallAnswered);
    bind(SocketEvents.callTimedOut, handleCallTimedOut);
    bind(SocketEvents.callEnded, handleCallEnded);
    bind(SocketEvents.callerCallCut, handleCallRejected);
    bind(SocketEvents.callTerminated, handleCallTerminated);
    bind(SocketEvents.randomCallRinging, handleRandomCallRinging);
    bind(SocketEvents.notEnoughCoins, handleNotEnoughCoins);
    bind(SocketEvents.callCoinsDeducted, handleCallCoinsDeducted);
    bind(SocketEvents.callCutData, handleCallCutData);
  }

  static void handleSendMessage(dynamic message) {
    Utils.showLog("Received messageDispatched: $message");

    try {
      final Map<String, dynamic> data = Map<String, dynamic>.from(message['data'] as Map);
      final String chatTopicId = data['chatTopicId'] ?? '';

      if (Get.isRegistered<HostPersonalChatScreenController>()) {
        final hostController = Get.find<HostPersonalChatScreenController>();
        if (chatTopicId == hostController.chatTopicId) {
          final newMsg = ListenerChat.fromJson(data);

          if (data["senderId"] == Database.fetchListenerProfileModel?.data?.id && data['messageType'] == 3) {
            hostController.oldChatListener.removeAt(0);
          }

          hostController.isLoadingAudio = false;
          hostController.update([Constant.idGetOldChat]);

          // hostController.oldChatListener.insert(0, newMsg);
          // Try to find and replace the optimistic message
          final index = hostController.oldChatListener.indexWhere(
              (msg) => msg.senderId == Database.loginUserId && msg.message == newMsg.message && msg.id?.length == 13 // temporary ID is a timestamp
              );

          if (index != -1) {
            hostController.oldChatListener[index] = newMsg;
          } else {
            hostController.oldChatListener.insert(0, newMsg);
          }

          hostController.onScrollDown();
          hostController.update([Constant.idGetOldChat]);

          if (Get.currentRoute == AppRoutes.hostPersonalChatScreen || Get.currentRoute == AppRoutes.personalChatScreen) {
            final String messageId = message['messageId']?.toString() ?? '';

            if (data["senderId"] != Database.fetchListenerProfileModel?.data?.id &&
                data['receiverId'] == Database.fetchListenerProfileModel?.data?.id) {
              // Future.delayed(const Duration(seconds: 1), () {
              //   Utils.showLog("Message seen event");
              //   SocketEmit.onMessageSeen({
              //     SocketParams.messageId: messageId,
              //     SocketParams.senderId: data["senderId"],
              //   });
              // });

              _latestMessageIdPerChat[chatTopicId] = messageId;

// Cancel previous timer if running
              _seenEmitTimer?.cancel();

// Start a new short timer to emit only once after all messages received
              _seenEmitTimer = Timer(const Duration(milliseconds: 500), () {
                final latestMsgId = _latestMessageIdPerChat[chatTopicId];
                if (latestMsgId != null) {
                  Utils.showLog("🔥 Emitting seen for last messageId: $latestMsgId");

                  SocketEmit.onMessageSeen({
                    SocketParams.messageId: latestMsgId,
                    SocketParams.senderId: data["senderId"],
                  });

                  _latestMessageIdPerChat.remove(chatTopicId); // Clear after use
                }
              });
            } else {
              Utils.showLog("Message not for current user");
            }
          }
          return;
        }
      }

      if (Get.isRegistered<PersonalChatScreenController>()) {
        final userController = Get.find<PersonalChatScreenController>();
        if (chatTopicId == userController.chatTopicId) {
          userController.onSocketMessage(data, message['messageId']?.toString());

          if (Get.currentRoute == AppRoutes.hostPersonalChatScreen || Get.currentRoute == AppRoutes.personalChatScreen) {
            final String messageId = message['messageId']?.toString() ?? '';

            if (data["senderId"] != Database.fetchLoginUserProfileModel?.user?.id &&
                data['receiverId'] == Database.fetchLoginUserProfileModel?.user?.id) {
              // Future.delayed(const Duration(seconds: 1), () {
              //   SocketEmit.onMessageSeen({
              //     SocketParams.messageId: messageId,
              //     SocketParams.senderId: data["senderId"],
              //   });
              // });

              _latestMessageIdPerChat[chatTopicId] = messageId;

// Cancel previous timer if running
              _seenEmitTimer?.cancel();

// Start a new short timer to emit only once after all messages received
              _seenEmitTimer = Timer(const Duration(milliseconds: 500), () {
                final latestMsgId = _latestMessageIdPerChat[chatTopicId];
                if (latestMsgId != null) {
                  Utils.showLog("🔥 Emitting seen for last messageId: $latestMsgId");

                  SocketEmit.onMessageSeen({
                    SocketParams.messageId: latestMsgId,
                    SocketParams.senderId: data["senderId"],
                  });

                  _latestMessageIdPerChat.remove(chatTopicId); // Clear after use
                }
              });
            } else {
              Utils.showLog("Message not for current user");
            }
          }

          return;
        }
      }

      Utils.showLog(" Message not for current chat topic");
    } catch (e) {
      Utils.showLog(" Error parsing socket message: $e");
    }
  }

  static void handleMarkMessageSeen(dynamic data) {
    Utils.showLog("Received markMessageSeen: $data");
/*
    if (Get.isRegistered<HostPersonalChatScreenController>()) {
      final hostController = Get.find<HostPersonalChatScreenController>();
      Utils.showLog("hostController.isMsgSeen111: ${hostController.isMsgSeen}");
      hostController.isMsgSeen = true;
      Utils.showLog("hostController.isMsgSeen222: ${hostController.isMsgSeen}");

      hostController.update();
      Utils.showLog("hostController.isMsgSeen33: ${hostController.isMsgSeen}");
    }
    if (Get.isRegistered<PersonalChatScreenController>()) {
      final Controller = Get.find<PersonalChatScreenController>();
      Utils.showLog("hostController.isMsgSeen111: ${Controller.isMsgSeen}");
      Controller.isMsgSeen = true;
      Utils.showLog("hostController.isMsgSeen222: ${Controller.isMsgSeen}");

      Controller.update();
      Utils.showLog("hostController.isMsgSeen33: ${Controller.isMsgSeen}");
    }
*/
  }

  // static void handleMarkMessageSeen(dynamic data) {
  //   Utils.showLog("Received markMessageSeen: $data");
  //
  //   try {
  //     final parsed = jsonDecode(data);
  //     final messageId = parsed['messageId'];
  //
  //     if (Get.isRegistered<PersonalChatScreenController>()) {
  //       final controller = Get.find<PersonalChatScreenController>();
  //
  //       for (var msg in controller.oldChat) {
  //         if (msg.senderId == Database.loginUserId) {
  //           msg.isRead = true;
  //         }
  //       }
  //
  //       controller.update([Constant.idGetOldChat]);
  //     }
  //   } catch (e) {
  //     Utils.showLog("Error in markMessageSeen handler: $e");
  //   }
  // }

  /// when caller call then caller this event listen
  static void handleOutGoingCall(dynamic data) {
    Get.back();
    Utils.showLog("Socket Listen => callEstablished event: $data");
    if (data['callType'] == "audio") {
      Get.toNamed(AppRoutes.outgoingAudioCallScreen, arguments: data);
    } else {
      Get.toNamed(AppRoutes.outgoingCallScreen, arguments: data);
    }
  }

  /// when caller call then receiver this event listen
  static Future<void> handleIncomingCall(dynamic data) async {
    Utils.showLog("Socket Listen => incomingCall event: $data");

    Get.toNamed(AppRoutes.incomingCallScreen, arguments: data);
  }

  /// If any error like busy, caller or receiver not found then listen always in callOutgoingRinging event
  static void handleCallOutgoingRinging(dynamic data) {
    Utils.showLog("Socket Listen => callOutgoingRinging (error or status): $data");
    // Get.back();
    Utils.showToast(Get.context!, data['message']);
  }

  /// receiver call cut listen this event
  static void handleCallDeclined(dynamic data) {
    Utils.showLog("Socket Listen => callDeclined event: $data");
    if (Get.currentRoute == AppRoutes.outgoingCallScreen ||
        Get.currentRoute == AppRoutes.incomingCallScreen ||
        Get.currentRoute == AppRoutes.outgoingAudioCallScreen) {
      log(" <<<<<<<<<<<<<<<<<<<<<<<<< ${Get.currentRoute}");
      Get.back();
    }
  }

  /// caller call and receiver call answer then this event listen
  static void handleCallAnswered(dynamic data) {
    Utils.showLog("Socket Listen => callAnswered event: $data");
    Get.back();

    // Utils.showToast(Get.context!, data['message']);
    // if (Get.isRegistered<OutgoingCallController>()) {
    Utils.showLog("ooooooooooooooooooooooooooo");

    if (data['callType'] == "audio") {
      // if (!Get.isRegistered<OutgoingCallController>()) {
      //   Get.put<OutgoingCallController>(OutgoingCallController());
      // }
      // final controller = Get.find<OutgoingCallController>();

      Utils.showLog("vvvvvvvvvvvvvvvvvvvvvvvvvv");

      Get.toNamed(AppRoutes.voiceCallScreen, arguments: {
        "callerId": data['callerId'],
        "receiverId": data['receiverId'],
        "callType": data['callType'],
        "callerRole": data['callerRole'],
        "receiverRole": data['receiverRole'],
        "callId": data['callId'],
        "receiverName": data['receiverName'],
        "callerfullName": data['callerfullName'],
        "receiverImage": data['receiverImage'],
        "callerImage": data['callerImage'],
        "isAccept": data['isAccept'],
        "callMode": data['callMode'],
        // "micMute": controller.micMute,
        // "micMute": controller.micMute,
        // "speakerOn": controller.isSpeakerOn,
      });
    } else {
      Get.toNamed(AppRoutes.videoCallScreen, arguments: data);
    }
    // }
  }

  /// when caller call then Invalid caller, receiver, or call history then listen this event
  static void handleCallResponseProcessed(dynamic data) {
    Utils.showLog("Socket Listen => callResponseProcessed event: $data");
    Utils.showToast(Get.context!, data['message']);
  }

  /// if callId not match then listen also in callTimedOut ( to receiver )
  static void handleCallTimedOut(dynamic data) {
    Utils.showLog("Socket Listen => callTimedOut event: $data");
    // Utils.showToast(Get.context!, data['message']);
    if (Get.isRegistered<VideoCallController>()) {
      final videoCallController = Get.find<VideoCallController>();

      SocketEmit.emitCallTerminated(
        callerId: videoCallController.callerId.toString(),
        receiverId: videoCallController.receiverId.toString(),
        callId: videoCallController.callId.toString(),
        callType: videoCallController.callType.toString(),
        callMode: videoCallController.callMode.toString(),
        callerRole: videoCallController.callerRole.toString(),
        receiverRole: videoCallController.receiverRole.toString(),
        receiverName: videoCallController.receiverName.toString(),
        receiverImage: videoCallController.receiverImage.toString(),
      );
    }
  }

  /// when caller cut call then this event listen
  static void handleCallEnded(dynamic data) {
    Utils.showLog("Socket Listen => callEnded event: $data");
    if (Get.currentRoute == AppRoutes.incomingCallScreen) {
      log("***************************${Get.currentRoute == AppRoutes.incomingCallScreen}");
      Get.back();
    }
  }

  /// if Invalid caller, receiver, or call history then listen also in callRejected event
  static void handleCallRejected(dynamic data) {
    Utils.showLog("Socket Listen => callRejected event: $data");
  }

  /// both join call and then cut call this event listen
  // static Future<void> handleCallTerminated(dynamic data) async {
  //   UserCoinModel? userCoinModel;
  //   ListenerCoinModel? listenerCoinModel;
  //   Utils.showLog("Socket Listen => callTerminated event: $data");
  //
  //   final callerRole = data['callerRole'];
  //   final callMode = data['callMode'];
  //   if (Database.fetchLoginUserProfileModel?.user?.isListener == false && callMode == "random") {
  //     // Get.close(2);
  //     if (Get.currentRoute == AppRoutes.videoCallScreen || Get.currentRoute == AppRoutes.voiceCallScreen) {
  //       StreamSubscription<bool>? subsProximity;
  //
  //       await ProximityScreenLock.setActive(false);
  //       // Subscribe to proximity states
  //       subsProximity = ProximityScreenLock.proximityStates.listen((objectDetected) {
  //         log("call cut screen controller Proximity event (even though disabled): $objectDetected   $subsProximity");
  //       });
  //
  //       Get.back();
  //     }
  //
  //     log("is listener ${Database.fetchLoginUserProfileModel?.user?.isListener}");
  //     log("call mode  $callMode");
  //   } else {
  //     if (Get.currentRoute == AppRoutes.videoCallScreen || Get.currentRoute == AppRoutes.voiceCallScreen) {
  //       Get.back();
  //     }
  //   }
  //   if (Database.fetchLoginUserProfileModel?.user?.isListener == false && callerRole == "user") {
  //     Get.toNamed(AppRoutes.callCutScreen, arguments: data);
  //   }
  //
  //   userCoinModel = await UserCoinApi.callApi();
  //   Database.onSetUserCoin(userCoinModel?.coin.toString() ?? "0");
  //
  //   if (Get.isRegistered<HostHomeScreenController>()) {
  //     final hostHomeScreenController = Get.find<HostHomeScreenController>();
  //
  //     hostHomeScreenController.isCoinLoading = true;
  //     hostHomeScreenController.update([Constant.idCoinUpdate]);
  //     listenerCoinModel = await HostCoinApi.callApi();
  //     Database.onSetListenerCoin(listenerCoinModel!.coin.toString());
  //     hostHomeScreenController.isCoinLoading = false;
  //     hostHomeScreenController.update([Constant.idCoinUpdate]);
  //   }
  // }

  static Future<void> handleCallTerminated(dynamic data) async {
    UserCoinModel? userCoinModel;
    ListenerCoinModel? listenerCoinModel;
    Utils.showLog("Socket Listen => callTerminated event: $data");
    VoiceCallController? controller;
    if (Get.isRegistered<VoiceCallController>()) {
      controller = Get.find<VoiceCallController>();
    } else {
      controller = Get.put(VoiceCallController());
      log("⚠️ VoiceCallController not registered, skipping cleanup.");
    }
    final callerRole = data['callerRole'];
    final callMode = data['callMode'];

    // ✅ First, properly cleanup proximity sensor and screen lock
    try {
      await ProximityScreenLock.setActive(false);
      // ✅ Force screen to turn ON if it was locked by proximity
      controller?.isProximitySupported = false;
      controller?.isObjectNear = false;
      controller?.userEnabledSpeaker = false;
      log("✅ Proximity sensor deactivated and screen unlocked  userEnabledSpeaker = ${controller?.userEnabledSpeaker} isObjectNear = ${controller?.isObjectNear} isProximitySupported = ${controller?.isProximitySupported}");
    } catch (e) {
      log("❌ Error deactivating proximity sensor: $e");
    }

    if (Database.fetchLoginUserProfileModel?.user?.isListener == false && callMode == "random") {
      if (Get.currentRoute == AppRoutes.videoCallScreen || Get.currentRoute == AppRoutes.voiceCallScreen) {
        Get.back();
      }

      log("is listener ${Database.fetchLoginUserProfileModel?.user?.isListener}");
      log("call mode  $callMode");
    } else {
      if (Get.currentRoute == AppRoutes.videoCallScreen || Get.currentRoute == AppRoutes.voiceCallScreen) {
        Get.back();
      }
    }

    if (Database.fetchLoginUserProfileModel?.user?.isListener == false && callerRole == "user") {
      Get.toNamed(AppRoutes.callCutScreen, arguments: data);
    }

    userCoinModel = await UserCoinApi.callApi();
    Database.onSetUserCoin(userCoinModel?.coin.toString() ?? "0");

    if (Get.isRegistered<HostHomeScreenController>()) {
      final hostHomeScreenController = Get.find<HostHomeScreenController>();

      hostHomeScreenController.isCoinLoading = true;
      hostHomeScreenController.update([Constant.idCoinUpdate]);
      listenerCoinModel = await HostCoinApi.callApi();
      Database.onSetListenerCoin(listenerCoinModel!.coin.toString());
      hostHomeScreenController.isCoinLoading = false;
      hostHomeScreenController.update([Constant.idCoinUpdate]);
    }
  }

  /// random call If any error like busy, caller or receiver not found then listen always in incomingRingingStarted event
  static void handleRandomCallRinging(dynamic data) {
    Utils.showLog("Socket Listen => random call incomingRingingStarted (error or status): $data");
    Utils.showToast(Get.context!, data['message']);
  }

  static void handleNotEnoughCoins(dynamic data) {
    Utils.showLog("Socket Listen => handleNotEnoughCoins: $data");
    if (Get.isRegistered<VideoCallController>()) {
      final videoCallController = Get.find<VideoCallController>();

      SocketEmit.emitCallTerminated(
        callerId: videoCallController.callerId.toString(),
        receiverId: videoCallController.receiverId.toString(),
        callId: videoCallController.callId.toString(),
        callType: videoCallController.callType.toString(),
        callMode: videoCallController.callMode.toString(),
        callerRole: videoCallController.callerRole.toString(),
        receiverRole: videoCallController.receiverRole.toString(),
        receiverName: videoCallController.receiverName.toString(),
        receiverImage: videoCallController.receiverImage.toString(),
      );
    }
    if (Get.isRegistered<VoiceCallController>()) {
      final voiceCallController = Get.find<VoiceCallController>();

      SocketEmit.emitCallTerminated(
        callerId: voiceCallController.callerId.toString(),
        receiverId: voiceCallController.receiverId.toString(),
        callId: voiceCallController.callId.toString(),
        callType: voiceCallController.callType.toString(),
        callMode: voiceCallController.callMode.toString(),
        callerRole: voiceCallController.callerRole.toString(),
        receiverRole: voiceCallController.receiverRole.toString(),
        receiverName: voiceCallController.receiverName.toString(),
        receiverImage: voiceCallController.receiverImage.toString(),
      );
    }
    Utils.showToast(Get.context!, data);
  }

  /// if Invalid callerRole or receiverRole  or Caller, Receiver, or CallHistory not found then listen also in coinDeductionError
  static void handleCallCoinsDeducted(dynamic data) {
    Utils.showLog("Socket Listen => callCoinsDeducted: $data");
    Utils.showToast(Get.context!, data['message']);
    if (Get.isRegistered<VideoCallController>()) {
      final videoCallController = Get.find<VideoCallController>();

      SocketEmit.emitCallTerminated(
        callerId: videoCallController.callerId.toString(),
        receiverId: videoCallController.receiverId.toString(),
        callId: videoCallController.callId.toString(),
        callType: videoCallController.callType.toString(),
        callMode: videoCallController.callMode.toString(),
        callerRole: videoCallController.callerRole.toString(),
        receiverRole: videoCallController.receiverRole.toString(),
        receiverName: videoCallController.receiverName.toString(),
        receiverImage: videoCallController.receiverImage.toString(),
      );
    }
  }

  /// call cut data listen this event
  static void handleCallCutData(dynamic data) {
    try {
      Utils.showLog("Socket Listen => callCutData: $data");

      // Inject if not already present
      if (!Get.isRegistered<CallCutController>()) {
        Get.put(CallCutController());
      }

      Get.find<CallCutController>().setCallCutData(data);
    } catch (e, st) {
      Utils.showLog("❌ Error in handleCallCutData: $e\n$st");
    }
  }
}

class CallCutDataStorage {
  static String? callId;
  static String? date;
  static String? balanceUsed;
  static String? duration;
}

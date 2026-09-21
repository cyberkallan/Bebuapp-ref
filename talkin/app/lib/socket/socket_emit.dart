import 'package:talk_in/socket/socket_service.dart';
import 'package:talk_in/ui/host_flow/host_home_screen/api/host_coin_api.dart';
import 'package:talk_in/ui/host_flow/host_home_screen/model/listener_coin_model.dart';
import 'package:talk_in/ui/user_flow/home_screen/api/user_coin_api.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/user_coin_model.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/socket_events.dart';
import 'package:talk_in/utils/socket_params.dart';
import 'package:talk_in/utils/utils.dart';

class SocketEmit {
  static void sendMessage(Map<String, dynamic> message) {
    if (socket != null && socket?.connected == true) {
      socket?.emit(SocketEvents.sendMessage, message);
      Utils.showLog("Emitting message: $message");
    } else {
      Utils.showLog("Socket Not Connected!!");
    }
  }

  static void onMessageSeen(Map<String, dynamic> data) async {
    // final data = jsonEncode({
    //   SocketParams.messageId: messageId,
    //   SocketParams.senderId: senderId,
    // });

    if (socket != null && socket?.connected == true) {
      socket?.emit(SocketEvents.markMessageSeen, data);
      Utils.showLog("Socket Emit => Message Seen: $data");
    } else {
      Utils.showLog("Socket Not Connected!!");
    }
  }

  /// private video & audio call button onTap first this event emit
  static void emitCallOutgoingRinging({
    required String callerId,
    required String receiverId,
    required String callType,
    required String callerRole,
    required String receiverRole,
    required String receiverName,
    required String receiverImage,
    required String callerName,
    required String callerImage,
  }) {
    if (socket != null && socket?.connected == true) {
      final data = {
        SocketParams.callerId: callerId,
        SocketParams.receiverId: receiverId,
        SocketParams.callType: callType,
        SocketParams.callerRole: callerRole,
        SocketParams.receiverRole: receiverRole,
        SocketParams.receiverName: receiverName,
        SocketParams.receiverImage: receiverImage,
        SocketParams.callerName: callerName,
        SocketParams.callerImage: callerImage,
      };
      socket?.emit(SocketEvents.callOutgoingRinging, data);
      Utils.showLog("Socket Emit => callOutgoingRinging: $data");
    } else {
      Utils.showLog("Socket Not Connected!!");
    }
  }

  ///when caller accept call then this event  emit
  static void emitCallResponseProcessed({
    required String callerId,
    required String receiverId,
    required String callId,
    required bool isAccept,
    required String callType,
    required String callMode,
    required String callerRole,
    required String receiverRole,
    required String receiverName,
    required String receiverImage,
    required String callerName,
    required String callerImage,
  }) {
    if (socket != null && socket!.connected) {
      final data = {
        SocketParams.callerId: callerId,
        SocketParams.receiverId: receiverId,
        SocketParams.callType: callType,
        SocketParams.callerRole: callerRole,
        SocketParams.receiverRole: receiverRole,
        SocketParams.callId: callId,
        SocketParams.receiverName: receiverName,
        SocketParams.receiverImage: receiverImage,
        SocketParams.callerName: callerName,
        SocketParams.callerImage: callerImage,
        SocketParams.isAccept: isAccept,
        SocketParams.callMode: callMode,
      };
      socket!.emit(SocketEvents.callResponseProcessed, data);
      Utils.showLog("Socket Emit => callResponseProcessed: $data");
    } else {
      Utils.showLog("Socket Not Connected!!");
    }
  }

  /// when caller cut call then this event emit
  static void emitCallerCallCut({
    required String callerId,
    required String receiverId,
    required String callId,
    required String callType,
    required String callMode,
    required String callerRole,
    required String receiverRole,
  }) {
    if (socket != null && socket!.connected) {
      final data = {
        SocketParams.callerId: callerId,
        SocketParams.receiverId: receiverId,
        SocketParams.callId: callId,
        SocketParams.callType: callType,
        SocketParams.callMode: callMode,
        SocketParams.callerRole: callerRole,
        SocketParams.receiverRole: receiverRole,
      };
      socket!.emit(SocketEvents.callerCallCut, data);
      Utils.showLog("Socket Emit => callRejected: $data");
      // Get.toNamed(AppRoutes.callCutScreen);
    } else {
      Utils.showLog("Socket Not Connected!!");
    }
  }

  /// join call both and cut call then emit this event
  static void emitCallTerminated({
    required String callerId,
    required String receiverId,
    required String callId,
    required String callType,
    required String callMode,
    required String callerRole,
    required String receiverRole,
    required String receiverName,
    required String receiverImage,
  }) async {
    if (socket != null && socket!.connected) {
      UserCoinModel? userCoinModel;
      ListenerCoinModel? listenerCoinModel;
      final data = {
        SocketParams.callerId: callerId,
        SocketParams.receiverId: receiverId,
        SocketParams.callType: callType,
        SocketParams.callerRole: callerRole,
        SocketParams.receiverRole: receiverRole,
        SocketParams.callId: callId,
        SocketParams.callMode: callMode,
        SocketParams.receiverName: receiverName,
        SocketParams.receiverImage: receiverImage,
      };
      socket!.emit(SocketEvents.callTerminated, data);
      userCoinModel = await UserCoinApi.callApi();
      Database.onSetUserCoin(userCoinModel?.coin.toString() ?? "0");

      listenerCoinModel = await HostCoinApi.callApi();
      Database.onSetListenerCoin(listenerCoinModel!.coin.toString());

      Utils.showLog("Socket Emit => callTerminated: $data");
    } else {
      Utils.showLog("Socket Not Connected!!");
    }
  }

  /// random call ringing
  static void randomCallRinging({
    required String callerId,
    required String receiverId,
    required String callType,
    required String callerRole,
    required String receiverRole,
    required String receiverName,
    required String receiverImage,
    required String callerName,
    required String callerImage,
  }) {
    if (socket != null && socket?.connected == true) {
      final data = {
        SocketParams.callerId: callerId,
        SocketParams.receiverId: receiverId,
        SocketParams.callType: callType,
        SocketParams.callerRole: callerRole,
        SocketParams.receiverRole: receiverRole,
        SocketParams.receiverName: receiverName,
        SocketParams.receiverImage: receiverImage,
        SocketParams.callerName: callerName,
        SocketParams.callerImage: callerImage,
      };
      socket?.emit(SocketEvents.randomCallRinging, data);
      Utils.showLog("Socket Emit => random call incomingRingingStarted: $data");
    } else {
      Utils.showLog("Socket Not Connected!!");
    }
  }

  /// coin cut call
  static void callCoinsDeducted({
    required String callerId,
    required String receiverId,
    required String callId,
    required String callType,
    required String callMode,
    required String callerRole,
    required String receiverRole,
    // required String receiverName,
    // required String receiverImage,
    // required String callerName,
    // required String callerImage,
  }) {
    if (socket != null && socket?.connected == true) {
      final data = {
        SocketParams.callerId: callerId,
        SocketParams.receiverId: receiverId,
        SocketParams.callId: callId,
        SocketParams.callType: callType,
        SocketParams.callMode: callMode,
        SocketParams.callerRole: callerRole,
        SocketParams.receiverRole: receiverRole,
      };
      socket?.emit(SocketEvents.callCoinsDeducted, data);
      Utils.showLog("Socket Emit => coin cut callCoinsDeducted: $data");
    } else {
      Utils.showLog("Socket Not Connected!!");
    }
  }
}

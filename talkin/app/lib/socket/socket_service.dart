import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

io.Socket? socket;

class SocketService {
  io.Socket? getSocket() => socket;

  static Future<void> socketDisConnect() async {
    socket?.disconnect();
    socket?.onDisconnect(
      (data) => Utils.showLog("Socket Listen => Socket Disconnected Called : ${socket?.id}"),
    );
  }

  static Future<void> socketConnect() async {
    log("listener id :::::: ${Database.fetchListenerProfileModel?.data?.id}");
    log("user id :::::: ${Database.loginUserId}");

    try {
      socket = io.io(
        Api.baseUrl,
        io.OptionBuilder().setTransports(['websocket']).setQuery({
          "globalRoom":
              "globalRoom:${Database.fetchLoginUserProfileModel?.user?.isListener == true ? Database.fetchListenerProfileModel?.data?.id : Database.loginUserId}"
        }).build(),
      );

      socket?.connect();

      socket?.onConnect((_) {
        Utils.showLog("Socket Listen => Socket Connected : ${socket?.id}");
      });

      socket?.on("error", (error) {
        Utils.showLog("Socket Listen => Socket Error : $error");
      });

      socket?.on("connect_error", (error) {
        Utils.showLog("Socket Listen => Socket Connection Error : $error");
      });

      socket?.on("connect_timeout", (timeout) {
        Utils.showLog("Socket Listen => Socket Connection Timeout : $timeout");
      });

      socket?.on("disconnect", (reason) {
        Utils.showLog("Socket Listen => Socket Disconnected : $reason");
      });

      Utils.showLog("Socket Listen => Socket Connected : ${socket?.connected}");
    } catch (e) {
      Utils.showLog("Socket Listen => Socket Connection Error: $e");
    }
  }
}

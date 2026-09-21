import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:talk_in/socket/socket_listen.dart';
import 'package:talk_in/socket/socket_service.dart';
import 'package:talk_in/ui/user_flow/calling_screen/view/calling_screen.dart';
import 'package:talk_in/ui/user_flow/chat_screen/view/chat_screen.dart';
import 'package:talk_in/ui/user_flow/home_screen/view/home_screen.dart';
import 'package:talk_in/ui/user_flow/listener_screen/view/listeners_screen.dart';
import 'package:talk_in/ui/user_flow/random_call_screen/view/random_call_view.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/setting_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/setting_api_model.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class BottomBarController extends GetxController {
  bool checkScreen = false;
  int selectIndex = 0;
  SettingApiModel? settingApiModel;

  @override
  void onInit() {
    // SocketManager.initSocketManager();
    init();
    // SocketService.socketConnect().then((_) {
    //   Utils.showLog(" Socket connect User");
    //   SocketListen.registerListeners();
    // });

    super.onInit();
  }

  init() async {
    log("Enter user bottomBar Controller");
    await SocketService.socketDisConnect();
    await SocketService.socketConnect().then((_) {
      Utils.showLog(" Socket connect User");
      SocketListen.registerListeners();
    });

    settingApiModel = await SettingApi.callApi();
    Database.settingApiModel = settingApiModel;
    createEngine();
  }

  Future<void> createEngine() async {
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

  final pages = [
    HomeScreen(),
    ListenersScreen(),
    RandomCallScreen(),
    ChatScreen(),
    CallingScreen(),
  ];

  onClick(value) async {
    if (value != null) {
      selectIndex = value;
      update([Constant.idBottomBar]);
    }
  }
}

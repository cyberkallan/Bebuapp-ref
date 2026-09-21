import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:talk_in/utils/utils.dart';

class InternetConnection {
  static RxBool isConnect = false.obs;

  static void init() {
    Connectivity().onConnectivityChanged.listen(
      (result) {
        switch (result.first) {
          case ConnectivityResult.none:
            isConnect.value = false;
            Utils.showLog("Network Not Connect...");
            break;
          case ConnectivityResult.bluetooth:
            isConnect.value = true;
            Utils.showLog("Network Connected to Bluetooth...");
            break;
          case ConnectivityResult.wifi:
            isConnect.value = true;
            Utils.showLog("Network Connected to Wifi...");
            break;
          case ConnectivityResult.ethernet:
            isConnect.value = true;
            Utils.showLog("Network Connected to Ethernet...");
            break;
          case ConnectivityResult.mobile:
            isConnect.value = true;
            Utils.showLog("Network Connected to Mobile...");
            break;
          case ConnectivityResult.vpn:
            isConnect.value = true;
            Utils.showLog("Network Connected to VPN...");
            break;
          case ConnectivityResult.other:
            isConnect.value = true;
            Utils.showLog("Network Connected to Other...");
            break;
        }
      },
    );
  }
}

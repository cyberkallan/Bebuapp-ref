import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/host_withdraw_coin_screen/controller/host_withdraw_coin_controller.dart';

class HostWithdrawCoinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HostWithdrawCoinController>(() => HostWithdrawCoinController());
  }
}

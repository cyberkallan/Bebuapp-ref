import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/coin_history_screen/controller/coin_history_screen_controller.dart';

class CoinHistoryScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoinHistoryScreenController>(() => CoinHistoryScreenController());
  }
}

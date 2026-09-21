import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/coin_purchase_screen/controller/coin_purchase_screen_controller.dart';

class CoinPurchaseScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoinPurchaseScreenController>(() => CoinPurchaseScreenController());
  }
}

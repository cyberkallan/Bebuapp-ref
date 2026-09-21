import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/controller/my_wallet_controller.dart';

class MyWalletScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyWalletController>(() => MyWalletController());
  }
}

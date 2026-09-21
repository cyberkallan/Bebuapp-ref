import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/mobile_number_screen/controller/mobile_number_controller.dart';

class MobileNumberBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MobileNumberController>(() => MobileNumberController());
  }
}

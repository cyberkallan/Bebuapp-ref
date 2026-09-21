import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/random_call_screen/controller/random_call_controller.dart';

class RandomCallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RandomCallController>(() => RandomCallController());
  }
}

import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/sign_in_screen/controller/sign_in_controller.dart';

class SignInBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignInController>(() => SignInController());
  }
}

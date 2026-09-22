import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/forgot_password_screen/controller/forgot_password_controller.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());
  }
}

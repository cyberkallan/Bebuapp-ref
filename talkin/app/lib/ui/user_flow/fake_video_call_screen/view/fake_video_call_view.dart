import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/fake_video_call_screen/controller/fake_video_call_controller.dart';
import 'package:talk_in/ui/user_flow/fake_video_call_screen/fake_video_call_widget/fake_video_call_widget.dart';
import 'package:talk_in/utils/utils.dart';

class FakeVideoCallScreen extends StatefulWidget {
  const FakeVideoCallScreen({super.key});

  @override
  State<FakeVideoCallScreen> createState() => _FakeVideoCallScreenState();
}

class _FakeVideoCallScreenState extends State<FakeVideoCallScreen> with WidgetsBindingObserver {
  final controller = Get.put<FakeVideoCallController>(FakeVideoCallController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      Utils.showLog("App went to background");
      // App went to background
      // controller.endCallDueToBackground();
      if (controller.isBackProfile == true) {
        Utils.showLog("Is Back Profile ${controller.isBackProfile}");
        Get.back();
      } else {
        Utils.showLog("Is Back Profile ${controller.isBackProfile}");
        Get.back();
        // Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: FakeVideoCallView(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:talk_in/ui/user_flow/fake_audio_call_screen/widget/fake_audio_call_widget.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:get/get.dart';
import 'package:talk_in/utils/utils.dart';

class FakeAudioCallScreen extends StatefulWidget {
  const FakeAudioCallScreen({super.key});

  @override
  State<FakeAudioCallScreen> createState() => _FakeAudioCallScreenState();
}

class _FakeAudioCallScreenState extends State<FakeAudioCallScreen> with WidgetsBindingObserver {
  // final controller = Get.put<FakeAudioCallController>(FakeAudioCallController());
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
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: FakeVoiceCallView(),
    );
  }
}

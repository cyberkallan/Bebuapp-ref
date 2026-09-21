import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/voice_call_screen/controller/voice_call_controller.dart';
import 'package:talk_in/ui/user_flow/voice_call_screen/widget/voice_call_widget.dart';
import 'package:talk_in/utils/app_color.dart';

class VoiceCallScreen extends StatefulWidget {
  const VoiceCallScreen({super.key});

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> with WidgetsBindingObserver {
  final controller = Get.put<VoiceCallController>(VoiceCallController());
  double originalBrightness = 1.0;

  @override
  void initState() {
    super.initState();
    // enableProximitySensorFallback();
    WidgetsBinding.instance.addObserver(this);
  }

  // void enableProximitySensorFallback() async {
  //   try {
  //     final supported = await ProximityScreenLock.isProximityLockSupported();
  //
  //     if (supported) {
  //       originalBrightness = await ScreenBrightness().current;
  //
  //       ProximityScreenLock.proximityStates.listen((bool isNear) async {
  //         if (isNear) {
  //           // Dim screen
  //           await ScreenBrightness().setScreenBrightness(0.01);
  //         } else {
  //           // Restore brightness
  //           await ScreenBrightness().setScreenBrightness(originalBrightness);
  //         }
  //       });
  //     } else {
  //       debugPrint("❌ Proximity not supported on this device.");
  //     }
  //   } catch (e) {
  //     debugPrint("❌ Proximity setup failed: $e");
  //   }
  // }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // ScreenBrightness().resetScreenBrightness(); // ✅ Restore brightness on dispose

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      log("App went to background");
      // App went to background
      controller.endCallDueToBackground();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: const VoiceCallView1(),
      ),
    );
  }
}

import 'dart:developer';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:talk_in/ui/user_flow/video_call_screen/controller/video_call_controller.dart';
import 'package:talk_in/ui/user_flow/video_call_screen/widget/video_call_widget.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> with WidgetsBindingObserver {
  final controller = Get.put<VideoCallController>(VideoCallController());

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
    if (state == AppLifecycleState.paused) {
      log("App went to background");
      // App went to background
      controller.endCallDueToBackground();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Utils.onChangeStatusBar(brightness: Brightness.light);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: VideoCallView1(),
      ),
    );
  }
}

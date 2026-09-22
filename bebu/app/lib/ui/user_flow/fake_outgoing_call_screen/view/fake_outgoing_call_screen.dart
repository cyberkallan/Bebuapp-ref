import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/fake_outgoing_call_screen/controller/fake_outgoing_call_controller.dart';
import 'package:talk_in/ui/user_flow/fake_outgoing_call_screen/widget/fake_outgoing_call_widget.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/utils.dart';

class FakeOutgoingCallScreen extends StatelessWidget {
  const FakeOutgoingCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: GetBuilder<FakeOutgoingCallController>(
            id: Constant.idVideoCall,
            builder: (controller) {
              Utils.showLog('controller.callType  ////////////${controller.callType}');
              return controller.callType == 'audio' ? const FakeAudioOutgoingCallView() : const FakeOutgoingCallView();
              // return controller.callType == 'audio' ? const FakeAudioOutgoingCallView() : const FakeOutgoingCallView();
            }),
      ),
    );
  }
}

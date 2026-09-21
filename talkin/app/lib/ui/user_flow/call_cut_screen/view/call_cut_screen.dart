import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/call_cut_screen/controller/call_cut_controller.dart';
import 'package:talk_in/ui/user_flow/call_cut_screen/widget/call_cut_widget.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/utils.dart';

class CallCutScreen extends StatelessWidget {
  const CallCutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light);
    return PopScope(
      canPop: false,
      child: Scaffold(
        bottomNavigationBar: BottomView(),
        backgroundColor: AppColors.backGroundColor,
        body: GetBuilder<CallCutController>(builder: (context) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CallCutView(),
              ],
            ),
          );
        }),
      ),
    );
  }
}

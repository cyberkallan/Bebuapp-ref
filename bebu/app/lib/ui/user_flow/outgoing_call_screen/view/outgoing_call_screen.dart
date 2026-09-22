import 'package:flutter/material.dart';
import 'package:talk_in/ui/user_flow/outgoing_call_screen/widget/outgoing_call_widget.dart';
import 'package:talk_in/utils/app_color.dart';

class OutgoingCallScreen extends StatelessWidget {
  const OutgoingCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: const OutgoingCallView(),
      ),
    );
  }
}

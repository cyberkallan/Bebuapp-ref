import 'package:flutter/material.dart';
import 'package:talk_in/ui/user_flow/incoming_call_screen/widget/incoming_call_widget.dart';
import 'package:talk_in/utils/app_color.dart';

class IncomingCallScreen extends StatelessWidget {
  const IncomingCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: const IncomingCallView(),
      ),
    );
  }
}

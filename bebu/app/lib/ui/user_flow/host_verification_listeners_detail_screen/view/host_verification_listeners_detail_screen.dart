import 'package:flutter/material.dart';
import 'package:talk_in/ui/user_flow/host_verification_listeners_detail_screen/widget/host_verification_listeners_detail_widget.dart';
import 'package:talk_in/utils/app_color.dart';

class HostVerificationListenersDetailScreen extends StatelessWidget {
  const HostVerificationListenersDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPurple,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const HostVerificationListenersDetailAppBar(),
      ),
      bottomNavigationBar: HostVerificationListenersDetailBottomButton(),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
            currentFocus.focusedChild?.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              HostVerificationListenersDetailView(),
            ],
          ),
        ),
      ),
    );
  }
}

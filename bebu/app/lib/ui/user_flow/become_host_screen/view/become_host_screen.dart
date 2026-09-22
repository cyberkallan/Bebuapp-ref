import 'package:flutter/material.dart';
import 'package:talk_in/ui/user_flow/become_host_screen/widget/become_host_screen_widget.dart';

class BecomeHostScreen extends StatelessWidget {
  const BecomeHostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const BecomeHostScreenAppBar(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BecomeHostScreenView(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height,
      width: Get.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          end: Alignment.bottomCenter,
          begin: Alignment.topCenter,
          colors: [
            Color(0xffF1EDFF),
            Color(0xffF4F6FF),
            Color(0xffF7FAFF),
            Color(0xffF7FAFF),
            Color(0xffFFFFFF),
            Color(0xffFFFFFF),
          ],
        ),
      ),
      child: child,
    );
  }
}

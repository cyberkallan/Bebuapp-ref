/*
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:talk_in/ui/user_flow/random_call_screen/controller/random_call_controller.dart';
import 'package:talk_in/ui/user_flow/random_call_screen/widget/random_call_widget.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class RandomCallScreen extends StatefulWidget {
  const RandomCallScreen({super.key});

  @override
  State<RandomCallScreen> createState() => _RandomCallScreenState();
}

class _RandomCallScreenState extends State<RandomCallScreen> {
  final Random _random = Random();
  RandomCallController randomCallController = Get.put(RandomCallController());

  @override
  void initState() {
    // randomCallController.randomCall = false;

    // Utils.showLog("Random call ============= ${randomCallController.randomCall}");

    super.initState();
    _initializeRandomListeners();
  }

  void _initializeRandomListeners() {
    final shuffled = List<TopListeners>.from(randomCallController.allListener)..shuffle();
    randomCallController.randomDisplayList = shuffled.take(4).toList();

    randomCallController.fadeDurations = List.generate(4, (_) => Duration(seconds: 3 + _random.nextInt(2)));
    randomCallController.delays = List.generate(4, (_) => Duration(milliseconds: 200 + _random.nextInt(1000)));

    // randomCallController.update([Constant.idGetListener]);
  }

  void replaceListenerAt(int index) {
    final usedIds = randomCallController.randomDisplayList.map((e) => e.id).toSet();
    final available = randomCallController.allListener.where((e) => !usedIds.contains(e.id)).toList();
    if (available.isEmpty) return;

    final newListener = available[_random.nextInt(available.length)];

    randomCallController.randomDisplayList[index] = newListener;
    randomCallController.fadeDurations[index] = Duration(seconds: 3 + _random.nextInt(2));
    randomCallController.delays[index] = Duration(milliseconds: 200 + _random.nextInt(1000));

    randomCallController.update([Constant.idGetListener]);
  }

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.dark);

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        Get.dialog(
          barrierColor: AppColors.black.withValues(alpha: 0.8),
          Dialog(
            backgroundColor: AppColors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            child: const ExitAppDialog(),
          ),
        );
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.randomCallGrey.withValues(alpha: 0.07),
        body: GetBuilder<RandomCallController>(
          builder: (controller) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    RandomCallTopView(),
                  ],
                ),

                /// ripple animation for background
                Positioned(
                  right: -170,
                  top: 0,
                  bottom: 0,
                  child: RippleAnimation(
                    color: AppColors.randomCallBg,
                    delay: const Duration(milliseconds: 100),
                    repeat: true,
                    minRadius: 100,
                    maxRadius: 200,
                    ripplesCount: 6,
                    duration: const Duration(seconds: 3),
                    child: SizedBox(
                      height: 300,
                      width: 300,
                    ),
                  ),
                ),

                /// background image
                Positioned(
                  right: -140,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.zero,
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(AppAsset.randomBg),
                        ),
                        shape: BoxShape.circle,
                        color: AppColors.white),
                  ),
                ),

                /// bottom button view
                GetBuilder<RandomCallController>(
                    id: Constant.idGetListener,
                    builder: (context) {
                      return
                          // controller.randomCall == true
                          //   ? Positioned(
                          //       bottom: 0,
                          //       left: 0,
                          //       right: 0,
                          //       child: RandomMatchBottomButtonsView(),
                          //     )
                          //   :
                          Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: BottomButtonsView(),
                      );
                    }),

                /// listener list show
                GetBuilder<RandomCallController>(
                    id: Constant.idGetListener,
                    builder: (context) {
                      return
                          // controller.randomCall == true
                          //   ? Align(
                          //       alignment: Alignment.center,
                          //       child: Column(
                          //         // mainAxisAlignment: MainAxisAlignment.center,
                          //         children: [
                          //           Align(
                          //                   alignment: Alignment.centerLeft,
                          //                   child: Lottie.asset(AppAsset.randomMatchLottie, height: 150, fit: BoxFit.cover))
                          //               .paddingOnly(bottom: 20),
                          //           Row(
                          //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //             children: [
                          //               Column(
                          //                 mainAxisAlignment: MainAxisAlignment.center,
                          //                 children: [
                          //                   RippleAnimation(
                          //                     color: AppColors.notificationTxt.withValues(alpha: 0.3),
                          //                     delay: const Duration(milliseconds: 100),
                          //                     repeat: true,
                          //                     minRadius: 65,
                          //                     maxRadius: 25,
                          //                     ripplesCount: 6,
                          //                     duration: const Duration(seconds: 3),
                          //                     child: SizedBox(
                          //                       height: 100,
                          //                       width: 100,
                          //                       child: ClipOval(
                          //                         child: CustomListenerProfileImage(image: Database.fetchLoginUserProfileModel?.user?.profilePic ?? ''),
                          //                       ),
                          //                     ),
                          //                   ).paddingOnly(bottom: 14),
                          //                   Text(
                          //                     Database.fetchLoginUserProfileModel?.user?.nickName ?? '',
                          //                     style: AppFontStyle.fontStyleW700(
                          //                       fontSize: 14,
                          //                       fontColor: AppColors.black,
                          //                     ),
                          //                   ).paddingOnly(bottom: 8),
                          //                   // Container(
                          //                   //   padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          //                   //   decoration: BoxDecoration(
                          //                   //     borderRadius: BorderRadius.circular(46),
                          //                   //     gradient: LinearGradient(
                          //                   //       colors: [Color(0xffCF00FD), Color(0xff8400FF)],
                          //                   //     ),
                          //                   //   ),
                          //                   //   child: Text(
                          //                   //     " ${controller.randomAvailableListenerModel?.data?.talkTopics?[0] ?? ''}  ",
                          //                   //     style: AppFontStyle.fontStyleW600(
                          //                   //       fontSize: 10,
                          //                   //       fontColor: AppColors.white,
                          //                   //     ),
                          //                   //   ),
                          //                   // ),
                          //                 ],
                          //               ),
                          //               20.width,
                          //               Column(
                          //                 mainAxisAlignment: MainAxisAlignment.center,
                          //                 children: [
                          //                   RippleAnimation(
                          //                     color: AppColors.notificationTxt.withValues(alpha: 0.3),
                          //                     delay: const Duration(milliseconds: 100),
                          //                     repeat: true,
                          //                     minRadius: 65,
                          //                     maxRadius: 25,
                          //                     ripplesCount: 6,
                          //                     duration: const Duration(seconds: 3),
                          //                     child: SizedBox(
                          //                       height: 100,
                          //                       width: 100,
                          //                       child: ClipOval(
                          //                         child: CustomListenerProfileImage(image: controller.randomAvailableListenerModel?.data?.image ?? ''),
                          //                       ),
                          //                     ),
                          //                   ).paddingOnly(bottom: 14),
                          //                   Text(
                          //                     controller.randomAvailableListenerModel?.data?.name ?? '',
                          //                     style: AppFontStyle.fontStyleW700(
                          //                       fontSize: 14,
                          //                       fontColor: AppColors.black,
                          //                     ),
                          //                   ).paddingOnly(bottom: 8),
                          //                   // Container(
                          //                   //   padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          //                   //   decoration: BoxDecoration(
                          //                   //     borderRadius: BorderRadius.circular(46),
                          //                   //     gradient: LinearGradient(
                          //                   //       colors: [Color(0xffCF00FD), Color(0xff8400FF)],
                          //                   //     ),
                          //                   //   ),
                          //                   //   child: Text(
                          //                   //     " ${controller.randomAvailableListenerModel?.data?.talkTopics?[0] ?? ''}  ",
                          //                   //     style: AppFontStyle.fontStyleW600(
                          //                   //       fontSize: 10,
                          //                   //       fontColor: AppColors.white,
                          //                   //     ),
                          //                   //   ),
                          //                   // ),
                          //                 ],
                          //               ),
                          //             ],
                          //           ).paddingSymmetric(horizontal: 45),
                          //           Flexible(
                          //             child: Text(
                          //               textAlign: TextAlign.center,
                          //               "Random Match Connection...",
                          //               style: AppFontStyle.fontStyleKaushanW400(fontSize: 36, fontColor: AppColors.black),
                          //             ).paddingOnly(top: 32, left: 14, right: 14),
                          //           ),
                          //         ],
                          //       ).paddingOnly(top: Get.height * 0.12),
                          //     )
                          //   :
                          Positioned(
                        top: Get.height * 0.23,
                        bottom: Get.height * 0.1,
                        // bottom: 0,
                        left: (Get.width - 220) / 2,
                        child: SizedBox(
                          // color: AppColors.red,
                          height: Get.height * 0.45,
                          width: Get.width * 0.6,
                          child: GetBuilder<RandomCallController>(
                            id: Constant.idGetListener,
                            builder: (controller) {
                              return Column(
                                children: List.generate(controller.allListener.take(4).length, (index) {
                                  final item = controller.randomDisplayList[index];
                                  bool isLeft = index % 2 == 0;

                                  return Align(
                                    alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        Get.toNamed(
                                          AppRoutes.profileDetailScreenView,
                                          arguments: item.id,
                                        );
                                      },
                                      child: SmoothNameTransition(
                                        fadeDuration: randomCallController.fadeDurations[index],
                                        delay: randomCallController.delays[index],
                                        onAnimationComplete: () => replaceListenerAt(index),

                                        key: ValueKey('name-${item.id}-${item.name}'),
                                        // name: item.name.toString(),
                                        // fadeDuration: Duration(milliseconds: 2500 + (index * 300)),
                                        // delay: Duration(milliseconds: 500 + (index * 150)),
                                        childWidget: Stack(
                                          alignment: Alignment.center,
                                          clipBehavior: Clip.none,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(
                                                left: index == 3 ? 32 : 20,
                                                right: index == 3 ? 14 : 32,
                                                bottom: 7,
                                                top: 7,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.randomCallPurple,
                                                borderRadius: index == 3
                                                    ? BorderRadius.only(
                                                        bottomRight: Radius.circular(42),
                                                        topRight: Radius.circular(42),
                                                      )
                                                    : BorderRadius.only(
                                                        bottomLeft: Radius.circular(42),
                                                        topLeft: Radius.circular(42),
                                                      ),
                                                border: Border.all(color: AppColors.white, width: 2),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    item.name ?? '',
                                                    style: AppFontStyle.fontStyleW700(
                                                      fontSize: 13,
                                                      fontColor: AppColors.black,
                                                    ),
                                                  ).paddingOnly(bottom: 5),
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(46),
                                                      gradient: LinearGradient(
                                                        colors: [Color(0xffCF00FD), Color(0xff8400FF)],
                                                      ),
                                                    ),
                                                    child: Text(
                                                      " ${item.talkTopics?[0] ?? ''}  ",
                                                      style: AppFontStyle.fontStyleW600(
                                                        fontSize: 10,
                                                        fontColor: AppColors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Positioned(
                                              left: index == 3 ? -36 : null,
                                              right: index == 3 ? null : -36,
                                              child: Container(
                                                width: 62,
                                                height: 62,
                                                decoration: BoxDecoration(
                                                  border: Border.all(width: 4, color: AppColors.randomCallBorder),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Color(0xffCF00FD).withValues(alpha: 0.1),
                                                      blurRadius: 3,
                                                      offset: Offset(1, 1),
                                                      spreadRadius: 2.5,
                                                    ),
                                                  ],
                                                  shape: BoxShape.circle,
                                                ),
                                                child: ClipOval(
                                                  child: CustomProfileImage(
                                                    image: item.image ?? '',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ).paddingOnly(bottom: Get.height * 0.036),
                                  );
                                }),
                              );
                            },
                          ),
                          // child: RandomAnimatedListenerList(),
                        ),
                      );
                    }),

                /// loading
                if (controller.isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Center(
                        child: LoadingAnimationWidget.threeArchedCircle(
                          color: AppColors.appColor,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SmoothNameTransition extends StatefulWidget {
  final String? name;
  final VoidCallback onAnimationComplete;
  final Duration fadeDuration;
  final Duration delay;
  final Widget childWidget;

  const SmoothNameTransition({
    super.key,
    this.name,
    required this.onAnimationComplete,
    required this.fadeDuration,
    required this.delay,
    required this.childWidget,
  });

  @override
  _SmoothNameTransitionState createState() => _SmoothNameTransitionState();
}

class _SmoothNameTransitionState extends State<SmoothNameTransition> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _isReversing = false;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.fadeDuration,
      vsync: this,
    );

    // Create smoother fade animation with gentler curve
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutQuart, // Smoother curve
    ));

    // Create more subtle scale animation
    _scaleAnimation = Tween<double>(
      begin: 0.98, // Less dramatic scale change
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic, // Gentler bounce
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isReversing) {
        // Wait longer before starting reverse animation
        Future.delayed(Duration(milliseconds: 800), () {
          // Increased from 300ms
          if (mounted) {
            _isReversing = true;
            _controller.reverse();
          }
        });
      } else if (status == AnimationStatus.dismissed && _isReversing) {
        // Animation cycle complete, trigger callback
        widget.onAnimationComplete();
        _isReversing = false;
        // Start the next cycle
        _controller.forward();
      }
    });

    // Start with delay
    Future.delayed(widget.delay, () {
      if (mounted && !_hasStarted) {
        _hasStarted = true;
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Clamp values to prevent out-of-range errors
        final fadeValue = _fadeAnimation.value.clamp(0.0, 1.0);
        final scaleValue = _scaleAnimation.value.clamp(0.95, 1.05); // Tighter range

        return Transform.scale(
          scale: scaleValue,
          child: Opacity(
            opacity: fadeValue,
            child: widget.childWidget,
          ),
        );
      },
    );
  }
}
*/

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:talk_in/ui/user_flow/random_call_screen/controller/random_call_controller.dart';
import 'package:talk_in/ui/user_flow/random_call_screen/widget/random_call_widget.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class RandomCallScreen extends StatefulWidget {
  const RandomCallScreen({super.key});

  @override
  State<RandomCallScreen> createState() => _RandomCallScreenState();
}

class _RandomCallScreenState extends State<RandomCallScreen> {
  final Random _random = Random();
  RandomCallController randomCallController = Get.put(RandomCallController());

  @override
  void initState() {
    // randomCallController.randomCall = false;

    // Utils.showLog("Random call ============= ${randomCallController.randomCall}");

    super.initState();
    _initializeRandomListeners();
  }

  void _initializeRandomListeners() {
    final shuffled = List<TopListeners>.from(randomCallController.allListener)..shuffle();
    randomCallController.randomDisplayList = shuffled.take(4).toList();

    randomCallController.fadeDurations = List.generate(4, (_) => Duration(seconds: 3 + _random.nextInt(2)));
    randomCallController.delays = List.generate(4, (_) => Duration(milliseconds: 200 + _random.nextInt(1000)));

    // randomCallController.update([Constant.idGetListener]);
  }

  void replaceListenerAt(int index) {
    final usedIds = randomCallController.randomDisplayList.map((e) => e.id).toSet();
    final available = randomCallController.allListener.where((e) => !usedIds.contains(e.id)).toList();
    if (available.isEmpty) return;

    final newListener = available[_random.nextInt(available.length)];

    randomCallController.randomDisplayList[index] = newListener;
    randomCallController.fadeDurations[index] = Duration(seconds: 3 + _random.nextInt(2));
    randomCallController.delays[index] = Duration(milliseconds: 200 + _random.nextInt(1000));

    randomCallController.update([Constant.idGetListener]);
  }

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.dark);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        Get.dialog(
          barrierColor: AppColors.black.withValues(alpha: 0.8),
          Dialog(
            backgroundColor: AppColors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            child: const ExitAppDialog(),
          ),
        );
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: Color(0xffFBF1EA),
        body: GetBuilder<RandomCallController>(
          builder: (controller) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    RandomCallTopView(),
                  ],
                ),

                /// ripple animation for background
                Positioned(
                  right: -170,
                  top: Get.height * 0.2,
                  // bottom: 0,
                  child: RippleAnimation(
                    color: Color(0xffEDDDD2),
                    delay: const Duration(milliseconds: 100),
                    repeat: true,
                    minRadius: 200,
                    maxRadius: 170,
                    ripplesCount: 5,
                    duration: const Duration(seconds: 3),
                    child: SizedBox(
                      height: 310,
                      width: 310,
                    ),
                  ),
                ),

                /// background image
                /// dot background
                Positioned(
                  // right: -140,
                  top: Get.height * 0.2,
                  // bottom: 0,
                  child: Container(
                    padding: EdgeInsets.zero,
                    height: 300,
                    width: Get.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AppAsset.randomDotBg),
                      ),
                      // shape: BoxShape.circle,
                    ),
                  ),
                ),

                /// earth bg
                Positioned(
                  right: -140,
                  top: Get.height * 0.2,
                  // bottom: 0,
                  child: Container(
                    padding: EdgeInsets.zero,
                    height: 270,
                    width: 270,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AppAsset.randomBg),
                        opacity: 0.55,
                      ),
                      shape: BoxShape.circle,
                      color: Color(0xffEFE2DE).withValues(alpha: 0.1),
                    ),
                  ),
                ),

                /// bottom bg
                Positioned(
                  right: 0,
                  left: 0,
                  // top: 0,
                  bottom: Get.height * -0.1,
                  child: Container(
                    padding: EdgeInsets.zero,
                    height: 300,
                    width: Get.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage(AppAsset.randomBottomBg), fit: BoxFit.cover),
                      // shape: BoxShape.circle,
                    ),
                  ),
                ),

                /// bottom button view
                GetBuilder<RandomCallController>(
                    id: Constant.idGetListener,
                    builder: (context) {
                      return
                          //
                          // controller.randomCall == true
                          //     ? Positioned(
                          //         bottom: 0,
                          //         left: 0,
                          //         right: 0,
                          //         child: RandomMatchBottomButtonsView(),
                          //       )
                          //     :
                          Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: BottomButtonsView(),
                      );
                    }),

                /// listener list show
                GetBuilder<RandomCallController>(
                    id: Constant.idGetListener,
                    builder: (context) {
                      return

                          // controller.randomCall == true
                          //   ? Align(
                          //       alignment: Alignment.center,
                          //       child: Column(
                          //         // mainAxisAlignment: MainAxisAlignment.center,
                          //         children: [
                          //           Align(
                          //                   alignment: Alignment.centerLeft,
                          //                   child: Lottie.asset(AppAsset.randomMatchLottie, height: 150, fit: BoxFit.cover))
                          //               .paddingOnly(bottom: 20),
                          //           Row(
                          //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //             children: [
                          //               Column(
                          //                 mainAxisAlignment: MainAxisAlignment.center,
                          //                 children: [
                          //                   RippleAnimation(
                          //                     color: AppColors.notificationTxt.withValues(alpha: 0.3),
                          //                     delay: const Duration(milliseconds: 100),
                          //                     repeat: true,
                          //                     minRadius: 65,
                          //                     maxRadius: 25,
                          //                     ripplesCount: 6,
                          //                     duration: const Duration(seconds: 3),
                          //                     child: SizedBox(
                          //                       height: 100,
                          //                       width: 100,
                          //                       child: ClipOval(
                          //                         child: CustomListenerProfileImage(image: Database.fetchLoginUserProfileModel?.user?.profilePic ?? ''),
                          //                       ),
                          //                     ),
                          //                   ).paddingOnly(bottom: 14),
                          //                   Text(
                          //                     Database.fetchLoginUserProfileModel?.user?.nickName ?? '',
                          //                     style: AppFontStyle.fontStyleW700(
                          //                       fontSize: 14,
                          //                       fontColor: AppColors.black,
                          //                     ),
                          //                   ).paddingOnly(bottom: 8),
                          //                   // Container(
                          //                   //   padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          //                   //   decoration: BoxDecoration(
                          //                   //     borderRadius: BorderRadius.circular(46),
                          //                   //     gradient: LinearGradient(
                          //                   //       colors: [Color(0xffCF00FD), Color(0xff8400FF)],
                          //                   //     ),
                          //                   //   ),
                          //                   //   child: Text(
                          //                   //     " ${controller.randomAvailableListenerModel?.data?.talkTopics?[0] ?? ''}  ",
                          //                   //     style: AppFontStyle.fontStyleW600(
                          //                   //       fontSize: 10,
                          //                   //       fontColor: AppColors.white,
                          //                   //     ),
                          //                   //   ),
                          //                   // ),
                          //                 ],
                          //               ),
                          //               20.width,
                          //               Column(
                          //                 mainAxisAlignment: MainAxisAlignment.center,
                          //                 children: [
                          //                   RippleAnimation(
                          //                     color: AppColors.notificationTxt.withValues(alpha: 0.3),
                          //                     delay: const Duration(milliseconds: 100),
                          //                     repeat: true,
                          //                     minRadius: 65,
                          //                     maxRadius: 25,
                          //                     ripplesCount: 6,
                          //                     duration: const Duration(seconds: 3),
                          //                     child: SizedBox(
                          //                       height: 100,
                          //                       width: 100,
                          //                       child: ClipOval(
                          //                         child: CustomListenerProfileImage(image: controller.randomAvailableListenerModel?.data?.image ?? ''),
                          //                       ),
                          //                     ),
                          //                   ).paddingOnly(bottom: 14),
                          //                   Text(
                          //                     controller.randomAvailableListenerModel?.data?.name ?? '',
                          //                     style: AppFontStyle.fontStyleW700(
                          //                       fontSize: 14,
                          //                       fontColor: AppColors.black,
                          //                     ),
                          //                   ).paddingOnly(bottom: 8),
                          //                   // Container(
                          //                   //   padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          //                   //   decoration: BoxDecoration(
                          //                   //     borderRadius: BorderRadius.circular(46),
                          //                   //     gradient: LinearGradient(
                          //                   //       colors: [Color(0xffCF00FD), Color(0xff8400FF)],
                          //                   //     ),
                          //                   //   ),
                          //                   //   child: Text(
                          //                   //     " ${controller.randomAvailableListenerModel?.data?.talkTopics?[0] ?? ''}  ",
                          //                   //     style: AppFontStyle.fontStyleW600(
                          //                   //       fontSize: 10,
                          //                   //       fontColor: AppColors.white,
                          //                   //     ),
                          //                   //   ),
                          //                   // ),
                          //                 ],
                          //               ),
                          //             ],
                          //           ).paddingSymmetric(horizontal: 45),
                          //           Flexible(
                          //             child: Text(
                          //               textAlign: TextAlign.center,
                          //               "Random Match Connection...",
                          //               style: AppFontStyle.fontStyleKaushanW400(fontSize: 36, fontColor: AppColors.black),
                          //             ).paddingOnly(top: 32, left: 14, right: 14),
                          //           ),
                          //         ],
                          //       ).paddingOnly(top: Get.height * 0.12),
                          //     )
                          //   :
                          Positioned(
                        top: Get.height * 0.18,
                        bottom: Get.height * 0.17,
                        // bottom: 0,
                        left: (Get.width - 340) / 2,
                        child: SizedBox(
                          // color: AppColors.black,
                          // height: Get.height * 0.45,
                          width: Get.width * 0.55,
                          child: GetBuilder<RandomCallController>(
                            id: Constant.idGetListener,
                            builder: (controller) {
                              return Column(
                                children: List.generate(controller.allListener.take(4).length, (index) {
                                  final item = controller.randomDisplayList[index];
                                  bool isLeft = index % 2 == 0;

                                  return Align(
                                    alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        Get.toNamed(
                                          AppRoutes.profileDetailScreenView,
                                          arguments: item.id,
                                        );
                                      },
                                      child: SmoothNameTransition(
                                        fadeDuration: randomCallController.fadeDurations[index],
                                        delay: randomCallController.delays[index],
                                        onAnimationComplete: () => replaceListenerAt(index),

                                        key: ValueKey('name-${item.id}-${item.name}'),
                                        // name: item.name.toString(),
                                        // fadeDuration: Duration(milliseconds: 2500 + (index * 300)),
                                        // delay: Duration(milliseconds: 500 + (index * 150)),
                                        childWidget: Stack(
                                          alignment: Alignment.center,
                                          clipBehavior: Clip.none,
                                          children: [
                                            Container(
                                              // height: 52,
                                              padding: EdgeInsets.only(
                                                left: index == 3 ? 32 : 20,
                                                right: index == 3 ? 14 : 32,
                                                bottom: 7,
                                                top: 7,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.randomCallPurple,
                                                borderRadius: index == 3
                                                    ? BorderRadius.only(
                                                        bottomRight: Radius.circular(42),
                                                        topRight: Radius.circular(42),
                                                      )
                                                    : BorderRadius.only(
                                                        bottomLeft: Radius.circular(42),
                                                        topLeft: Radius.circular(42),
                                                      ),
                                                border: Border.all(color: AppColors.white, width: 2),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    item.name ?? '',
                                                    style: AppFontStyle.fontStyleW700(
                                                      fontSize: 12,
                                                      fontColor: AppColors.black,
                                                    ),
                                                  ).paddingOnly(bottom: 3),
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(46),
                                                      gradient: LinearGradient(
                                                        colors: [Color(0xffCF00FD), Color(0xff8400FF)],
                                                      ),
                                                    ),
                                                    child: Text(
                                                      " ${item.talkTopics?[0] ?? ''}  ",
                                                      style: AppFontStyle.fontStyleW600(
                                                        fontSize: 10,
                                                        fontColor: AppColors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Positioned(
                                              left: index == 3 ? -36 : null,
                                              right: index == 3 ? null : -36,
                                              child: Container(
                                                width: 62,
                                                height: 62,
                                                decoration: BoxDecoration(
                                                  border: Border.all(width: 4, color: AppColors.randomCallBorder),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Color(0xffCF00FD).withValues(alpha: 0.1),
                                                      blurRadius: 3,
                                                      offset: Offset(1, 1),
                                                      spreadRadius: 2.5,
                                                    ),
                                                  ],
                                                  shape: BoxShape.circle,
                                                ),
                                                child: ClipOval(
                                                  child: CustomProfileImage(
                                                    image: item.image ?? '',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ).paddingOnly(bottom: Get.height * 0.045),
                                  );
                                }),
                              );
                            },
                          ),
                          // child: RandomAnimatedListenerList(),
                        ),
                      );
                    }),

                /// loading
                if (controller.isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Center(
                        child: LoadingAnimationWidget.threeArchedCircle(
                          color: AppColors.appColor,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SmoothNameTransition extends StatefulWidget {
  final String? name;
  final VoidCallback onAnimationComplete;
  final Duration fadeDuration;
  final Duration delay;
  final Widget childWidget;

  const SmoothNameTransition({
    super.key,
    this.name,
    required this.onAnimationComplete,
    required this.fadeDuration,
    required this.delay,
    required this.childWidget,
  });

  @override
  SmoothNameTransitionState createState() => SmoothNameTransitionState();
}

class SmoothNameTransitionState extends State<SmoothNameTransition> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _isReversing = false;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.fadeDuration,
      vsync: this,
    );

    // Create smoother fade animation with gentler curve
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutQuart, // Smoother curve
    ));

    // Create more subtle scale animation
    _scaleAnimation = Tween<double>(
      begin: 0.98, // Less dramatic scale change
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic, // Gentler bounce
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isReversing) {
        // Wait longer before starting reverse animation
        Future.delayed(Duration(milliseconds: 800), () {
          // Increased from 300ms
          if (mounted) {
            _isReversing = true;
            _controller.reverse();
          }
        });
      } else if (status == AnimationStatus.dismissed && _isReversing) {
        // Animation cycle complete, trigger callback
        widget.onAnimationComplete();
        _isReversing = false;
        // Start the next cycle
        _controller.forward();
      }
    });

    // Start with delay
    Future.delayed(widget.delay, () {
      if (mounted && !_hasStarted) {
        _hasStarted = true;
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Clamp values to prevent out-of-range errors
        final fadeValue = _fadeAnimation.value.clamp(0.0, 1.0);
        final scaleValue = _scaleAnimation.value.clamp(0.95, 1.05); // Tighter range

        return Transform.scale(
          scale: scaleValue,
          child: Opacity(
            opacity: fadeValue,
            child: widget.childWidget,
          ),
        );
      },
    );
  }
}

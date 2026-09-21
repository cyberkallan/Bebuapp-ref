import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/on_boarding_screen/controller/on_boarding_controller.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/utils.dart';

/// First-run onboarding: three swipeable pages, skip, animated indicator and
/// a single primary action. Uses the existing [OnBoardingController].
class OnBoardingScreen extends GetView<OnBoardingController> {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
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
      },
      child: Scaffold(
        backgroundColor: BebuTheme.bg,
        body: AuroraBackground(
          intensity: 1.3,
          child: SafeArea(
            child: GetBuilder<OnBoardingController>(
              id: Constant.idOnBoarding,
              builder: (logic) {
                final last = logic.currentPage == logic.title.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 12, 0),
                      child: Row(
                        children: [
                          Text('bebu', style: BebuTheme.title(size: 20)),
                          const Spacer(),
                          AnimatedOpacity(
                            duration: BebuTheme.fast,
                            opacity: last ? 0 : 1,
                            child: TextButton(
                              onPressed: last ? null : _finish,
                              child: Text(EnumLocale.txtSkip.name.tr, style: BebuTheme.label(size: 14, color: BebuTheme.textMuted)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: logic.pageController,
                        onPageChanged: (page) => logic.onPageChanged(page: page),
                        itemCount: logic.title.length,
                        itemBuilder: (context, index) => _OnboardingPage(
                          controller: logic.pageController,
                          index: index,
                          image: logic.image[index].toString(),
                          title: logic.title[index].toString(),
                          subtitle: logic.subTitle[index].toString(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        children: [
                          _Dots(count: logic.title.length, index: logic.currentPage),
                          const SizedBox(height: 22),
                          GradientButton(
                            label: last ? 'Get started' : EnumLocale.txtNext.name.tr,
                            icon: last ? Icons.arrow_forward_rounded : null,
                            onTap: () => logic.onPageScroll(currentPage: logic.currentPage),
                          ),
                          const SizedBox(height: 12),
                          Text('Free to join · No card needed', style: BebuTheme.body(size: 12, color: BebuTheme.textFaint)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _finish() {
    Database.onSetSeenOnboarding(true);
    Get.offAllNamed(AppRoutes.main);
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.controller, required this.index, required this.image, required this.title, required this.subtitle});
  final PageController controller;
  final int index;
  final String image;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Parallax: the illustration drifts slower than the page.
        double offset = 0;
        if (controller.hasClients && controller.position.haveDimensions) {
          offset = (controller.page ?? index.toDouble()) - index;
        }
        final size = MediaQuery.sizeOf(context);
        final art = (size.width * 0.62).clamp(200.0, 300.0);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Transform.translate(
                offset: Offset(offset * -60, 0),
                child: Opacity(
                  opacity: (1 - offset.abs() * 0.6).clamp(0.0, 1.0),
                  child: SizedBox(
                    width: art,
                    height: art,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: art * 0.9,
                          height: art * 0.9,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(colors: [BebuTheme.violet.withValues(alpha: 0.45), BebuTheme.violet.withValues(alpha: 0)]),
                          ),
                        ),
                        Image.asset(image, width: art * 0.78, height: art * 0.78, fit: BoxFit.contain),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),
              Transform.translate(
                offset: Offset(offset * -24, 0),
                child: Opacity(
                  opacity: (1 - offset.abs()).clamp(0.0, 1.0),
                  child: Column(
                    children: [
                      Text(title, textAlign: TextAlign.center, style: BebuTheme.display(size: 32)),
                      const SizedBox(height: 14),
                      Text(subtitle, textAlign: TextAlign.center, style: BebuTheme.body(size: 15, height: 1.5)),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        );
      },
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: BebuTheme.normal,
            curve: BebuTheme.curve,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              gradient: i == index ? BebuTheme.violetGradient : null,
              color: i == index ? null : BebuTheme.surface3,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/on_boarding_screen/controller/on_boarding_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/font_style.dart';

class OnBoardingView extends StatelessWidget {
  const OnBoardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnBoardingController>(
      id: Constant.idOnBoarding,
      builder: (logic) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: PageView.builder(
                controller: logic.pageController,
                onPageChanged: (int page) {
                  logic.onPageChanged(page: page);
                },
                itemCount: logic.title.length,
                itemBuilder: (context, index) {
                  return OnboardingItemView(
                    title: logic.title[index],
                    image: logic.image[index],
                    subTitle: logic.subTitle[index],
                  );
                },
              ),
            ),
            Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(logic.title.length, (index) {
                        bool isSelected = index == logic.currentPage; // Check if this is the current page
                        return AnimatedContainer(
                          margin: EdgeInsets.only(right: 4),
                          width: isSelected ? 22 : 14, // Make the selected dot a bit bigger
                          height: isSelected ? 4 : 4, // Same as width for circle shape
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.appColor : AppColors.unSelected, // Change color based on selection
                            borderRadius: BorderRadius.circular(10), // Make it round
                          ),
                          duration: Duration(milliseconds: 300),
                        );
                      }),
                    ).paddingOnly(bottom: 53, left: 18),
                    const SizedBox(height: 30),
                  ],
                ).paddingOnly(top: Get.height * 0.1),
                Positioned(
                    bottom: Get.height * 0,
                    right: Get.width * -0.05,
                    child: GetBuilder<OnBoardingController>(
                      id: Constant.idOnBoarding,
                      builder: (logic) {
                        return GestureDetector(
                          onTap: () {
                            logic.onPageScroll(currentPage: logic.currentPage);
                          },
                          child: Image.asset(
                            AppAsset.onBoardingArrow,
                            height: 100,
                            width: 100,
                          ),
                        );
                      },
                    )),
              ],
            ),
          ],
        );
      },
    );
  }
}

class OnboardingItemView extends StatelessWidget {
  final String title;
  final String image;
  final String subTitle;

  const OnboardingItemView({
    super.key,
    required this.title,
    required this.image,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Image.asset(image, height: 360).paddingOnly(bottom: Get.height * 0.02, left: 34, right: 34),
        Text(
          title,
          style: AppFontStyle.fontStyleW800(
            fontSize: 40,
            letterSpace: Get.width * 0.013,
            fontColor: AppColors.black,
          ),
          textAlign: TextAlign.center,
        ).paddingOnly(left: 20, right: 20, bottom: 6),
        Text(
          subTitle,
          style: AppFontStyle.fontStyleW500(
            fontSize: 15,
            fontColor: AppColors.onBoardingTxt,
          ),
          textAlign: TextAlign.center,
        ).paddingOnly(left: 20, right: 20, bottom: 30),
      ],
    );
  }
}

class CustomArrowContainer extends StatelessWidget {
  const CustomArrowContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color similar to your image
      body: Center(
        child: Transform.scale(
          scale: 1.5, // Scale the container
          child: ClipPath(
            clipper: CustomShapeClipper(),
            child: Container(
              width: 80,
              height: 80,
              color: Colors.indigo[900], // Dark background like your image
              child: Center(
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.7);

    path.quadraticBezierTo(
      size.width * 0.7,
      size.height,
      size.width * 0.5,
      size.height,
    );

    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomShapeClipper oldClipper) => false;
}

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({super.key});

  @override
  LoadingIndicatorState createState() => LoadingIndicatorState();
}

class LoadingIndicatorState extends State<LoadingIndicator> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          margin: EdgeInsets.symmetric(horizontal: 5),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(5),
          ),
          duration: Duration(milliseconds: 300),
          transform: Matrix4.translationValues(0, 0, 0),
        );
      }),
    );
  }
}

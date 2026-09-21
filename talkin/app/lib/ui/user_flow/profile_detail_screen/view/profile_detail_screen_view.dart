import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/listeners/listener_actions.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/controller/profile_detail_screen_controller.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/widget/profile_detail_dark_widgets.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/utils.dart';

class ProfileDetailScreenView extends StatelessWidget {
  const ProfileDetailScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light);
    return Scaffold(
      backgroundColor: BebuTheme.bg,
      extendBody: true,
      bottomNavigationBar: const ProfileActionBar(),
      body: Stack(
        children: [
          GetBuilder<ProfileDetailScreenController>(
            id: Constant.listenerProfile,
            builder: (controller) {
              final d = controller.listenerProfileModel?.data;
              final bottomInset = MediaQuery.paddingOf(context).bottom;
              return RefreshIndicator(
                color: BebuTheme.pink,
                backgroundColor: BebuTheme.surface2,
                onRefresh: () => controller.onRefresh(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + 8, 16, 110 + bottomInset),
                  children: controller.isLoading || d == null
                      ? const [ProfileDarkShimmer()]
                      : [
                          FadeSlideIn(child: ProfileHeroCard(data: d, heroTag: 'listener-photo-${d.id}')),
                          const SizedBox(height: 14),
                          FadeSlideIn(
                            delayMs: 60,
                            child: ProfileMediaStrip(
                              data: d,
                              onVideoTap: () => ListenerActions.openTalkNow(
                                id: d.id,
                                name: d.name,
                                image: d.image,
                                ratePrivateAudioCall: d.ratePrivateAudioCall,
                                ratePrivateVideoCall: d.ratePrivateVideoCall,
                                isFake: d.isFake,
                                video: d.video,
                                audio: d.audio,
                                isAvailableForPrivateVideoCall: d.isAvailableForPrivateVideoCall,
                                isAvailableForPrivateAudioCall: d.isAvailableForPrivateAudioCall,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          FadeSlideIn(delayMs: 120, child: ProfileStats(data: d)),
                          const SizedBox(height: 14),
                          FadeSlideIn(delayMs: 180, child: ProfileAbout(text: d.selfIntro ?? '')),
                          const SizedBox(height: 14),
                          FadeSlideIn(delayMs: 240, child: ProfileMoreInfo(data: d)),
                          const SizedBox(height: 14),
                          const FadeSlideIn(delayMs: 300, child: ProfileReviews()),
                        ],
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 18,
            left: 26,
            child: GlassIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Get.back(),
              tooltip: 'Back',
            ),
          ),
        ],
      ),
    );
  }
}

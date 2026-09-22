import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/custom/motion/coin_3d.dart';
import 'package:talk_in/custom/motion/coin_burst.dart';
import 'package:talk_in/custom/motion/coin_pill.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/avatar_studio/controller/avatar_studio_controller.dart';
import 'package:talk_in/ui/user_flow/avatar_studio/model/avatar_studio_model.dart';
import 'package:talk_in/ui/user_flow/avatar_studio/widget/avatar_stage.dart';
import 'package:talk_in/utils/app_theme.dart';

/// Back, title, balance pill.
class StudioHeader extends StatelessWidget {
  const StudioHeader({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        children: [
          GlassIconButton(icon: Icons.arrow_back_rounded, size: 42, color: BebuTheme.surface, blur: false, onTap: onBack, tooltip: 'Back'),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Avatar Studio', style: BebuTheme.title(size: 18)),
                GetBuilder<AvatarStudioController>(
                  id: AvatarStudioController.idCoins,
                  builder: (c) => Text(
                    c.data == null ? 'Build your look' : '${c.unlockedCount} of ${c.totalPremium} premium items unlocked',
                    style: BebuTheme.body(size: 11.5, color: BebuTheme.textFaint),
                  ),
                ),
              ],
            ),
          ),
          GetBuilder<AvatarStudioController>(
            id: AvatarStudioController.idCoins,
            builder: (c) => CoinPill(coins: c.data?.coins ?? 0, height: 38, onTap: () => Get.toNamed(AppRoutes.myWalletScreen)),
          ),
        ],
      ),
    );
  }
}

/// The stage bound to the controller's current look.
class StudioStage extends StatelessWidget {
  const StudioStage({super.key, required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AvatarStudioController>(
      id: AvatarStudioController.idStage,
      builder: (c) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              Container(
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(BebuTheme.radiusXl),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: BebuTheme.isLight ? 0.18 : 0.5), blurRadius: 30, offset: const Offset(0, 14))],
                ),
                child: AvatarStage(look: c.stageLook, revision: c.stageRevision),
              ),
              // try-on badge
              if (c.tryOn != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: FadeSlideIn(
                    offset: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: c.tryOn!.rarity.gradient,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [BoxShadow(color: c.tryOn!.rarity.color.withValues(alpha: 0.5), blurRadius: 14)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome_rounded, size: 13, color: Colors.white),
                          const SizedBox(width: 5),
                          Text('Trying on ${c.tryOn!.name}', style: BebuTheme.label(size: 11.5, color: Colors.white, weight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(999)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.threed_rotation_rounded, size: 13, color: Colors.white.withValues(alpha: 0.85)),
                      const SizedBox(width: 5),
                      Text('Drag to look around', style: BebuTheme.body(size: 10.5, color: Colors.white.withValues(alpha: 0.85))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Horizontal category tabs with the 3D icon of each slot.
class StudioTabs extends StatelessWidget {
  const StudioTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AvatarStudioController>(
      id: AvatarStudioController.idGrid,
      builder: (c) {
        return SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: StudioSlot.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final s = StudioSlot.values[i];
              final on = c.slot == s;
              final equipped = c.stageItem(s) != null;
              return PressScale(
                scale: 0.94,
                onTap: () => c.selectSlot(s),
                child: AnimatedContainer(
                  duration: BebuTheme.fast,
                  curve: BebuTheme.curve,
                  width: 74,
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(BebuTheme.radiusMd),
                    gradient: on ? BebuTheme.pinkGradient : null,
                    color: on ? null : BebuTheme.surface,
                    border: Border.all(color: on ? Colors.transparent : BebuTheme.border),
                    boxShadow: on ? [BoxShadow(color: BebuTheme.pink.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))] : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Image.asset('assets/avatar_studio/${s.iconKey}.webp', width: 30, height: 30, cacheWidth: 90),
                          if (equipped && !on)
                            Positioned(
                              right: -4,
                              top: -3,
                              child: Container(width: 9, height: 9, decoration: BoxDecoration(shape: BoxShape.circle, color: BebuTheme.green, border: Border.all(color: BebuTheme.surface, width: 1.5))),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(s.label, style: BebuTheme.label(size: 11, color: on ? Colors.white : BebuTheme.textMuted)),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Item grid for the selected slot (+ gender switch on the Avatar tab).
class StudioGrid extends StatelessWidget {
  const StudioGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AvatarStudioController>(
      id: AvatarStudioController.idGrid,
      builder: (c) {
        final items = c.visibleItems;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_title(c.slot), style: BebuTheme.title(size: 16)),
                        const SizedBox(height: 2),
                        Text(_hint(c.slot), style: BebuTheme.body(size: 11.5, color: BebuTheme.textFaint)),
                      ],
                    ),
                  ),
                  if (c.slot == StudioSlot.avatar)
                    SizedBox(
                      width: 150,
                      child: SegmentedPill(
                        height: 36,
                        index: c.genderFilter == 'female' ? 1 : 0,
                        onChanged: (i) => c.setGender(i == 1 ? 'female' : 'male'),
                        segments: const [SegmentItem('Male', Icons.male_rounded), SegmentItem('Female', Icons.female_rounded)],
                      ),
                    ),
                ],
              ),
            ),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                child: GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, color: BebuTheme.textMuted),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Nothing here yet. New items arrive with updates.', style: BebuTheme.body(size: 13))),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.78),
                itemCount: items.length,
                itemBuilder: (_, i) => FadeSlideIn(
                  key: ValueKey('${c.slot.name}-${items[i].id}'),
                  delayMs: (i % 9) * 30,
                  offset: 10,
                  child: StudioItemCard(item: items[i], owned: c.owns(items[i]), onStage: c.isEquippedOnStage(items[i]), tryingOn: c.tryOn?.id == items[i].id, bonus: c.bonusFor(items[i]), onTap: () => c.tapItem(items[i])),
                ),
              ),
          ],
        );
      },
    );
  }

  static String _title(StudioSlot s) => switch (s) {
        StudioSlot.avatar => 'Pick your avatar',
        StudioSlot.background => 'Set the scene',
        StudioSlot.accessory => 'Add some style',
        StudioSlot.pet => 'Choose a companion',
        StudioSlot.vehicle => 'Your ride',
        StudioSlot.home => 'Where you live',
        StudioSlot.sky => 'Own the sky',
      };

  static String _hint(StudioSlot s) => switch (s) {
        StudioSlot.avatar => 'This is the face others see on your profile and calls',
        StudioSlot.background => 'Colours and lights behind your avatar',
        StudioSlot.accessory => 'Tap again to take it off',
        StudioSlot.pet => 'Sits beside you · tap again to remove',
        StudioSlot.vehicle => 'Parked on the stage · tap again to remove',
        StudioSlot.home => 'Shown behind you · tap again to remove',
        StudioSlot.sky => 'Flies above the scene · tap again to remove',
      };
}

/// One catalog tile: rarity frame, 3D render, name and price / owned state.
class StudioItemCard extends StatelessWidget {
  const StudioItemCard({super.key, required this.item, required this.owned, required this.onStage, required this.tryingOn, required this.onTap, this.bonus = 0});
  final AvatarItem item;
  final int bonus;
  final bool owned;
  final bool onStage;
  final bool tryingOn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = item.rarity;
    final highlight = onStage || tryingOn;
    final glow = r == Rarity.epic || r == Rarity.legendary;
    return PressScale(
      scale: 0.95,
      onTap: onTap,
      child: AnimatedContainer(
        duration: BebuTheme.fast,
        curve: BebuTheme.curve,
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BebuTheme.radiusMd),
          gradient: highlight ? BebuTheme.pinkGradient : (r == Rarity.common ? null : r.gradient),
          color: r == Rarity.common && !highlight ? BebuTheme.border : null,
          boxShadow: [
            if (highlight) BoxShadow(color: BebuTheme.pink.withValues(alpha: 0.4), blurRadius: 18, offset: const Offset(0, 6)),
            if (!highlight && glow) BoxShadow(color: r.color.withValues(alpha: 0.28), blurRadius: 14, offset: const Offset(0, 4)),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BebuTheme.radiusMd - 1.5),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.alphaBlend(r.color.withValues(alpha: r == Rarity.common ? 0.0 : 0.16), BebuTheme.surface), BebuTheme.surface],
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 12, 8, 2),
                      child: item.slot == StudioSlot.background ? _SceneSwatch(item: item) : StudioImage(item, size: 96),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
                    child: Column(
                      children: [
                        Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.label(size: 12)),
                        const SizedBox(height: 5),
                        _Price(item: item, owned: owned, onStage: onStage, bonus: bonus),
                      ],
                    ),
                  ),
                ],
              ),
              // rarity tag
              if (r != Rarity.common)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(color: r.color.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(5)),
                    child: Text(r.label.toUpperCase(), style: BebuTheme.label(size: 7.5, color: r.color, weight: FontWeight.w800)),
                  ),
                ),
              if (!owned)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withValues(alpha: 0.45)),
                    child: const Icon(Icons.lock_rounded, size: 11, color: Colors.white),
                  ),
                ),
              if (onStage)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(shape: BoxShape.circle, gradient: BebuTheme.pinkGradient, boxShadow: [BoxShadow(color: BebuTheme.pink.withValues(alpha: 0.5), blurRadius: 8)]),
                    child: const Icon(Icons.check_rounded, size: 13, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SceneSwatch extends StatelessWidget {
  const _SceneSwatch({required this.item});
  final AvatarItem item;

  @override
  Widget build(BuildContext context) {
    final colors = item.colors.length >= 2 ? item.colors : [BebuTheme.surface2, BebuTheme.surface3];
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(BebuTheme.radiusSm), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors)),
      child: Center(child: StudioImage(item, size: 52)),
    );
  }
}

class _Price extends StatelessWidget {
  const _Price({required this.item, required this.owned, required this.onStage, this.bonus = 0});
  final AvatarItem item;
  final bool owned;
  final bool onStage;
  final int bonus;

  @override
  Widget build(BuildContext context) {
    if (onStage) {
      return Text('On stage', style: BebuTheme.label(size: 10.5, color: BebuTheme.pink, weight: FontWeight.w700));
    }
    if (owned) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.isFree ? Icons.lock_open_rounded : Icons.check_circle_rounded, size: 12, color: BebuTheme.green),
          const SizedBox(width: 3),
          Text(item.isFree ? 'Free' : 'Owned', style: BebuTheme.label(size: 10.5, color: BebuTheme.green, weight: FontWeight.w700)),
        ],
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: BebuTheme.amber.withValues(alpha: BebuTheme.isLight ? 0.16 : 0.18), borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Coin3D(size: 11),
          const SizedBox(width: 4),
          Text('${item.coins}', style: BebuTheme.label(size: 11, color: BebuTheme.isLight ? const Color(0xFF92400E) : BebuTheme.amber, weight: FontWeight.w800)),
          if (bonus > 0) ...[
            const SizedBox(width: 4),
            Text('+$bonus back', style: BebuTheme.label(size: 9.5, color: BebuTheme.green, weight: FontWeight.w800)),
          ],
        ],
      ),
    );
  }
}

/// Docked action: unlock the try-on, or save the look.
class StudioActionBar extends StatelessWidget {
  const StudioActionBar({super.key, required this.onUnlock, required this.onSave});
  final VoidCallback onUnlock;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return GetBuilder<AvatarStudioController>(
      id: AvatarStudioController.idBar,
      builder: (c) {
        final t = c.tryOn;
        final canAfford = t != null && (c.data?.coins ?? 0) >= t.coins;
        return Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, bottom + 12),
          decoration: BoxDecoration(
            color: BebuTheme.bg.withValues(alpha: 0.94),
            border: Border(top: BorderSide(color: BebuTheme.border)),
          ),
          child: t != null
              ? Row(
                  children: [
                    GhostButton(label: 'Cancel', expanded: false, height: 52, onTap: c.cancelTryOn),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GradientButton(
                        height: 52,
                        loading: c.unlocking,
                        gradient: canAfford ? t.rarity.gradient : const LinearGradient(colors: [Color(0xFFFFC44D), Color(0xFFF08A00)]),
                        glow: canAfford ? t.rarity.color : BebuTheme.amber,
                        icon: canAfford ? Icons.lock_open_rounded : Icons.add_rounded,
                        label: canAfford
                            ? 'Unlock for ${t.coins} coins${c.bonusFor(t) > 0 ? ' · +${c.bonusFor(t)} back' : ''}'
                            : 'Need ${t.coins - (c.data?.coins ?? 0)} more coins · Top up',
                        onTap: onUnlock,
                      ),
                    ),
                  ],
                )
              : GradientButton(
                  height: 52,
                  loading: c.saving,
                  gradient: BebuTheme.pinkGradient,
                  glow: BebuTheme.pink,
                  icon: c.isDirty ? Icons.check_rounded : Icons.favorite_rounded,
                  label: c.isDirty ? 'Save my look' : 'Looking great',
                  onTap: c.isDirty ? onSave : null,
                ),
        );
      },
    );
  }
}

/// Full-screen celebration after a premium unlock.
class UnlockCelebration extends StatelessWidget {
  const UnlockCelebration({super.key, required this.item, required this.onDone, this.bonus = 0});
  final AvatarItem item;
  final VoidCallback onDone;

  /// Coins paid back for this unlock; shows a counting chip when > 0.
  final int bonus;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDone,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black.withValues(alpha: 0.72)),
          const CoinBurst(coins: 18, confetti: 60, origin: Alignment(0, -0.15)),
          Center(
            child: FadeSlideIn(
              offset: 30,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      const PulseRings(size: 240, color: Colors.white),
                      Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [item.rarity.color.withValues(alpha: 0.55), item.rarity.color.withValues(alpha: 0)]),
                        ),
                      ),
                      StudioImage(item, size: 150),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(gradient: item.rarity.gradient, borderRadius: BorderRadius.circular(999)),
                    child: Text(item.rarity.label.toUpperCase(), style: BebuTheme.label(size: 10.5, color: Colors.white, weight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 10),
                  Text('${item.name} unlocked', style: BebuTheme.display(size: 28, color: Colors.white)),
                  const SizedBox(height: 6),
                  Text('It is on your stage. Tap anywhere to continue.', style: BebuTheme.body(size: 13.5, color: Colors.white.withValues(alpha: 0.75))),
                  if (bonus > 0) ...[
                    const SizedBox(height: 18),
                    _BonusChip(bonus: bonus),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "+N coins back" pill that pops in and counts up after the unlock lands.
class _BonusChip extends StatelessWidget {
  const _BonusChip({required this.bonus});
  final int bonus;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: BebuTheme.reducedMotion ? const Duration(milliseconds: 1) : const Duration(milliseconds: 900),
      curve: Curves.easeOutBack,
      builder: (_, v, __) {
        final n = (bonus * Curves.easeOutCubic.transform(v.clamp(0, 1))).round();
        return Transform.scale(
          scale: 0.6 + 0.4 * v.clamp(0, 1.15),
          child: Opacity(
            opacity: v.clamp(0, 1),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [BebuTheme.green.withValues(alpha: 0.32), BebuTheme.amber.withValues(alpha: 0.28)]),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Coin3D(size: 20),
                  const SizedBox(width: 8),
                  Text('+$n coins back', style: BebuTheme.label(size: 14, color: Colors.white, weight: FontWeight.w800).copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                  const SizedBox(width: 6),
                  Text('premium bonus', style: BebuTheme.body(size: 12, color: Colors.white.withValues(alpha: 0.8))),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class StudioShimmer extends StatelessWidget {
  const StudioShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: BebuTheme.surface,
      highlightColor: BebuTheme.surface3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(height: 300, decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(BebuTheme.radiusXl))),
            const SizedBox(height: 14),
            Row(children: [for (var i = 0; i < 4; i++) Expanded(child: Container(height: 64, margin: EdgeInsets.only(right: i == 3 ? 0 : 8), decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(BebuTheme.radiusMd))))]),
            const SizedBox(height: 14),
            Row(children: [for (var i = 0; i < 3; i++) Expanded(child: Container(height: 130, margin: EdgeInsets.only(right: i == 2 ? 0 : 10), decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(BebuTheme.radiusMd))))]),
          ],
        ),
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:talk_in/custom/custom_country_picker/country_picker.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/custom/motion/coin_3d.dart';
import 'package:talk_in/custom/motion/presence_badge.dart';
import 'package:talk_in/ui/user_flow/sign_in_screen/controller/sign_in_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/login_config.dart';
import 'package:talk_in/utils/utils.dart';

String _fmt(num n) => NumberFormat.decimalPattern().format(n);

/// Sign-in. One screen, three panels: pick a method, type a number, type the
/// code. Which buttons appear and which one is the hero come from the admin
/// panel ([LoginConfig]). Everything fits without scrolling on a 640 px tall
/// phone and scrolls gracefully with the keyboard open.
class SignInScreen extends GetView<SignInController> {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: BebuTheme.statusBarIcons);
    return GetBuilder<SignInController>(
      id: SignInController.idStep,
      builder: (c) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            if (c.step != SignInStep.methods) {
              c.back();
              return;
            }
            Get.dialog(
              barrierColor: Colors.black.withValues(alpha: 0.8),
              Dialog(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, surfaceTintColor: Colors.transparent, elevation: 0, child: const ExitAppDialog()),
            );
          },
          child: Scaffold(
            backgroundColor: BebuTheme.bg,
            resizeToAvoidBottomInset: true,
            body: AuroraBackground(
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, box) {
                    final compact = box.maxHeight < 700;
                    return AnimatedSwitcher(
                      duration: BebuTheme.normal,
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(position: Tween(begin: const Offset(0.06, 0), end: Offset.zero).animate(anim), child: child),
                      ),
                      layoutBuilder: (current, previous) => Stack(alignment: Alignment.topCenter, children: [...previous, if (current != null) current]),
                      child: KeyedSubtree(
                        key: ValueKey(c.step),
                        child: SingleChildScrollView(
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: box.maxHeight),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
                              child: switch (c.step) {
                                SignInStep.methods => _MethodsPanel(compact: compact),
                                SignInStep.phone => const _PhonePanel(),
                                SignInStep.otp => const _OtpPanel(),
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Methods
// ---------------------------------------------------------------------------

class _MethodsPanel extends GetView<SignInController> {
  const _MethodsPanel({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cfg = controller.config;
    final teaser = controller.teaser;
    final hero = cfg.hero;
    final secondary = cfg.secondary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: compact ? 6 : 18),
            FadeSlideIn(
              child: Row(
                children: [
                  _LogoMark(size: compact ? 44 : 52),
                  const SizedBox(width: 12),
                  Text('bebu', style: BebuTheme.title(size: 24, weight: FontWeight.w800)),
                  const SizedBox(width: 12),
                  const Flexible(child: Align(alignment: Alignment.centerRight, child: FittedBox(fit: BoxFit.scaleDown, child: _LivePill()))),
                ],
              ),
            ),
            SizedBox(height: compact ? 22 : 34),
            FadeSlideIn(
              delayMs: 60,
              child: Text(
                cfg.headline.isNotEmpty ? cfg.headline : 'Real people.\nReal talk.',
                style: BebuTheme.display(size: compact ? 36 : 42).copyWith(height: 1.02, letterSpacing: -1.2),
              ),
            ),
            const SizedBox(height: 12),
            FadeSlideIn(
              delayMs: 120,
              child: Text(
                'Voice and video calls with hosts who actually listen. Free to start, pay only for the minutes you talk.',
                style: BebuTheme.body(size: 15, color: BebuTheme.textMuted, height: 1.4),
              ),
            ),
            SizedBox(height: compact ? 16 : 22),
            if (cfg.showWelcomeBonus && (teaser.welcomeCoins > 0 || (teaser.dailyEnabled && teaser.dayOne > 0)))
              FadeSlideIn(delayMs: 180, child: _BonusTeaser(teaser: teaser)),
            SizedBox(height: compact ? 14 : 20),
            FadeSlideIn(
              delayMs: 240,
              child: Column(
                children: const [
                  _ValueRow(icon: Icons.translate_rounded, text: 'Hosts who speak your language'),
                  _ValueRow(icon: Icons.timer_outlined, text: 'Pay per minute with coins, no subscription'),
                  _ValueRow(icon: Icons.lock_outline_rounded, text: 'Your number and identity stay private'),
                ],
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: compact ? 18 : 26),
            FadeSlideIn(delayMs: 300, child: _HeroButton(method: hero)),
            const SizedBox(height: 8),
            FadeSlideIn(
              delayMs: 340,
              child: Text(_heroHint(hero), textAlign: TextAlign.center, style: BebuTheme.label(size: 12, color: BebuTheme.textFaint)),
            ),
            if (secondary.isNotEmpty) ...[
              const SizedBox(height: 14),
              FadeSlideIn(
                delayMs: 380,
                child: Row(
                  children: [
                    Expanded(child: Divider(color: BebuTheme.border)),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('or', style: BebuTheme.label(size: 12, color: BebuTheme.textFaint))),
                    Expanded(child: Divider(color: BebuTheme.border)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FadeSlideIn(
                delayMs: 420,
                child: secondary.length == 1
                    ? _SecondaryButton(method: secondary.first)
                    : secondary.length == 2
                        ? Row(
                            children: [
                              for (var i = 0; i < secondary.length; i++) ...[
                                if (i > 0) const SizedBox(width: 10),
                                Expanded(child: _SecondaryButton(method: secondary[i], short: true)),
                              ],
                            ],
                          )
                        : Column(
                            children: [
                              for (var i = 0; i < secondary.length; i++) ...[
                                if (i > 0) const SizedBox(height: 10),
                                _SecondaryButton(method: secondary[i]),
                              ],
                            ],
                          ),
              ),
            ],
            const SizedBox(height: 16),
            const FadeSlideIn(delayMs: 460, child: _Consent()),
          ],
        ),
      ],
    );
  }

  static String _heroHint(LoginMethod m) => switch (m) {
        LoginMethod.google => 'Takes 5 seconds. No password to remember.',
        LoginMethod.phone => 'We’ll text you a 6-digit code. No password.',
        LoginMethod.quick => 'Start instantly. You can add a number or email later.',
        LoginMethod.email => 'Use your email and a password.',
      };
}

class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: BebuTheme.pink.withValues(alpha: 0.35), blurRadius: 22, spreadRadius: -2)],
      ),
      child: Image.asset(AppAsset.logoMark, fit: BoxFit.contain),
    );
  }
}

/// "Hosts online now" — a live indicator without a made-up number.
class _LivePill extends StatelessWidget {
  const _LivePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 11, 6),
      decoration: BoxDecoration(color: BebuTheme.surface.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(999), border: Border.all(color: BebuTheme.border)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PresenceBadge(presence: Presence.online, size: 12, pulse: true),
          const SizedBox(width: 6),
          Text('Hosts online now', style: BebuTheme.label(size: 11.5, color: BebuTheme.textMuted)),
        ],
      ),
    );
  }
}

/// Amber pill that puts a number on the reward for finishing sign-in.
class _BonusTeaser extends StatefulWidget {
  const _BonusTeaser({required this.teaser});
  final RewardTeaser teaser;

  @override
  State<_BonusTeaser> createState() => _BonusTeaserState();
}

class _BonusTeaserState extends State<_BonusTeaser> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 5200));

  @override
  void initState() {
    super.initState();
    if (BebuTheme.coinAnimation) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.teaser;
    final String headline;
    final String sub;
    if (t.welcomeCoins > 0) {
      headline = '${_fmt(t.welcomeCoins)} free coins when you join';
      sub = t.dailyEnabled ? 'plus a daily gift that grows to ${_fmt(t.dailyCoins.reduce(math.max))} coins' : 'enough for your first conversation';
    } else {
      headline = '${_fmt(t.dayOne)} free coins on your first day';
      sub = 'come back daily and the gift grows to ${_fmt(t.dailyCoins.reduce(math.max))}';
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [BebuTheme.amber.withValues(alpha: BebuTheme.isLight ? 0.16 : 0.20), BebuTheme.surface.withValues(alpha: 0.85)]),
        borderRadius: BorderRadius.circular(BebuTheme.radiusMd),
        border: Border.all(color: BebuTheme.amber.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, __) => Coin3D(size: 34, yaw: CoinMotion.yaw(_c.value), pitch: 0.14, shine: CoinMotion.shine(_c.value)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(headline, style: BebuTheme.label(size: 13.5, color: BebuTheme.amber, weight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(sub, style: BebuTheme.body(size: 12, color: BebuTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(shape: BoxShape.circle, color: BebuTheme.violet.withValues(alpha: BebuTheme.isLight ? 0.12 : 0.22)),
            child: Icon(icon, size: 14, color: BebuTheme.isLight ? BebuTheme.violetDeep : const Color(0xFFC4B5FD)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: BebuTheme.body(size: 13.5, color: BebuTheme.textMuted))),
        ],
      ),
    );
  }
}

// ---- buttons ---------------------------------------------------------------

String _label(LoginMethod m) => switch (m) {
      LoginMethod.google => 'Continue with Google',
      LoginMethod.phone => 'Continue with phone',
      LoginMethod.quick => 'Try it now, no sign-up',
      LoginMethod.email => 'Continue with email',
    };

String _short(LoginMethod m) => switch (m) {
      LoginMethod.google => 'Google',
      LoginMethod.phone => 'Phone',
      LoginMethod.quick => 'Guest',
      LoginMethod.email => 'Email',
    };

Widget _glyph(LoginMethod m, {double size = 20, Color? color}) => switch (m) {
      LoginMethod.google => Image.asset(AppAsset.googleIcon, width: size, height: size),
      LoginMethod.phone => Icon(Icons.phone_iphone_rounded, size: size, color: color),
      LoginMethod.quick => Icon(Icons.bolt_rounded, size: size + 2, color: color),
      LoginMethod.email => Icon(Icons.alternate_email_rounded, size: size, color: color),
    };

class _HeroButton extends GetView<SignInController> {
  const _HeroButton({required this.method});
  final LoginMethod method;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignInController>(
      id: SignInController.idBusy,
      builder: (c) {
        final busy = c.busy == method;
        final disabled = c.busy != null && !busy;
        if (method == LoginMethod.google) {
          // Google's brand guidance: a light button with the G logo reads as trustworthy.
          return PressScale(
            onTap: disabled || busy ? null : () => c.onMethodTap(method),
            child: AnimatedOpacity(
              duration: BebuTheme.fast,
              opacity: disabled ? 0.5 : 1,
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: BebuTheme.isLight ? 0.12 : 0.45), blurRadius: 24, offset: const Offset(0, 10))],
                ),
                child: Center(
                  child: busy
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Color(0xFF1D1D1F)))
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _glyph(method, size: 22),
                                const SizedBox(width: 10),
                                Text(_label(method), style: BebuTheme.label(size: 16, weight: FontWeight.w700, color: const Color(0xFF1D1D1F))),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ),
          );
        }
        return GradientButton(
          label: _label(method),
          icon: switch (method) { LoginMethod.phone => Icons.phone_iphone_rounded, LoginMethod.quick => Icons.bolt_rounded, _ => Icons.alternate_email_rounded },
          gradient: BebuTheme.pinkGradient,
          glow: BebuTheme.pink,
          height: 58,
          loading: busy,
          onTap: disabled ? null : () => c.onMethodTap(method),
        );
      },
    );
  }
}

class _SecondaryButton extends GetView<SignInController> {
  const _SecondaryButton({required this.method, this.short = false});
  final LoginMethod method;
  final bool short;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignInController>(
      id: SignInController.idBusy,
      builder: (c) {
        final busy = c.busy == method;
        final disabled = c.busy != null && !busy;
        return PressScale(
          onTap: disabled || busy ? null : () => c.onMethodTap(method),
          child: AnimatedOpacity(
            duration: BebuTheme.fast,
            opacity: disabled ? 0.5 : 1,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: BebuTheme.surface.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(999), border: Border.all(color: BebuTheme.borderStrong)),
              child: Center(
                child: busy
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.2, color: BebuTheme.text))
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _glyph(method, size: 19, color: BebuTheme.text),
                            const SizedBox(width: 9),
                            Text(short ? _short(method) : _label(method), style: BebuTheme.label(size: 14.5)),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Consent extends GetView<SignInController> {
  const _Consent();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignInController>(
      id: SignInController.idConsent,
      builder: (c) {
        final link = TextStyle(color: BebuTheme.text, decoration: TextDecoration.underline, decorationColor: BebuTheme.textFaint);
        final text = Text.rich(
          TextSpan(
            style: BebuTheme.body(size: 12, color: BebuTheme.textFaint, height: 1.35),
            children: [
              TextSpan(text: c.config.requireConsentCheckbox ? 'I agree to the ' : 'By continuing you agree to our '),
              TextSpan(text: 'Terms', style: link),
              const TextSpan(text: ' and '),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: GestureDetector(onTap: c.openPrivacyPolicy, child: Text('Privacy Policy', style: BebuTheme.body(size: 12, color: BebuTheme.text).merge(link))),
              ),
              const TextSpan(text: '.'),
            ],
          ),
          textAlign: c.config.requireConsentCheckbox ? TextAlign.start : TextAlign.center,
        );
        if (!c.config.requireConsentCheckbox) return text;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: c.toggleAgreed,
          child: Row(
            children: [
              AnimatedContainer(
                duration: BebuTheme.fast,
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  gradient: c.agreed ? BebuTheme.pinkGradient : null,
                  color: c.agreed ? null : BebuTheme.surface2,
                  border: Border.all(color: c.agreed ? Colors.transparent : BebuTheme.borderStrong, width: 1.4),
                ),
                child: c.agreed ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
              ),
              const SizedBox(width: 10),
              Expanded(child: text),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Phone
// ---------------------------------------------------------------------------

class _StepHeader extends GetView<SignInController> {
  const _StepHeader({required this.title, required this.subtitle});
  final String title;
  final Widget subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GlassIconButton(icon: Icons.arrow_back_rounded, size: 42, color: BebuTheme.surface, blur: false, onTap: controller.back, tooltip: 'Back'),
          ],
        ),
        const SizedBox(height: 26),
        Text(title, style: BebuTheme.display(size: 30).copyWith(letterSpacing: -0.8)),
        const SizedBox(height: 8),
        subtitle,
      ],
    );
  }
}

class _PhonePanel extends GetView<SignInController> {
  const _PhonePanel();

  String _flag(String code) {
    if (code.length != 2) return '🌐';
    final upper = code.toUpperCase();
    return String.fromCharCodes(upper.codeUnits.map((u) => 0x1F1E6 + (u - 65)));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignInController>(
      id: SignInController.idPhone,
      builder: (c) {
        return GetBuilder<SignInController>(
          id: SignInController.idBusy,
          builder: (_) {
            final busy = c.busy == LoginMethod.phone;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StepHeader(
                  title: 'What’s your number?',
                  subtitle: Text('We’ll text you a one-time code. Your number is never shown to hosts.', style: BebuTheme.body(size: 14.5, color: BebuTheme.textMuted, height: 1.4)),
                ),
                const SizedBox(height: 28),
                Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: BebuTheme.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(BebuTheme.radiusMd),
                    border: Border.all(color: c.phoneError != null ? BebuTheme.red : BebuTheme.borderStrong, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      PressScale(
                        onTap: () => CustomCountryPicker.pickCountry(context, false, (country) => c.setCountry(dial: country.phoneCode, code: country.countryCode)),
                        child: Container(
                          height: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(border: Border(right: BorderSide(color: BebuTheme.border))),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_flag(c.countryCode), style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 6),
                              Text(c.dialCode, style: BebuTheme.label(size: 17, weight: FontWeight.w700)),
                              Icon(Icons.expand_more_rounded, size: 18, color: BebuTheme.textFaint),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: c.phoneController,
                          focusNode: c.phoneFocus,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.telephoneNumberNational],
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(15)],
                          style: BebuTheme.title(size: 22, weight: FontWeight.w700).copyWith(letterSpacing: 1.2),
                          cursorColor: BebuTheme.pink,
                          onSubmitted: (_) => c.sendOtp(),
                          decoration: InputDecoration(
                            hintText: 'Mobile number',
                            hintStyle: BebuTheme.title(size: 18, weight: FontWeight.w500, color: BebuTheme.textFaint),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedSize(
                  duration: BebuTheme.fast,
                  child: c.phoneError == null
                      ? const SizedBox(height: 14)
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline_rounded, size: 15, color: BebuTheme.red),
                              const SizedBox(width: 6),
                              Expanded(child: Text(c.phoneError!, style: BebuTheme.label(size: 12.5, color: BebuTheme.red))),
                            ],
                          ),
                        ),
                ),
                GradientButton(
                  label: 'Send code',
                  icon: Icons.sms_outlined,
                  gradient: BebuTheme.pinkGradient,
                  glow: BebuTheme.pink,
                  height: 58,
                  loading: busy,
                  onTap: busy ? null : c.sendOtp,
                ),
                const SizedBox(height: 12),
                Text('Standard SMS rates may apply.', textAlign: TextAlign.center, style: BebuTheme.label(size: 12, color: BebuTheme.textFaint)),
              ],
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// OTP
// ---------------------------------------------------------------------------

class _OtpPanel extends GetView<SignInController> {
  const _OtpPanel();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignInController>(
      id: SignInController.idOtp,
      builder: (c) {
        return GetBuilder<SignInController>(
          id: SignInController.idBusy,
          builder: (_) {
            final sending = c.busy == LoginMethod.phone;
            final code = c.otpController.text;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StepHeader(
                  title: 'Enter the code',
                  subtitle: Text.rich(
                    TextSpan(
                      style: BebuTheme.body(size: 14.5, color: BebuTheme.textMuted, height: 1.4),
                      children: [
                        const TextSpan(text: 'Sent to '),
                        TextSpan(text: c.fullPhone, style: BebuTheme.label(size: 14.5, color: BebuTheme.text)),
                        const TextSpan(text: '  ·  '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: GestureDetector(
                            onTap: c.back,
                            child: Text('Change', style: BebuTheme.label(size: 14, color: BebuTheme.pink)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _OtpBoxes(code: code, error: c.otpError != null, verifying: c.verifying, onTap: () => c.otpFocus.requestFocus()),
                // Invisible field that owns the keyboard; the boxes above mirror it.
                SizedBox(
                  height: 1,
                  width: 1,
                  child: Opacity(
                    opacity: 0,
                    child: TextField(
                      controller: c.otpController,
                      focusNode: c.otpFocus,
                      keyboardType: TextInputType.number,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                      onChanged: c.onOtpChanged,
                      enableInteractiveSelection: false,
                      showCursor: false,
                      decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: BebuTheme.fast,
                  child: c.otpError == null
                      ? const SizedBox(height: 18)
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(4, 12, 4, 12),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline_rounded, size: 15, color: BebuTheme.red),
                              const SizedBox(width: 6),
                              Expanded(child: Text(c.otpError!, style: BebuTheme.label(size: 12.5, color: BebuTheme.red))),
                            ],
                          ),
                        ),
                ),
                GradientButton(
                  label: c.verifying ? 'Verifying…' : 'Verify',
                  icon: c.verifying ? null : Icons.check_rounded,
                  gradient: BebuTheme.pinkGradient,
                  glow: BebuTheme.pink,
                  height: 58,
                  loading: c.verifying,
                  onTap: code.length == 6 && !c.verifying ? c.verifyOtp : null,
                ),
                const SizedBox(height: 14),
                Center(
                  child: c.resendIn > 0
                      ? Text('Resend code in 0:${c.resendIn.toString().padLeft(2, '0')}', style: BebuTheme.label(size: 13, color: BebuTheme.textFaint))
                      : TextButton(
                          onPressed: sending ? null : () => c.sendOtp(resend: true),
                          child: sending
                              ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: BebuTheme.textMuted))
                              : Text('Didn’t get it? Resend code', style: BebuTheme.label(size: 13.5, color: BebuTheme.pink)),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _OtpBoxes extends StatelessWidget {
  const _OtpBoxes({required this.code, required this.error, required this.verifying, required this.onTap});
  final String code;
  final bool error;
  final bool verifying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = code.length.clamp(0, 5);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          for (var i = 0; i < 6; i++) ...[
            if (i > 0) SizedBox(width: i == 3 ? 14 : 8),
            Expanded(
              child: AnimatedContainer(
                duration: BebuTheme.fast,
                height: 62,
                decoration: BoxDecoration(
                  color: BebuTheme.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(BebuTheme.radiusSm + 2),
                  border: Border.all(
                    color: error
                        ? BebuTheme.red
                        : i == active && code.length < 6
                            ? BebuTheme.pink
                            : i < code.length
                                ? BebuTheme.borderStrong
                                : BebuTheme.border,
                    width: i == active && !error ? 1.6 : 1.1,
                  ),
                  boxShadow: i == active && code.length < 6 && !error ? [BoxShadow(color: BebuTheme.pink.withValues(alpha: 0.25), blurRadius: 14)] : null,
                ),
                child: Center(
                  child: i < code.length
                      ? Text(code[i], style: BebuTheme.display(size: 26, color: verifying ? BebuTheme.textMuted : BebuTheme.text))
                      : i == active
                          ? const _Caret()
                          : null,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Caret extends StatefulWidget {
  const _Caret();

  @override
  State<_Caret> createState() => _CaretState();
}

class _CaretState extends State<_Caret> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

  @override
  void initState() {
    super.initState();
    if (!BebuTheme.reducedMotion) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Opacity(
        opacity: _c.value < 0.5 ? 1 : 0,
        child: Container(width: 2, height: 26, decoration: BoxDecoration(color: BebuTheme.pink, borderRadius: BorderRadius.circular(1))),
      ),
    );
  }
}

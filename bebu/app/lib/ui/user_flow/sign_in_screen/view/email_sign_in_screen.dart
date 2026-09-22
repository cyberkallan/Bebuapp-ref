import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/main_screen/controller/main_screen_controller.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/utils.dart';

/// Email + password sign-in, shown only when the admin enables the email
/// method. Reuses the legacy [MainScreenController] which already talks to
/// Firebase email auth and the register / forgot-password screens.
class EmailSignInScreen extends StatefulWidget {
  const EmailSignInScreen({super.key});

  @override
  State<EmailSignInScreen> createState() => _EmailSignInScreenState();
}

class _EmailSignInScreenState extends State<EmailSignInScreen> {
  late final MainScreenController c = Get.isRegistered<MainScreenController>() ? Get.find<MainScreenController>() : Get.put(MainScreenController());
  bool _obscure = true;
  bool _busy = false;

  Future<void> _submit() async {
    if (_busy) return;
    c.selectedValue = 1;
    if (!c.validateLogin()) return;
    setState(() => _busy = true);
    try {
      await c.onClickSignIn();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: BebuTheme.statusBarIcons);
    return Scaffold(
      backgroundColor: BebuTheme.bg,
      resizeToAvoidBottomInset: true,
      body: AuroraBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    GlassIconButton(icon: Icons.arrow_back_rounded, size: 42, color: BebuTheme.surface, blur: false, onTap: Get.back, tooltip: 'Back'),
                  ],
                ),
                const SizedBox(height: 26),
                Text('Sign in with email', style: BebuTheme.display(size: 30).copyWith(letterSpacing: -0.8)),
                const SizedBox(height: 8),
                Text('Welcome back. Enter the email and password you registered with.', style: BebuTheme.body(size: 14.5, color: BebuTheme.textMuted, height: 1.4)),
                const SizedBox(height: 28),
                _Field(
                  controller: c.emailController,
                  hint: 'Email address',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  autofill: const [AutofillHints.email],
                  action: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                _Field(
                  controller: c.passwordController,
                  hint: 'Password',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscure,
                  autofill: const [AutofillHints.password],
                  action: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  trailing: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20, color: BebuTheme.textMuted),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.forgotPasswordScreen, arguments: {'email': c.emailController.text.trim()}),
                    child: Text('Forgot password?', style: BebuTheme.label(size: 13, color: BebuTheme.textMuted)),
                  ),
                ),
                const SizedBox(height: 6),
                GradientButton(label: 'Sign in', icon: Icons.arrow_forward_rounded, gradient: BebuTheme.pinkGradient, glow: BebuTheme.pink, height: 58, loading: _busy, onTap: _submit),
                const SizedBox(height: 18),
                Center(
                  child: Text.rich(
                    TextSpan(
                      style: BebuTheme.body(size: 13.5, color: BebuTheme.textMuted),
                      children: [
                        const TextSpan(text: 'New here? '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.register),
                            child: Text('Create an account', style: BebuTheme.label(size: 13.5, color: BebuTheme.pink)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.autofill,
    this.action,
    this.onSubmitted,
    this.trailing,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Iterable<String>? autofill;
  final TextInputAction? action;
  final ValueChanged<String>? onSubmitted;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.only(left: 16, right: 6),
      decoration: BoxDecoration(color: BebuTheme.surface.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(BebuTheme.radiusMd), border: Border.all(color: BebuTheme.borderStrong)),
      child: Row(
        children: [
          Icon(icon, size: 20, color: BebuTheme.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              autofillHints: autofill,
              textInputAction: action,
              onSubmitted: onSubmitted,
              cursorColor: BebuTheme.pink,
              style: BebuTheme.body(size: 16, color: BebuTheme.text, weight: FontWeight.w500),
              decoration: InputDecoration(hintText: hint, hintStyle: BebuTheme.body(size: 15, color: BebuTheme.textFaint), border: InputBorder.none),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

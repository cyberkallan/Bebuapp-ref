import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:talk_in/custom/custom_web_view/web_view_screen.dart';
import 'package:talk_in/custom/motion/sfx.dart';
import 'package:talk_in/custom/random_name/random_name.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/daily_reward/controller/daily_reward_controller.dart';
import 'package:talk_in/ui/user_flow/main_screen/api/login_api.dart';
import 'package:talk_in/ui/user_flow/main_screen/controller/main_screen_controller.dart';
import 'package:talk_in/ui/user_flow/main_screen/model/login_model.dart';
import 'package:talk_in/utils/anonymous_authentication.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/login_config.dart';
import 'package:talk_in/utils/utils.dart';

/// Which panel the sign-in screen is showing.
enum SignInStep { methods, phone, otp }

/// Drives the redesigned sign-in screen. Google, guest and phone OTP are
/// handled here end to end; the email/password path reuses the legacy
/// [MainScreenController] (which the register / forgot-password screens
/// also depend on).
class SignInController extends GetxController {
  static const idStep = 'signInStep';
  static const idBusy = 'signInBusy';
  static const idConsent = 'signInConsent';
  static const idOtp = 'signInOtp';
  static const idPhone = 'signInPhone';

  final LoginConfig config = LoginConfig.current;
  final RewardTeaser teaser = RewardTeaser.current;

  /// Legacy controller kept alive for the email flow and profile fetch.
  final MainScreenController legacy = Get.isRegistered<MainScreenController>() ? Get.find<MainScreenController>() : Get.put(MainScreenController());

  SignInStep step = SignInStep.methods;
  LoginMethod? busy;
  late bool agreed = !config.requireConsentCheckbox;

  // Phone
  final phoneController = TextEditingController();
  final phoneFocus = FocusNode();
  String dialCode = Database.dialCode ?? '+91';
  String countryCode = Database.selectedCountryCode.isEmpty ? 'IN' : Database.selectedCountryCode;
  String? phoneError;

  // OTP
  final otpController = TextEditingController();
  final otpFocus = FocusNode();
  String? verificationId;
  int? resendToken;
  String? otpError;
  int resendIn = 0;
  Timer? _resendTimer;
  bool verifying = false;

  String get fullPhone => '$dialCode${phoneController.text.trim()}';

  @override
  void onInit() {
    super.onInit();
    legacy.selectedValue = 1; // consent is handled by this screen
    phoneController.addListener(() {
      if (phoneError != null) {
        phoneError = null;
        update([idPhone]);
      }
    });
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    phoneController.dispose();
    otpController.dispose();
    phoneFocus.dispose();
    otpFocus.dispose();
    super.onClose();
  }

  // ---- consent -----------------------------------------------------------

  void toggleAgreed() {
    agreed = !agreed;
    Sfx.tick();
    update([idConsent]);
  }

  bool _consentOk() {
    if (agreed) return true;
    Sfx.deny();
    Utils.showToast(Get.context!, 'Please accept the Terms & Privacy Policy first.');
    update([idConsent]);
    return false;
  }

  void openPrivacyPolicy() {
    final url = Database.appConfigurationModel?.data?.userPrivacyPolicyUrl ?? '';
    if (url.isNotEmpty && url.startsWith('http')) {
      Get.to(() => WebViewScreen(url: url, screen: 'Privacy Policy'));
    }
  }

  // ---- step navigation ---------------------------------------------------

  void goTo(SignInStep s) {
    step = s;
    update([idStep]);
    if (s == SignInStep.phone) {
      Future.delayed(const Duration(milliseconds: 260), () => phoneFocus.requestFocus());
    } else if (s == SignInStep.otp) {
      Future.delayed(const Duration(milliseconds: 260), () => otpFocus.requestFocus());
    } else {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  void back() {
    if (step == SignInStep.otp) {
      otpController.clear();
      otpError = null;
      goTo(SignInStep.phone);
    } else if (step == SignInStep.phone) {
      goTo(SignInStep.methods);
    }
  }

  void onMethodTap(LoginMethod m) {
    if (busy != null) return;
    if (!_consentOk()) return;
    Sfx.lightTap();
    switch (m) {
      case LoginMethod.google:
        signInWithGoogle();
      case LoginMethod.phone:
        goTo(SignInStep.phone);
      case LoginMethod.quick:
        signInAsGuest();
      case LoginMethod.email:
        Get.toNamed(AppRoutes.emailSignIn);
    }
  }

  void setCountry({required String dial, required String code}) {
    dialCode = dial.startsWith('+') ? dial : '+$dial';
    countryCode = code;
    update([idPhone]);
  }

  // ---- shared plumbing ---------------------------------------------------

  Future<void> _prepareDevice() async {
    final identity = await MobileDeviceIdentifier().getDeviceId() ?? Database.identity;
    final fcmToken = await FirebaseMessaging.instance.getToken().catchError((_) => null);
    Database.onSetIdentity(identity);
    Database.onSetFcmToken(fcmToken ?? Database.fcmToken);
  }

  void _setBusy(LoginMethod? m) {
    busy = m;
    update([idBusy, idStep]);
  }

  /// Runs after Firebase authenticated the user and the backend accepted the
  /// login: stores the session, loads the profile, routes to the right home.
  Future<bool> _completeLogin({required LoginModel? model, required int loginType, required String uid}) async {
    if (model?.status != true) {
      Utils.showToast(Get.context!, model?.message?.isNotEmpty == true ? model!.message! : 'Something went wrong. Please try again.');
      return false;
    }
    Database.onSetIsLogin(true);
    Database.onSetLoginType(model?.user?.loginType ?? loginType);
    Database.onSetSeenOnboarding(true);
    Database.onSetFillProfile(true);

    await legacy.onGetProfile(loginUserId: uid, loginType: loginType);

    unawaited(Sfx.unlock());
    if (model?.signUp == true) {
      Database.onSetFillProfile(false);
      DailyRewardController.markWelcomePending();
      Get.offAllNamed(AppRoutes.fillProfileScreen, arguments: [Database.loginUserName, Database.loginUserProfilePic, Database.loginUserEmail]);
    } else if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
      Get.offAllNamed(AppRoutes.hostBottomBar);
    } else {
      Get.offAllNamed(AppRoutes.bottomBar);
    }
    return true;
  }

  // ---- Google ------------------------------------------------------------

  Future<void> signInWithGoogle() async {
    _setBusy(LoginMethod.google);
    try {
      await _prepareDevice();
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // user dismissed the account picker
      final auth = await googleUser.authentication;
      if (auth.idToken == null && auth.accessToken == null) {
        Utils.showToast(Get.context!, 'Google sign-in did not return a token. Please try again.');
        return;
      }
      final cred = await FirebaseAuth.instance.signInWithCredential(GoogleAuthProvider.credential(accessToken: auth.accessToken, idToken: auth.idToken));
      final email = cred.user?.email ?? googleUser.email;
      final model = await LoginApi.callApi(
        countryCode: Database.selectedCountryCode,
        loginType: LoginMethod.google.loginType,
        email: email,
        identity: Database.identity,
        fcmToken: Database.fcmToken,
        userName: cred.user?.displayName ?? googleUser.displayName ?? '',
        profilePic: cred.user?.photoURL ?? googleUser.photoUrl,
      );
      await _completeLogin(model: model, loginType: LoginMethod.google.loginType, uid: cred.user!.uid);
    } on FirebaseAuthException catch (e) {
      Utils.showToast(Get.context!, _authMessage(e));
    } catch (e) {
      Utils.showLog('Google sign-in failed => $e');
      Utils.showToast(Get.context!, 'Google sign-in failed. Check your connection and try again.');
    } finally {
      if (busy == LoginMethod.google) _setBusy(null);
    }
  }

  // ---- Guest -------------------------------------------------------------

  Future<void> signInAsGuest() async {
    _setBusy(LoginMethod.quick);
    try {
      await _prepareDevice();
      await AnonymousAuthentication.signInWithAnonymous();
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (uid.isEmpty) {
        Utils.showToast(Get.context!, 'Could not start a guest session. Please try again.');
        return;
      }
      final model = await LoginApi.callApi(
        countryCode: Database.selectedCountryCode,
        loginType: LoginMethod.quick.loginType,
        email: Database.identity,
        identity: Database.identity,
        fcmToken: Database.fcmToken,
        userName: CustomFetchRandomName.onGet(),
        profilePic: CustomFetchRandomImage.onGet(),
      );
      await _completeLogin(model: model, loginType: LoginMethod.quick.loginType, uid: uid);
    } catch (e) {
      Utils.showLog('Guest sign-in failed => $e');
      Utils.showToast(Get.context!, 'Guest sign-in failed. Please try again.');
    } finally {
      if (busy == LoginMethod.quick) _setBusy(null);
    }
  }

  // ---- Phone OTP ---------------------------------------------------------

  bool get phoneLooksValid {
    final digits = phoneController.text.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 7 && digits.length <= 15;
  }

  Future<void> sendOtp({bool resend = false}) async {
    if (!phoneLooksValid) {
      phoneError = 'Enter a valid mobile number';
      Sfx.deny();
      update([idPhone]);
      return;
    }
    _setBusy(LoginMethod.phone);
    otpError = null;
    try {
      await _prepareDevice();
      final completer = Completer<void>();
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: resend ? resendToken : null,
        verificationCompleted: (credential) async {
          // Android auto-retrieved the SMS: sign in without typing.
          if (credential.smsCode != null) {
            otpController.text = credential.smsCode!;
            update([idOtp]);
          }
          await _signInWithPhoneCredential(credential);
        },
        verificationFailed: (e) {
          phoneError = _authMessage(e);
          update([idPhone]);
          Sfx.deny();
          if (!completer.isCompleted) completer.complete();
        },
        codeSent: (id, token) {
          verificationId = id;
          resendToken = token;
          _startResendCountdown();
          Sfx.lightTap();
          if (step != SignInStep.otp) goTo(SignInStep.otp);
          if (!completer.isCompleted) completer.complete();
        },
        codeAutoRetrievalTimeout: (id) {
          verificationId = id;
          if (!completer.isCompleted) completer.complete();
        },
      );
      // codeSent / verificationFailed fire asynchronously; wait for the first one
      // so the button spinner matches what is actually happening.
      await completer.future.timeout(const Duration(seconds: 25), onTimeout: () {});
    } catch (e) {
      Utils.showLog('sendOtp failed => $e');
      phoneError = 'Could not send the code. Please try again.';
      update([idPhone]);
    } finally {
      if (busy == LoginMethod.phone) _setBusy(null);
    }
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    resendIn = 30;
    update([idOtp]);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      resendIn--;
      if (resendIn <= 0) {
        resendIn = 0;
        t.cancel();
      }
      update([idOtp]);
    });
  }

  void onOtpChanged(String code) {
    otpError = null;
    update([idOtp]);
    if (code.length == 6) verifyOtp();
  }

  Future<void> verifyOtp() async {
    final code = otpController.text.trim();
    if (code.length != 6 || verificationId == null || verifying) return;
    FocusManager.instance.primaryFocus?.unfocus();
    verifying = true;
    update([idOtp]);
    try {
      await _signInWithPhoneCredential(PhoneAuthProvider.credential(verificationId: verificationId!, smsCode: code));
    } finally {
      verifying = false;
      update([idOtp]);
    }
  }

  Future<void> _signInWithPhoneCredential(PhoneAuthCredential credential) async {
    try {
      final cred = await FirebaseAuth.instance.signInWithCredential(credential);
      final uid = cred.user?.uid;
      if (uid == null) {
        otpError = 'Could not verify the code. Please try again.';
        update([idOtp]);
        return;
      }
      final model = await LoginApi.callApi(
        countryCode: Database.selectedCountryCode,
        loginType: LoginMethod.phone.loginType,
        identity: Database.identity,
        fcmToken: Database.fcmToken,
        mobileNumber: phoneController.text.trim(),
      );
      await _completeLogin(model: model, loginType: LoginMethod.phone.loginType, uid: uid);
    } on FirebaseAuthException catch (e) {
      Sfx.deny();
      otpError = e.code == 'invalid-verification-code' ? 'That code isn’t right. Check the SMS and try again.' : _authMessage(e);
      otpController.clear();
      update([idOtp]);
      otpFocus.requestFocus();
    } catch (e) {
      Utils.showLog('Phone sign-in failed => $e');
      otpError = 'Something went wrong. Please try again.';
      update([idOtp]);
    }
  }

  String _authMessage(FirebaseAuthException e) {
    return switch (e.code) {
      'network-request-failed' => 'No internet connection. Check your network and try again.',
      'too-many-requests' => 'Too many attempts from this device. Please wait a while and try again.',
      'invalid-phone-number' => 'That phone number doesn’t look right.',
      'session-expired' => 'The code expired. Tap “Resend code” to get a new one.',
      'invalid-verification-code' => 'That code isn’t right. Check the SMS and try again.',
      'account-exists-with-different-credential' => 'This email is linked with a different sign-in method.',
      'invalid-credential' => 'Sign-in failed: invalid or expired credential.',
      'operation-not-allowed' => 'This sign-in method is not enabled yet. Please try another option.',
      _ => e.message ?? 'Sign-in failed. Please try again.',
    };
  }
}

import 'dart:async';
import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:talk_in/localization/locale_constant.dart';
import 'package:talk_in/routes/app_pages.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/services/notification_service/notification_services.dart';
import 'localization/localizations_delegate.dart';
import 'utils/utils.dart';
import 'package:talk_in/utils/appearance.dart';
import 'package:talk_in/utils/pro.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';

AppLifecycleState? currentAppLifecycleState;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await 500.milliseconds.delay();

  await Firebase.initializeApp();
  await GetStorage.init();
  Appearance.init();
  Pro.init();

  final identity = (await MobileDeviceIdentifier().getDeviceId())!;
  final fcmToken = await FirebaseMessaging.instance.getToken();

  Utils.showLog("Device Id => $identity");
  Utils.showLog("FCM Token => $fcmToken");

  if (fcmToken != null) {
    await Database.init(identity, fcmToken);
  }
  NotificationServices.init();

  // Set up Awesome Notifications listeners
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: NotificationServices.onAwesomeNotificationActionReceived,
  );

  NotificationServices.firebaseInit();
  FirebaseMessaging.onBackgroundMessage(backgroundNotification);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static final StreamController purchaseStreamController = StreamController<PurchaseDetails>.broadcast();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    currentAppLifecycleState = state;
    Utils.showLog('AppLifecycleState changed to: $state');
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        log("didChangeDependencies Preference Revoked ${locale.languageCode}");
        log("didChangeDependencies GET LOCALE Revoked ${Get.locale?.languageCode}");
        Get.updateLocale(locale);
      });
    });
    super.didChangeDependencies();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Utils.showLog("MY Current Routes => ${Get.currentRoute}");
    return GetMaterialApp(
      title: 'bebu',
      debugShowCheckedModeBanner: false,
      locale: const Locale("en"),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: Container(
            color: BebuTheme.bg,
            child: SafeArea(
              bottom: true,
              top: false,
              left: false,
              right: false,
              child: Scaffold(
                // backgroundColor: AppColors.black,
                body: Stack(
                  children: [
                    child ?? const SizedBox(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      translations: AppLanguages(),
      initialRoute: AppRoutes.splashScreenPage,
      getPages: AppPages.list,
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}

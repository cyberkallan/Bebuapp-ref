/// updated code
library;

// import 'dart:convert';
// import 'dart:math';
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:talk_in/custom/dialog/app_restart_dialog.dart';
// import 'package:talk_in/routes/app_routes.dart';
// import 'package:talk_in/utils/api_params.dart';
// import 'package:talk_in/utils/app_color.dart';
// import 'package:talk_in/utils/database.dart';
// import 'package:talk_in/utils/utils.dart';
//
// class NotificationServices {
//   static FirebaseMessaging messaging = FirebaseMessaging.instance;
//
//   static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   static FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
//
//   static Future<void> init() async {
//     // This Method Call in Main...
//     var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_notification');
//
//     const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();
//
//     final initializationSettings = InitializationSettings(android: androidInitializationSettings, iOS: initializationSettingsDarwin);
//
//     /*await _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (payload) {
//         final data = jsonDecode(payload.payload!);
//         Utils.showLog("Parsed payload data :: $data");
//
//       },
//       onDidReceiveBackgroundNotificationResponse: (details) {
//         Utils.showLog("On receive background notification response");
//       },
//     );*/
//
//     await _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (payload) {
//         final data = jsonDecode(payload.payload!);
//         Utils.showLog("Parsed payload data :: $data");
//
//         // Navigate based on notification type
//         if (data['type'] == 'CHAT') {
//           // Navigate to the personal chat screen with the sender's info
//           if (Database.fetchLoginUserProfileModel?.user?.isListener == false) {
//             Get.toNamed(
//               AppRoutes.personalChatScreen,
//               arguments: [
//                 data['senderId'],
//                 data['senderName'],
//                 data['isOnline'],
//                 data['senderProfilePic'],
//                 data['ratePrivateAudioCall'],
//                 data['ratePrivateVideoCall'],
//                 data['isFake'] ?? false,
//                 data['video'] ?? ''
//
//                 // controller.chatList[index].receiverId,
//                 // controller.chatList[index].name,
//                 // controller.chatList[index].isOnline,
//                 // controller.chatList[index].image,
//                 // controller.chatList[index].ratePrivateAudioCall,
//                 // controller.chatList[index].ratePrivateVideoCall,
//
//                 // {senderName: Tiya , senderId: 684a66dbc523eb77a4daec90,
//                 //   ratePrivateAudioCall: , ratePrivateVideoCall: , isOnline: true,
//                 //   type: CHAT, senderProfilePic: storage\1749706490597.jpg}
//               ],
//             );
//           } else {
//             Get.toNamed(
//               AppRoutes.hostPersonalChatScreen,
//               arguments: [
//                 data['senderId'],
//                 data['senderName'],
//                 data['isOnline'],
//                 data['senderProfilePic'],
//               ],
//
//               // controller.listenerChatList[index].id,
//               // controller.listenerChatList[index].fullName,
//               // controller.listenerChatList[index].isOnline,
//               // controller.listenerChatList[index].profilePic,],
//             );
//           }
//         } else if (data['type'] == 'listener_verified') {
//           // Show a dialog when listener is verified
//           Get.dialog(
//             barrierColor: AppColors.black.withValues(alpha: 0.8),
//             Dialog(
//               backgroundColor: AppColors.transparent,
//               shadowColor: Colors.transparent,
//               surfaceTintColor: Colors.transparent,
//               elevation: 0,
//               child: const AppRestartDialog(),
//             ),
//           );
//         }
//         // Add more conditions as needed for other notification types
//       },
//       onDidReceiveBackgroundNotificationResponse: (details) {
//         Utils.showLog("On receive background notification response");
//       },
//     );
//
//     await messaging.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: true,
//       criticalAlert: true,
//       provisional: true,
//       sound: true,
//     );
//   }
//
//   static Future<void> showNotification(RemoteMessage message) async {
//     AndroidNotificationChannel channel = AndroidNotificationChannel(
//       Random.secure().nextInt(100000).toString(),
//       "High Importance Notification",
//       importance: Importance.max,
//       playSound: true,
//     );
//
//     AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
//       playSound: true,
//       channel.id,
//       channel.name,
//       channelDescription: "your channel description",
//       importance: Importance.max, //******** For show notification banner
//       priority: Priority.high,
//       ticker: "ticker",
//       enableVibration: true,
//       icon: "@mipmap/ic_notification",
//       actions: [],
//     );
//
//     DarwinNotificationDetails darwinNotificationDetails = const DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );
//
//     NotificationDetails notificationDetails = NotificationDetails(
//       android: androidNotificationDetails,
//       iOS: darwinNotificationDetails,
//     );
//
//     _flutterLocalNotificationsPlugin.show(
//       Random.secure().nextInt(100000),
//       message.notification?.title.toString(),
//       message.notification?.body.toString(),
//       notificationDetails,
//       payload: jsonEncode(message.data),
//     );
//   }
//
//   static Future<void> firebaseInit() async {
//     // This Method Call in Main...
//     FirebaseMessaging.onMessage.listen(
//       (message) {
//         Utils.showLog("Notification => ${message.data}");
//         Utils.showLog("Notification => ${message.data["type"]}");
//         Utils.showLog("Notification Title => ${message.notification?.title.toString()}");
//         Utils.showLog("Notification Body => ${message.notification?.body.toString()}");
//
//         Utils.showLog("Get.currentRoute ::  ${Get.currentRoute}");
//
//         if ((Get.currentRoute == AppRoutes.personalChatScreen || Get.currentRoute == AppRoutes.hostPersonalChatScreen) &&
//             message.data["type"] == "CHAT") {
//           Utils.showLog("User is already on a chat screen. Suppressing notification.");
//         } else {
//           Utils.showLog("User is not chat screen");
//
//           if (Database.fetchLoginUserProfileModel?.user?.isNotificationEnabled == true ||
//               Database.fetchListenerProfileModel?.data?.isNotificationEnabled == true) {
//             Utils.showLog('notification enabled');
//             showNotification(message);
//           } else {
//             Utils.showLog("notification disabled");
//           }
//         }
//
//         if (message.data["type"] == "listener_verified") {
//           Utils.showLog("User Listener Req acssepted.");
//           Get.dialog(
//             barrierColor: AppColors.black.withValues(alpha: 0.8),
//             Dialog(
//               backgroundColor: AppColors.transparent,
//               shadowColor: Colors.transparent,
//               surfaceTintColor: Colors.transparent,
//               elevation: 0,
//               child: const AppRestartDialog(),
//             ),
//           );
//         }
//       },
//     );
//   }
//
//   //**************************** Background notification
//
//   static Future<void> backgroundNotification(RemoteMessage message) async {
//     await Firebase.initializeApp();
//     FirebaseMessaging messaging = FirebaseMessaging.instance;
//
//     NotificationSettings settings = await messaging.requestPermission(
//       sound: true,
//       badge: true,
//       alert: true,
//       provisional: false,
//       announcement: true,
//     );
//
//     Utils.showLog("Setting :: $settings");
//     Utils.showLog('Got a message!');
//     Utils.showLog('Message data :: ${message.data}');
//
//     if (message.notification != null) {
//       Utils.showLog('Message Contained a Notification :: ${message.notification?.body}');
//     }
//
//     const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@drawable/ic_notification');
//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//     flutterLocalNotificationsPlugin?.initialize(
//       const InitializationSettings(android: initializationSettingsAndroid),
//       onDidReceiveNotificationResponse: (details) {
//         final data = jsonDecode(details.payload!);
//         Utils.showLog("Parsed payload data background :: $data");
//
//         if (data['type'] == 'CHAT') {
//           // Navigate to chat screen on notification tap
//           if (Database.fetchLoginUserProfileModel?.user?.isListener == false) {
//             Utils.showLog("user personal chat screen :::::::::::::::::: $data");
//             Get.toNamed(
//               AppRoutes.personalChatScreen,
//               arguments: [
//                 data['senderId'],
//                 data['senderName'],
//                 data['isOnline'],
//                 data['senderProfilePic'],
//                 data['ratePrivateAudioCall'],
//                 data['ratePrivateVideoCall'],
//                 data['isFake'] ?? false,
//                 data['video'] ?? ''
//               ],
//             );
//           } else {
//             Utils.showLog("listener personal chat screen ::::::::::::::: $data");
//             Get.toNamed(
//               AppRoutes.hostPersonalChatScreen,
//               arguments: [
//                 data['senderId'],
//                 data['senderName'],
//                 data['isOnline'],
//                 data['senderProfilePic'],
//               ],
//             );
//           }
//         } else if (data['type'] == 'listener_verified') {
//           // Show a dialog when listener is verified
//           Get.dialog(
//             barrierColor: AppColors.black.withValues(alpha: 0.8),
//             Dialog(
//               backgroundColor: AppColors.transparent,
//               shadowColor: Colors.transparent,
//               surfaceTintColor: Colors.transparent,
//               elevation: 0,
//               child: const AppRestartDialog(),
//             ),
//           );
//         }
//         // Add more conditions as needed for other notification types
//       },
//       onDidReceiveBackgroundNotificationResponse: (details) {
//         Utils.showToast(Get.context!, "on Did Receive Background Notification Response");
//       },
//     );
//
//     var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
//       "0",
//       "bebu",
//       channelDescription: "your channel description",
//       importance: Importance.max,
//       priority: Priority.high,
//       ticker: "ticker",
//       enableVibration: true,
//       playSound: true,
//       channelShowBadge: true,
//       fullScreenIntent: true,
//       onlyAlertOnce: true,
//       visibility: NotificationVisibility.public,
//       icon: "@mipmap/ic_notification",
//     );
//
//     var platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//     );
//
//     await flutterLocalNotificationsPlugin?.show(
//       message.hashCode,
//       message.notification!.title.toString(),
//       message.notification!.body.toString(),
//       platformChannelSpecifics,
//       payload: jsonEncode(message.data),
//     );
//   }
// }

/// claude ai code

/*import 'dart:convert';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/app_restart_dialog.dart';
import 'package:talk_in/main.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

class NotificationServices {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'call_channel',
          channelName: 'Call Channel',
          channelDescription: 'Channel for incoming call notifications',
          defaultColor: Colors.green,
          importance: NotificationImportance.Max,
          locked: true,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'chat_channel',
          channelName: 'Chat Channel',
          channelDescription: 'Channel for chat notifications',
          defaultColor: Colors.blue,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
      ],
      debug: true,
    );

    // Request permissions for Awesome Notifications
    await AwesomeNotifications().requestPermissionToSendNotifications();

    // Set up notification listeners PROPERLY
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onAwesomeNotificationActionReceived,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );

    // Flutter Local Notifications setup
    var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_notification');
    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();
    final initializationSettings = InitializationSettings(android: androidInitializationSettings, iOS: initializationSettingsDarwin);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    // Firebase Messaging permissions
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
  }

  // FIXED: Proper notification tap handling without app restart
  static Future<void> onDidReceiveNotificationResponse(NotificationResponse response) async {
    try {
      if (response.payload != null && response.payload!.isNotEmpty) {
        final data = jsonDecode(response.payload!);
        Utils.showLog("Flutter Local Notification tapped with payload: $data");

        // Use a delay to ensure app is fully ready
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate without restarting the app
        _handleNotificationNavigation(data);
      }
    } catch (e) {
      Utils.showLog("Error handling notification tap: $e");
    }
  }

  // FIXED: Separate navigation method to avoid restart
  static void _handleNotificationNavigation(Map<String, dynamic> data) {
    try {
      if (data["type"] == "CHAT") {
        Utils.showLog("Navigating to chat from notification");

        // Check if we're already on the target screen to avoid duplicate navigation
        String targetRoute =
            Database.fetchLoginUserProfileModel?.user?.isListener == false ? AppRoutes.personalChatScreen : AppRoutes.hostPersonalChatScreen;

        if (Get.currentRoute == targetRoute) {
          Utils.showLog("Already on target chat screen, skipping navigation");
          return;
        }

        if (Database.fetchLoginUserProfileModel?.user?.isListener == false) {
          // Navigate to personal chat screen (user)
          Get.offAndToNamed(
            // Use offAndToNamed to replace current route
            AppRoutes.personalChatScreen,
            arguments: [
              data['senderId'],
              data['senderName'],
              data['isOnline'] ?? false,
              data['senderProfilePic'] ?? '',
              data['ratePrivateAudioCall'],
              data['ratePrivateVideoCall'],
              data['isFake'] ?? false,
              data['video'] ?? ''
            ],
          );
        } else {
          // Navigate to personal chat screen (host)
          Get.offAndToNamed(
            // Use offAndToNamed to replace current route
            AppRoutes.hostPersonalChatScreen,
            arguments: [
              data['senderId'],
              data['senderName'],
              data['isOnline'] ?? false,
              data['senderProfilePic'] ?? '',
            ],
          );
        }
      }
    } catch (e) {
      Utils.showLog("Error in navigation: $e");
    }
  }

  // FIXED: Awesome Notifications action handler
  static Future<void> onAwesomeNotificationActionReceived(ReceivedAction receivedAction) async {
    try {
      Utils.showLog("Awesome notification action received: ${receivedAction.buttonKeyPressed}");

      if (receivedAction.payload != null) {
        final data = receivedAction.payload!;
        Utils.showLog("Received action with payload: $data");

        // Handle call actions
        if (receivedAction.buttonKeyPressed == 'ACCEPT') {
          Utils.showLog('Call Accepted via Awesome Notifications');
          await AwesomeNotifications().dismiss(receivedAction.id!);

          SocketEmit.emitCallResponseProcessed(
            callerId: data['callerId']!,
            receiverId: data['receiverId']!,
            callId: data['callId']!,
            isAccept: true,
            callType: data['callType'] ?? 'audio',
            callMode: data['callMode'] ?? 'private',
            callerRole: data['callerRole'] ?? '',
            receiverRole: data['receiverRole'] ?? '',
            receiverName: data['receiverName'] ?? '',
            receiverImage: data['receiverImage'] ?? '',
            callerName: data['callerfullName'] ?? '',
            callerImage: data['callerImage'] ?? '',
          );
        } else if (receivedAction.buttonKeyPressed == 'DECLINE') {
          Utils.showLog('Call Declined via Awesome Notifications');
          await AwesomeNotifications().dismiss(receivedAction.id!);
          SocketEmit.emitCallResponseProcessed(
            callerId: data['callerId']!,
            receiverId: data['receiverId']!,
            callId: data['callId']!,
            isAccept: false,
            callType: data['callType'] ?? 'audio',
            callMode: data['callMode'] ?? 'private',
            callerRole: data['callerRole'] ?? '',
            receiverRole: data['receiverRole'] ?? '',
            receiverName: data['receiverName'] ?? '',
            receiverImage: data['receiverImage'] ?? '',
            callerName: data['callerfullName'] ?? '',
            callerImage: data['callerImage'] ?? '',
          );
        } else {
          // Handle normal notification tap (not call actions)
          await Future.delayed(const Duration(milliseconds: 500));
          _handleNotificationNavigation(data);
        }
      }
    } catch (e) {
      Utils.showLog("Error in notification action handler: $e");
    }
  }

  // Additional notification lifecycle methods
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    Utils.showLog("Notification created: ${receivedNotification.id}");
  }

  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    Utils.showLog("Notification displayed: ${receivedNotification.id}");
  }

  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    Utils.showLog("Notification dismissed: ${receivedAction.id}");
  }

  // FIXED: Removed the problematic onHandleNotificationNavigation method
  // that was causing direct navigation issues

  static Future<void> showIncomingCallNotification({
    required String title,
    required String body,
    Map<String, dynamic>? callData,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: Random.secure().nextInt(100000), // Use random ID to avoid conflicts
        channelKey: 'call_channel',
        title: title,
        body: body,
        category: NotificationCategory.Call,
        fullScreenIntent: true,
        wakeUpScreen: true,
        locked: true,
        autoDismissible: false,
        timeoutAfter: const Duration(seconds: 30),
        notificationLayout: NotificationLayout.Default,
        criticalAlert: true,
        ticker: "Incoming Call",
        displayOnForeground: true,
        displayOnBackground: true,
        payload: callData?.map((key, value) => MapEntry(key.toString(), value.toString())),
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'ACCEPT',
          label: 'Accept',
          color: Colors.green,
          actionType: ActionType.Default,
          isDangerousOption: false,
        ),
        NotificationActionButton(
          key: 'DECLINE',
          label: 'Decline',
          color: Colors.red,
          actionType: ActionType.Default,
          isDangerousOption: true,
        ),
      ],
    );
  }

  static Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      Random.secure().nextInt(100000).toString(),
      "High Importance Notification",
      importance: Importance.max,
      playSound: true,
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: "your channel description",
      importance: Importance.max,
      priority: Priority.high,
      ticker: "ticker",
      enableVibration: true,
      icon: "@mipmap/ic_notification",
      playSound: true,
    );

    DarwinNotificationDetails darwinNotificationDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      Random.secure().nextInt(100000),
      message.notification?.title.toString(),
      message.notification?.body.toString(),
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  static Future<void> showAwesomeNotification(RemoteMessage message) async {
    String channelKey = 'chat_channel';
    NotificationCategory category = NotificationCategory.Message;
    List<NotificationActionButton> actions = [];

    if (message.data['type'] == 'callIncoming') {
      channelKey = 'call_channel';
      category = NotificationCategory.Call;
      actions = [
        NotificationActionButton(
          key: 'ACCEPT',
          label: 'Accept',
          color: Colors.green,
          actionType: ActionType.Default,
        ),
        NotificationActionButton(
          key: 'DECLINE',
          label: 'Decline',
          color: Colors.red,
          actionType: ActionType.Default,
        ),
      ];
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: Random.secure().nextInt(100000),
        channelKey: channelKey,
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? 'You have a new message',
        category: category,
        payload: message.data.map((key, value) => MapEntry(key.toString(), value.toString())),
        notificationLayout: NotificationLayout.Default,
        displayOnForeground: true,
        displayOnBackground: true,
        wakeUpScreen: channelKey == 'call_channel',
        fullScreenIntent: channelKey == 'call_channel',
        criticalAlert: channelKey == 'call_channel',
        autoDismissible: channelKey != 'call_channel',
        timeoutAfter: channelKey == 'call_channel' ? const Duration(seconds: 30) : null,
      ),
      actionButtons: actions,
    );
  }

  static Future<void> firebaseInit() async {
    FirebaseMessaging.onMessage.listen((message) {
      Utils.showLog("Notification => ${message.data}");
      Utils.showLog("Notification => ${message.data["type"]}");
      Utils.showLog("Notification Title => ${message.notification?.title.toString()}");
      Utils.showLog("Notification Body => ${message.notification?.body.toString()}");
      Utils.showLog("Get.currentRoute ::  ${Get.currentRoute}");

      if (Database.fetchLoginUserProfileModel?.user?.isNotificationEnabled == true ||
          Database.fetchListenerProfileModel?.data?.isNotificationEnabled == true) {
        if ((Get.currentRoute == AppRoutes.personalChatScreen || Get.currentRoute == AppRoutes.hostPersonalChatScreen) &&
            message.data["type"] == "CHAT") {
          Utils.showLog("User is already on a chat screen. Suppressing notification.");
        } else {
          if (message.data['type'] == 'callIncoming') {
            if (currentAppLifecycleState == AppLifecycleState.paused) {
              Utils.showLog("Showing incoming call notification");
              showIncomingCallNotification(
                title: message.notification?.title ?? 'Incoming Call',
                body: message.notification?.body ?? 'Someone is calling you...',
                callData: message.data,
              );
            }
          } else {
            showNotification(message);
          }
        }

        if (message.data["type"] == "listener_verified") {
          Utils.showLog("User Listener Request accepted.");
          Get.dialog(
            barrierColor: AppColors.black.withValues(alpha: 0.8),
            Dialog(
              backgroundColor: AppColors.transparent,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              child: const AppRestartDialog(),
            ),
          );
        }
      }
    });

    FirebaseMessaging.onBackgroundMessage(backgroundNotification);
  }
}

// Background notification handler
@pragma('vm:entry-point')
Future<void> backgroundNotification(RemoteMessage message) async {
  await Firebase.initializeApp();

  Utils.showLog('Background notification received');
  Utils.showLog('Message data :: ${message.data}');

  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'call_channel',
        channelName: 'Call Channel',
        channelDescription: 'Channel for incoming call notifications',
        defaultColor: Colors.green,
        importance: NotificationImportance.Max,
        locked: true,
        channelShowBadge: true,
        playSound: true,
        enableVibration: true,
      ),
    ],
  );

  if (message.data['type'] == 'callIncoming') {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: Random.secure().nextInt(100000),
        channelKey: 'call_channel',
        title: message.notification?.title ?? 'Incoming Call',
        body: message.notification?.body ?? 'You have an incoming call',
        category: NotificationCategory.Call,
        fullScreenIntent: true,
        wakeUpScreen: true,
        locked: true,
        autoDismissible: false,
        timeoutAfter: const Duration(seconds: 30),
        criticalAlert: true,
        displayOnForeground: true,
        displayOnBackground: true,
        payload: message.data.map((key, value) => MapEntry(key.toString(), value.toString())),
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'ACCEPT',
          label: 'Accept',
          color: Colors.green,
          actionType: ActionType.Default,
        ),
        NotificationActionButton(
          key: 'DECLINE',
          label: 'Decline',
          color: Colors.red,
          actionType: ActionType.Default,
        ),
      ],
    );
  } else {
    // Handle other notifications with local notifications
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_notification');

    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(android: initializationSettingsAndroid),
    );

    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      "0",
      "bebu",
      channelDescription: "your channel description",
      importance: Importance.max,
      priority: Priority.high,
      ticker: "ticker",
      enableVibration: true,
      playSound: true,
      channelShowBadge: true,
      fullScreenIntent: true,
      onlyAlertOnce: true,
      visibility: NotificationVisibility.public,
      icon: "@mipmap/ic_notification",
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification!.title.toString(),
      message.notification!.body.toString(),
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
  }
}*/

/// khushi  code

/*
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/app_restart_dialog.dart';
import 'package:talk_in/main.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/services/permission_handler/permission_handler.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

class NotificationServices {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'call_channel',
          channelName: 'Call Channel',
          channelDescription: 'Channel for incoming call notifications',
          defaultColor: Colors.green,
          importance: NotificationImportance.Max,
          locked: true,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'chat_channel',
          channelName: 'Chat Channel',
          channelDescription: 'Channel for chat notifications',
          defaultColor: Colors.blue,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
      ],
      debug: true,
    );

    await AwesomeNotifications().requestPermissionToSendNotifications();

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onAwesomeNotificationActionReceived,
    );

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );
  }

  static Future<void> onAwesomeNotificationActionReceived(ReceivedAction receivedAction) async {
    Utils.showLog("Awesome notification action received: ${receivedAction.buttonKeyPressed}");

    if (receivedAction.payload != null && receivedAction.payload!.isNotEmpty) {
      final data = receivedAction.payload!;

      if (receivedAction.buttonKeyPressed == 'ACCEPT') {
        await AwesomeNotifications().dismiss(receivedAction.id!);

        PermissionHandler.onGetCameraPermission(
          onGranted: () {
            PermissionHandler.onGetMicrophonePermission(
              onGranted: () async {
                SocketEmit.emitCallResponseProcessed(
                  callerId: data['callerId']!,
                  receiverId: data['receiverId']!,
                  callId: data['callId']!,
                  isAccept: true,
                  callType: data['callType'] ?? 'audio',
                  callMode: data['callMode'] ?? 'private',
                  callerRole: data['callerRole'] ?? '',
                  receiverRole: data['receiverRole'] ?? '',
                  receiverName: data['receiverName'] ?? '',
                  receiverImage: data['receiverImage'] ?? '',
                  callerName: data['callerfullName'] ?? '',
                  callerImage: data['callerImage'] ?? '',
                );
              },
            );
          },
        );
      } else if (receivedAction.buttonKeyPressed == 'DECLINE') {
        await AwesomeNotifications().dismiss(receivedAction.id!);
        SocketEmit.emitCallResponseProcessed(
          callerId: data['callerId']!,
          receiverId: data['receiverId']!,
          callId: data['callId']!,
          isAccept: false,
          callType: data['callType'] ?? 'audio',
          callMode: data['callMode'] ?? 'private',
          callerRole: data['callerRole'] ?? '',
          receiverRole: data['receiverRole'] ?? '',
          receiverName: data['receiverName'] ?? '',
          receiverImage: data['receiverImage'] ?? '',
          callerName: data['callerfullName'] ?? '',
          callerImage: data['callerImage'] ?? '',
        );
      } else {
        Utils.showLog("handle notification navigation");
        onHandleNotificationNavigation(data);
      }
    }
  }

  static void onHandleNotificationNavigation(Map<String, dynamic> data) {
    if (data["type"] == "CHAT") {
      Utils.showLog("Enter in notification tap chat********************");

      if (Database.fetchLoginUserProfileModel?.user?.isListener == false) {
        Utils.showLog("User chat screen *******************************");

        // Navigate to personal chat screen (user)
        Get.toNamed(
          AppRoutes.personalChatScreen,
          arguments: [
            data['senderId'],
            data['senderName'],
            data['isOnline'],
            data['senderProfilePic'],
            data['ratePrivateAudioCall'],
            data['ratePrivateVideoCall'],
            data['isFake'] ?? false,
            data['video']
          ],
        );
      } else {
        Utils.showLog("Listener chat screen *******************************");

        // Navigate to personal chat screen (host)
        Get.toNamed(
          AppRoutes.hostPersonalChatScreen,
          arguments: [
            data['senderId'],
            data['senderName'],
            data['isOnline'],
            data['senderProfilePic'],
          ],
        );
      }
    } else if (data["type"] == "missed_call") {
      Get.toNamed(AppRoutes.profileDetailScreenView, arguments: data['callerId']);
    } else {
      Utils.showLog("Enter in else****************************");
    }
  }

  static Future<void> showAwesomeNotification(RemoteMessage message) async {
    Utils.showLog("show awesome notification AAA");

    String type = message.data['type'] ?? '';
    String channelKey = 'chat_channel';
    NotificationCategory category = NotificationCategory.Message;
    List<NotificationActionButton> actions = [];

    if (type == 'callIncoming') {
      Utils.showLog("callIncoming notification ........");
      channelKey = 'call_channel';
      category = NotificationCategory.Call;
      actions = [
        NotificationActionButton(key: 'ACCEPT', label: 'Accept', color: Colors.green),
        NotificationActionButton(key: 'DECLINE', label: 'Decline', color: Colors.red),
      ];
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: Random.secure().nextInt(100000),
        channelKey: channelKey,
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? 'You have a new message',
        category: category,
        icon: 'resource://mipmap/ic_notification',
        payload: message.data.map((k, v) => MapEntry(k.toString(), v.toString())),
        notificationLayout: NotificationLayout.Default,
        displayOnForeground: true,
        displayOnBackground: true,
        wakeUpScreen: (channelKey == 'call_channel'),
        fullScreenIntent: (channelKey == 'call_channel'),
        criticalAlert: (channelKey == 'call_channel'),
        autoDismissible: (channelKey != 'call_channel'),
        timeoutAfter: (channelKey == 'call_channel') ? const Duration(seconds: 30) : null,
      ),
      actionButtons: actions,
    );
  }

  static Future<void> firebaseInit() async {
    FirebaseMessaging.onMessage.listen((message) {
      Utils.showLog("Notification service firebase init => $currentAppLifecycleState");

      Utils.showLog("Notification AAA => ${message.data}");
      Utils.showLog("Notification => ${message.data["type"]}");
      Utils.showLog("Notification Title => ${message.notification?.title.toString()}");
      Utils.showLog("Notification Body => ${message.notification?.body.toString()}");

      if (message.data["type"] == null) return;

      // Handle only if the app is in the foreground
      if (currentAppLifecycleState == AppLifecycleState.resumed) {
        Utils.showLog("app is in the foreground.");
        if ((Get.currentRoute == AppRoutes.personalChatScreen || Get.currentRoute == AppRoutes.hostPersonalChatScreen) &&
            message.data["type"] == "CHAT") {
          Utils.showLog("User is already on a chat screen. Suppressing notification.");
        } else if (message.data['type'] == 'listener_verified') {
          Get.dialog(
            barrierColor: AppColors.black.withOpacity(0.8),
            Dialog(
              backgroundColor: AppColors.transparent,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              child: const AppRestartDialog(),
            ),
          );
        } else if (message.data['type'] == 'callIncoming') {
          showAwesomeNotification(message);
        } else {
          showAwesomeNotification(message);
        }
      } else if (currentAppLifecycleState == AppLifecycleState.paused) {
        Utils.showLog("app is in the background.");
        // Handle background notifications
        showAwesomeNotification(message);
      }
    });
  }
}

@pragma('vm:entry-point')
Future<void> backgroundNotification(RemoteMessage message) async {
  Utils.showLog("background notification AAA");
  // await Firebase.initializeApp();
  await NotificationServices.showAwesomeNotification(message);
}
*/

import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/app_restart_dialog.dart';
import 'package:talk_in/main.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/services/permission_handler/permission_handler.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

class NotificationServices {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'call_channel',
          channelName: 'Call Channel',
          channelDescription: 'Channel for incoming call notifications',
          defaultColor: Colors.green,
          importance: NotificationImportance.Max,
          locked: true,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'chat_channel',
          channelName: 'Chat Channel',
          channelDescription: 'Channel for chat notifications',
          defaultColor: Colors.blue,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
      ],
      debug: true,
    );

    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    // await AwesomeNotifications().requestPermissionToSendNotifications();

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onAwesomeNotificationActionReceived,
    );

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );
  }

  static Future<void> onAwesomeNotificationActionReceived(ReceivedAction receivedAction) async {
    Utils.showLog("Awesome notification action received: ${receivedAction.buttonKeyPressed}");

    if (receivedAction.payload != null && receivedAction.payload!.isNotEmpty) {
      final data = receivedAction.payload!;

      if (receivedAction.buttonKeyPressed == 'ACCEPT') {
        await AwesomeNotifications().dismiss(receivedAction.id!);

        PermissionHandler.onGetCameraPermission(
          onGranted: () {
            PermissionHandler.onGetMicrophonePermission(
              onGranted: () async {
                SocketEmit.emitCallResponseProcessed(
                  callerId: data['callerId']!,
                  receiverId: data['receiverId']!,
                  callId: data['callId']!,
                  isAccept: true,
                  callType: data['callType'] ?? 'audio',
                  callMode: data['callMode'] ?? 'private',
                  callerRole: data['callerRole'] ?? '',
                  receiverRole: data['receiverRole'] ?? '',
                  receiverName: data['receiverName'] ?? '',
                  receiverImage: data['receiverImage'] ?? '',
                  callerName: data['callerfullName'] ?? '',
                  callerImage: data['callerImage'] ?? '',
                );
              },
            );
          },
        );
      } else if (receivedAction.buttonKeyPressed == 'DECLINE') {
        await AwesomeNotifications().dismiss(receivedAction.id!);
        SocketEmit.emitCallResponseProcessed(
          callerId: data['callerId']!,
          receiverId: data['receiverId']!,
          callId: data['callId']!,
          isAccept: false,
          callType: data['callType'] ?? 'audio',
          callMode: data['callMode'] ?? 'private',
          callerRole: data['callerRole'] ?? '',
          receiverRole: data['receiverRole'] ?? '',
          receiverName: data['receiverName'] ?? '',
          receiverImage: data['receiverImage'] ?? '',
          callerName: data['callerfullName'] ?? '',
          callerImage: data['callerImage'] ?? '',
        );
      } else {
        Utils.showLog("handle notification navigation");
        onHandleNotificationNavigation(data);
      }
    }
  }

  static void onHandleNotificationNavigation(Map<String, dynamic> data) {
    if (data["type"] == "CHAT") {
      Utils.showLog("Enter in notification tap chat********************");

      if (Database.fetchLoginUserProfileModel?.user?.isListener == false) {
        Utils.showLog("User chat screen *******************************");

        // Navigate to personal chat screen (user)
        Get.toNamed(
          AppRoutes.personalChatScreen,
          arguments: [
            data['senderId'],
            data['senderName'],
            data['isOnline'],
            data['senderProfilePic'],
            data['ratePrivateAudioCall'],
            data['ratePrivateVideoCall'],
            data['isFake'] ?? false,
            data['video'],
            data['isAvailableForPrivateVideoCall'],
            data['isAvailableForPrivateAudioCall'],
          ],
        );
      } else {
        Utils.showLog("Listener chat screen *******************************");

        // Navigate to personal chat screen (host)
        Get.toNamed(
          AppRoutes.hostPersonalChatScreen,
          arguments: [
            data['senderId'],
            data['senderName'],
            data['isOnline'],
            data['senderProfilePic'],
          ],
        );
      }
    } else if (data["type"] == "missed_call") {
      Get.toNamed(AppRoutes.profileDetailScreenView, arguments: data['callerId']);
    } else {
      Utils.showLog("Enter in else****************************");
    }
  }

  static Future<void> showAwesomeNotification(RemoteMessage message) async {
    Utils.showLog("show awesome notification AAA");

    String type = message.data['type'] ?? '';
    String channelKey = 'chat_channel';
    NotificationCategory category = NotificationCategory.Message;
    List<NotificationActionButton> actions = [];
    if (currentAppLifecycleState != AppLifecycleState.resumed) {
      Utils.showLog("incoming call resumed notification ........");
      if (type == 'callIncoming') {
        Utils.showLog("callIncoming notification ........");
        channelKey = 'call_channel';
        category = NotificationCategory.Call;
        actions = [
          NotificationActionButton(key: 'ACCEPT', label: 'Accept', color: Colors.green),
          NotificationActionButton(key: 'DECLINE', label: 'Decline', color: Colors.red),
        ];
      }
    } else {
      Utils.showLog("incoming call not resumed notification ........");
    }

    int getUniqueNotificationId() {
      var randomNumber = Random();
      var resultOne = randomNumber.nextInt(2000);
      var resultTwo = randomNumber.nextInt(100);
      if (resultTwo >= resultOne) resultTwo += 1;
      return resultTwo;
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: getUniqueNotificationId(),
        channelKey: channelKey,
        // title: message.notification?.title ?? 'Notification',
        // body: message.notification?.body ?? 'You have a new message',
        title: message.data['title'] ?? 'Notification',
        body: message.data['body'] ?? 'You have a new message',
        category: category,
        icon: 'resource://mipmap/ic_notification',
        payload: message.data.map((k, v) => MapEntry(k.toString(), v.toString())),
        notificationLayout: NotificationLayout.Default,
        displayOnForeground: true,
        displayOnBackground: true,
        wakeUpScreen: (channelKey == 'call_channel'),
        fullScreenIntent: (channelKey == 'call_channel'),
        criticalAlert: (channelKey == 'call_channel'),
        autoDismissible: (channelKey != 'call_channel'),
        timeoutAfter: (channelKey == 'call_channel') ? const Duration(seconds: 30) : null,
      ),
      actionButtons: actions,
    );
  }

  static Future<void> firebaseInit() async {
    Utils.showLog("notification firebase init");

    // Handle foreground messages

    FirebaseMessaging.onMessage.listen((message) {
      Utils.showLog("Notification service firebase init => $currentAppLifecycleState");
      Utils.showLog("Notification AAA => ${message.data}");
      // Utils.showLog("Notification data AAA => $jsonEncode($message)");
      Utils.showLog("Notification => ${message.data["type"]}");

      // Log both data and notification content for debugging
      Utils.showLog("Data Title => ${message.data['title']}");
      Utils.showLog("Data Body => ${message.data['body']}");
      Utils.showLog("Notification Title => ${message.notification?.title.toString()}");
      Utils.showLog("Notification Body => ${message.notification?.body.toString()}");

      if (message.data["type"] == null) return;

      // Always show custom notification regardless of app state
      if (currentAppLifecycleState == AppLifecycleState.resumed) {
        Utils.showLog("app is in the foreground.");
        if ((Get.currentRoute == AppRoutes.personalChatScreen || Get.currentRoute == AppRoutes.hostPersonalChatScreen) &&
            message.data["type"] == "CHAT") {
          Utils.showLog("User is already on a chat screen. Suppressing notification.");
        } else if (message.data['type'] == 'listener_verified') {
          Get.dialog(
            barrierDismissible: false,
            barrierColor: AppColors.black.withValues(alpha: 0.8),
            Dialog(
              backgroundColor: AppColors.transparent,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              child: const AppRestartDialog(),
            ),
          );
        } else {
          showAwesomeNotification(message);
        }
      } else if ((currentAppLifecycleState == AppLifecycleState.paused)) {
        Utils.showLog("app is in background/paused.");
        showAwesomeNotification(message);
      }
    });

    // Handle background/terminated app notifications
    FirebaseMessaging.onBackgroundMessage(backgroundNotification);
    // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle notification tap when app was in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Utils.showLog("App opened from notification: ${message.data}");
      onHandleNotificationNavigation(message.data);
    });
  }

  // static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //   // Example: Show notification using Awesome Notifications
  //   AwesomeNotifications().createNotification(
  //     content: NotificationContent(
  //       id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
  //       channelKey: 'chat_channel',
  //       title: message.data['title'],
  //       body: message.data['body'],
  //     ),
  //   );
  // }
}

@pragma('vm:entry-point')
Future<void> backgroundNotification(RemoteMessage message) async {
  Utils.showLog("background notification AAA");
  // await Firebase.initializeApp();
  await NotificationServices.showAwesomeNotification(message);
}

/// simple local notification code
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// class NotificationServices {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   static Future<void> initialize() async {
//     const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_notification');
//
//     const InitializationSettings initSettings = InitializationSettings(
//       android: androidSettings,
//     );
//
//     await _notificationsPlugin.initialize(initSettings);
//
//     // Handle foreground notifications
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       if (message.notification != null) {
//         showNotification(
//           id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
//           title: message.notification!.title ?? '',
//           body: message.notification!.body ?? '',
//         );
//       }
//     });
//   }
//
//   static Future<void> showNotification({
//     required int id,
//     required String title,
//     required String body,
//   }) async {
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'channel_id',
//       'Local Notifications',
//       channelDescription: 'This is a local notification channel',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//
//     const NotificationDetails notificationDetails = NotificationDetails(
//       android: androidDetails,
//     );
//
//     await _notificationsPlugin.show(id, title, body, notificationDetails);
//   }
// }

import 'dart:developer';

import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:talk_in/utils/utils.dart';

class PermissionHandler {
  static Future<void> notificationPermissions() async {
    await Permission.notification.request();
    await Permission.notification.isDenied.then((value) {
      if (value) {
        Permission.notification.request();
      }
    });
  }

  static Future<void> microphonePermissions() async {
    await Permission.notification.request();
    await Permission.notification.isDenied.then((value) {
      if (value) {
        Permission.notification.request();
      }
    });
  }

  static Future<void> onGetCameraPermission({
    required Callback onGranted,
    Callback? onDenied,
  }) async {
    try {
      PermissionStatus status = await Permission.camera.request();

      if (status == PermissionStatus.denied) {
        Utils.showToast(Get.context!, "Please allow camera permission.");
        onDenied?.call();
      } else if (status == PermissionStatus.permanentlyDenied) {
        Utils.showToast(Get.context!, "Please allow camera permission in settings.");
        await openAppSettings();
        onDenied?.call();
      } else {
        log("Camera Permission Granted");
        onGranted.call();
      }
    } catch (e) {
      onDenied?.call();
      log("Camera Permission Failed => $e");
    }
  }

  static Future<void> onGetMicrophonePermission({
    required Callback onGranted,
    Callback? onDenied,
  }) async {
    try {
      PermissionStatus status = await Permission.microphone.request();

      if (status == PermissionStatus.denied) {
        Utils.showToast(Get.context!, "Please allow microphone permission.");
        onDenied?.call();
      } else if (status == PermissionStatus.permanentlyDenied) {
        Utils.showToast(Get.context!, "Please allow microphone permission in settings.");
        await openAppSettings();
        onDenied?.call();
      } else {
        log("microphone Permission Granted");
        onGranted.call();
      }
    } catch (e) {
      onDenied?.call();
      log("microphone Permission Failed => $e");
    }
  }

  // static Future<void> cameraPermissions() async {
  //   await Permission.camera.request();
  //   await Permission.camera.isDenied.then((value) {
  //     if (value) {
  //       Permission.camera.request();
  //     }
  //   });
  // }

  static Future<void> storagePermissions() async {
    await Permission.storage.request();
    await Permission.storage.isDenied.then((value) {
      if (value) {
        Permission.storage.request();
      }
    });
  }
}

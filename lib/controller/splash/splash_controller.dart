import 'dart:io'; // For Platform checks
import 'package:device_info_plus/device_info_plus.dart'; // For device info
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../notification_services .dart';
import '../../utility/app_colors.dart';
import '../../utility/app_routes.dart';
import '../../utility/app_utility.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // For Firebase

class SplashController extends GetxController {
  final NotificationServices _notificationServices = NotificationServices();

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await AppUtility.initialize();

    List<Permission> permissionsToRequest = [];
    bool isAndroid13OrAbove = await _isAndroid13OrAbove();
    bool isAndroid12OrAbove = await _isAndroid12OrAbove();

    // Check which runtime permissions need to be requested
    if (await Permission.camera.isDenied) {
      permissionsToRequest.add(Permission.camera);
    }
    if (await Permission.notification.isDenied) {
      permissionsToRequest.add(Permission.notification);
    }
    if (Platform.isAndroid && isAndroid13OrAbove) {
      if (await Permission.photos.isDenied) {
        permissionsToRequest.add(Permission.photos); // For READ_MEDIA_IMAGES
      }
    } else if (Platform.isAndroid && await Permission.storage.isDenied) {
      permissionsToRequest.add(
        Permission.storage,
      ); // For WRITE_EXTERNAL_STORAGE
    } else if (Platform.isIOS && await Permission.photos.isDenied) {
      permissionsToRequest.add(Permission.photos);
    }
    if (Platform.isAndroid && isAndroid12OrAbove) {
      if (await Permission.scheduleExactAlarm.isDenied) {
        permissionsToRequest.add(Permission.scheduleExactAlarm);
      }
    }

    // Request Firebase notification permission
    bool firebaseNotificationGranted = false;
    try {
      NotificationSettings settings = await _notificationServices
          .firebaseMessaging
          .requestPermission(
            alert: true,
            announcement: true,
            badge: true,
            sound: true,
          );
      firebaseNotificationGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (!firebaseNotificationGranted) {
        if (kDebugMode) {
          print('Firebase notification permission not granted');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting Firebase notification permission: $e');
      }
    }

    // Request runtime permissions if needed
    bool hasDeniedPermissions = !firebaseNotificationGranted;
    String deniedMessage =
        firebaseNotificationGranted
            ? ''
            : 'Notification access is needed to send alerts.\n';

    if (permissionsToRequest.isNotEmpty) {
      Map<Permission, PermissionStatus> statuses =
          await permissionsToRequest.request();

      if (statuses[Permission.camera]?.isDenied ?? false) {
        deniedMessage += 'Camera access is needed to take photos.\n';
        hasDeniedPermissions = true;
      }
      if (statuses[Permission.photos]?.isDenied ?? false) {
        deniedMessage +=
            'Gallery access is needed to upload images and save receipts.\n';
        hasDeniedPermissions = true;
      }
      if (statuses[Permission.storage]?.isDenied ?? false) {
        deniedMessage += 'Storage access is needed to save files.\n';
        hasDeniedPermissions = true;
      }
      if (statuses[Permission.notification]?.isDenied ?? false) {
        deniedMessage += 'Notification access is needed to send alerts.\n';
        hasDeniedPermissions = true;
      }
      if (Platform.isAndroid && isAndroid12OrAbove) {
        if (statuses[Permission.scheduleExactAlarm]?.isDenied ?? false) {
          deniedMessage +=
              'Exact alarm permission is needed for scheduled notifications.\n';
          hasDeniedPermissions = true;
        }
      }
    }

    // Inform user about non-runtime permissions or special cases
    if (Platform.isAndroid &&
        isAndroid12OrAbove &&
        !(await Permission.scheduleExactAlarm.isGranted)) {
      hasDeniedPermissions = true;
      deniedMessage +=
          'Exact alarm permission is required for precise scheduling. Please enable it in app settings.\n';
    }

    if (hasDeniedPermissions) {
      // Check for permanently denied permissions
      bool anyPermanentlyDenied = false;
      for (var permission in permissionsToRequest) {
        if (await permission.isPermanentlyDenied) {
          anyPermanentlyDenied = true;
          break;
        }
      }

      Get.snackbar(
        'Permissions Required',
        deniedMessage,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.info_outline, color: Colors.white),
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () async {
            if (anyPermanentlyDenied || !firebaseNotificationGranted) {
              await openAppSettings();
            } else {
              await permissionsToRequest.request();
              if (!firebaseNotificationGranted) {
                await _notificationServices.requestNotificationPermission();
              }
            }
          },
          child: const Text(
            'Grant Permissions',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
      await Future.delayed(const Duration(seconds: 3));
    }

    // Initialize Firebase notifications if permission is granted
    if (firebaseNotificationGranted) {
      try {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _notificationServices.firebaseInit(Get.context!);
          _notificationServices.setInteractMessage(Get.context!);
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error initializing Firebase notifications: $e');
        }
      }
    }

    // Navigate after permission handling
    await Future.delayed(const Duration(seconds: 2));
    Get.offNamed(AppUtility.isLoggedIn ? AppRoutes.home : AppRoutes.welcome);
  }

  // Helper method to check Android version (API 33+ for READ_MEDIA_IMAGES)
  Future<bool> _isAndroid13OrAbove() async {
    if (Platform.isAndroid) {
      try {
        var androidInfo = await DeviceInfoPlugin().androidInfo;
        return androidInfo.version.sdkInt >= 33;
      } catch (e) {
        if (kDebugMode) {
          print('Error checking Android version: $e');
        }
        return false;
      }
    }
    return false;
  }

  // Helper method to check Android version (API 31+ for SCHEDULE_EXACT_ALARM)
  Future<bool> _isAndroid12OrAbove() async {
    if (Platform.isAndroid) {
      try {
        var androidInfo = await DeviceInfoPlugin().androidInfo;
        return androidInfo.version.sdkInt >= 31;
      } catch (e) {
        if (kDebugMode) {
          print('Error checking Android version: $e');
        }
        return false;
      }
    }
    return false;
  }
}

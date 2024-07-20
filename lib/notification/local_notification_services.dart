import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  if (kDebugMode) {
    print('HELLO BACKGROUND CALLBACK ${notificationResponse.payload}');
  }
}

/// BACKGROUND NOTIFICATION
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.showNotifications(message);
}

final StreamController<String?> selectNotificationStream = StreamController<String?>.broadcast();

/// CLICK EVENT HANDLE WHEN APP BACKGROUND
void _configureSelectNotificationSubject() {
  selectNotificationStream.stream.listen((String? payload) async {
    Map<String, dynamic> str = jsonDecode(payload!);
    if (kDebugMode) {
      print('HELLO LISTEN selectNotificationStream $str');
    }
  });
}

class NotificationService {
  //Singleton pattern
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() => _notificationService;

  NotificationService._internal();

  static String? selectedNotificationPayload;

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // static const String channelId = '123';
  // static const channelName = 'Flutter';
  // static const channelDescription = 'FlutterNotification';
  static final StreamController<Map<String, dynamic>> controllerPayload = StreamController<Map<String, dynamic>>();

  static Stream<Map<String, dynamic>> get streamPayload => controllerPayload.stream;

  static NotificationAppLaunchDetails? notificationAppLaunchDetails;

  static final FirebaseMessaging messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    /// INITIALIZE MESSAGING
    NotificationSettings settings = await messaging.requestPermission(alert: true, announcement: false, badge: true, carPlay: false, criticalAlert: false, provisional: false, sound: true);

    if (kDebugMode) {
      print('Hello Firebase authorizationStatus :- ${settings.authorizationStatus}');
    }
    messaging.subscribeToTopic('all_users');

    /// FOREGROUND NOTIFICATION
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await NotificationService.showNotifications(message);
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      selectedNotificationPayload = notificationAppLaunchDetails!.notificationResponse?.payload;
    }

    // const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings("@mipmap/icon_app");

    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later
    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
        requestSoundPermission: true,
        defaultPresentSound: true,
        requestAlertPermission: true,
        defaultPresentAlert: true,
        requestBadgePermission: false,
        defaultPresentBadge: false,
        defaultPresentBanner: false,
        defaultPresentList: false,
        requestCriticalPermission: false,
        requestProvisionalPermission: false);
    //for IOS Foreground Notification
    await messaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, badge: true, sound: true);
    const InitializationSettings initializationSettings = InitializationSettings(/*android: initializationSettingsAndroid,*/ iOS: initializationSettingsDarwin);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        selectNotificationStream.add(notificationResponse.payload);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    _configureSelectNotificationSubject();
  }

  static Future<void> showNotifications(RemoteMessage message) async {
    if (kDebugMode) {
      print('Hello Firebase show ${message.toMap()}');
    }
    await flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification!.title,
        message.notification!.body,
        const NotificationDetails(
          // android: AndroidNotificationDetails(channelId, channelName, icon: "@mipmap/icon_app", priority: Priority.high, importance: Importance.max, enableVibration: true, ticker: 'ticker'),
          iOS: DarwinNotificationDetails(presentSound: true),
        ),
        payload: jsonEncode(message.data));
  }

  static Future<void> cancelNotifications(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  static void close() {
    controllerPayload.close();
  }
}

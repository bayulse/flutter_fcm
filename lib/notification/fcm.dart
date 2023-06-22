import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'local_notification.dart';

class FCM {
  FCM._();

  static late ValueChanged<String?> _onTokenChanged;

  static initializeFCM({
    required void onTokenChanged(String? token),
    void onNotificationPressed(Map<String, dynamic> data)?,
    required BackgroundMessageHandler onNotificationReceived,
    GlobalKey<NavigatorState>? navigatorKey,
    required String icon,
    bool withLocalNotification = true,
  }) async {
    _onTokenChanged = onTokenChanged;
    await LocalNotification.initializeLocalNotification(
        onNotificationPressed: onNotificationPressed, icon: icon);
    await FirebaseMessaging.instance.getToken().then(onTokenChanged);
    Stream<String> _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    _tokenStream.listen(onTokenChanged);

    // Set the background messaging handler early on, as a named top-level function
    FirebaseMessaging.onBackgroundMessage(onNotificationReceived);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      debugPrint('getInitialMessage');
      debugPrint(message.toString());
      if (message != null) {
        if (navigatorKey != null)
          Timer.periodic(
            Duration(milliseconds: 500),
            (timer) {
              if (navigatorKey.currentState == null) return;
              onNotificationPressed!(message.data);
              timer.cancel();
            },
          );
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('A new onMessage event was published!');

      onNotificationReceived(message);
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null && withLocalNotification) {
        LocalNotification.showNotification(
            notification: notification, payload: message.data, icon: icon);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      onNotificationPressed!(message.data);
    });

    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      debugPrint('A new onBackgroundMessage event was published!');
      onNotificationPressed!(message.data);
      onNotificationReceived(message);
    });
  }

  static Future deleteRefreshToken() async {
    await FirebaseMessaging.instance.deleteToken();
    await FirebaseMessaging.instance.getToken().then(_onTokenChanged);
  }
}

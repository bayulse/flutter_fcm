import 'package:flutter/material.dart';
import 'package:flutter_fcm/flutter_fcm.dart';

void main() {
  Messaging.initFCM();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter FCM Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class Messaging {
  static String? token;
  static initFCM() async {
    try {
      await FCM.initializeFCM(
        onNotificationReceived: (RemoteMessage message) async {},
        onNotificationPressed: (Map<String, dynamic> data) {
          debugPrint(data.toString());
        },
        onTokenChanged: (token) {
          Messaging.token = token;
          debugPrint(token);
        },
        icon: 'icon',
      );
    } catch (e) {}
  }
}

import 'package:firebase_messaging/firebase_messaging.dart';

class FcmReceive{
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  void main() async{
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  void foreground(){
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      // Access the notification title and body
      print('FCM Notification Title: ${message.notification?.title}');
      print('FCM Notification Body: ${message.notification?.body}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }


  }

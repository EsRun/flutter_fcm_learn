
import 'dart:convert';

import 'package:fcm_learn/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

class Fcm{
  // fcm 인스턴스 생성
  final _firebaseMessaging = FirebaseMessaging.instance;

  // foreground 알람을 위해 채널 생성
  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  // 함수 초기화
  Future<void> initNotifications() async{
    // 알람 설정
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // 기기 토큰 가져오기
    final fcmToken = await _firebaseMessaging.getToken();
    var logger = Logger();
    logger.e(fcmToken);

    // 푸시알람 실행
    initPushNotification();
  }

  // 푸시 메세지 클릭 시 페이지 이동
  void handleMessage(RemoteMessage? message){
    if(message == null) return;

    /* background fcm 알람 클릭 시 페이지 이동
    navigatorKey.currentState?.pushNamed(
      '/notification_screen',
      arguments: message,
    );
    */
  }
  
  Future initPushNotification() async{
    // foreground 알람 플러그인 생성
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    // foreground 알람 채널 설정
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // fcm 알림 초기 메세지 수신 시 실행
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    // background 실행 중 fcm 알림 클릭 시 실행, 원하는 페이지로 이동 가능
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    // foreground 실행 중 fcm 메세지 수신 시 실행(
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              icon: android?.smallIcon,
              // other properties...
            ),
          )
        );
      }
    });
  }
}

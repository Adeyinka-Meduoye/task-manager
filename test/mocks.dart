import 'package:flutter_local_notifications/flutter_local_notifications.dart' as flutter_local_notifications;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart' as mockito;
import 'package:todo_app/services/notification_service.dart' as notification_service;
import 'package:todo_app/services/storage_service.dart' as storage_service;

@GenerateMocks([
  storage_service.StorageService,
  notification_service.NotificationService,
])
void main() {}

class MockStorageService extends mockito.Mock implements storage_service.StorageService {}

class MockNotificationService extends mockito.Mock implements notification_service.NotificationService {
  @override
  Future<void> initialize() => super.noSuchMethod(
        Invocation.method(#initialize, []),
        returnValue: Future.value(),
      );

  @override
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    flutter_local_notifications.tz.TZDateTime.from(scheduledTime, tz.local),
    flutter_local_notifications.NotificationDetails notificationDetails, {
    bool androidAllowWhileIdle = false,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #zonedSchedule,
          [id, title, body, scheduledDate, notificationDetails],
          {#androidAllowWhileIdle: flutter_local_notifications.AndroidScheduleMode},
        ),
        returnValue: Future.value(),
      );

  @override
  Future<void> cancelNotification(int id) => super.noSuchMethod(
        Invocation.method(#cancelNotification, [id]),
        returnValue: Future.value(),
      );
}
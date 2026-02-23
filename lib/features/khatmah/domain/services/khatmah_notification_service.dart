import '../../../../core/notifications/notifications_service.dart';

class KhatmahNotificationService {
  const KhatmahNotificationService();

  Future<void> scheduleDailyReminder({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    if (!enabled) {
      await NotificationsService.cancelKhatmahReminder();
      return;
    }

    await NotificationsService.scheduleKhatmahReminder(
      hour: hour,
      minute: minute,
      title: 'ورد الختمة',
      body: 'وردك اليومي جاهز، افتح التطبيق وأكمل الختمة',
    );
  }

  Future<void> cancelReminder() => NotificationsService.cancelKhatmahReminder();
}

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../data/providers/api_provider.dart';
import '../../data/services/auth_api.dart';
import '../../data/services/parent_api.dart';
import '../../data/models/parent_models.dart';
import '../../data/models/models.dart';
import '../../routes/app_routes.dart';

class ParentController extends GetxController {
  final AuthApi _authApi = AuthApi();
  final ParentApi _parentApi = ParentApi();

  final children = <StudentChild>[].obs;
  final announcements = <ChildAnnouncement>[].obs;
  final attendance = <ChildAttendance>[].obs;
  final notifications = <AppNotification>[].obs;
  final isLoading = true.obs;
  final showChat = false.obs;
  final unreadMessageCount = 0.obs;

  AuthService get _auth => Get.find<AuthService>();
  String get userName => _auth.userFullName;

  int get unreadNotificationCount =>
      notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    loadData();
    loadUnreadMessageCount();
  }

  Future<void> loadUnreadMessageCount() async {
    try {
      final count = await _parentApi.getUnreadMessageCount();
      unreadMessageCount.value = count;
    } catch (e) {
      debugPrint('Error loading unread message count: $e');
    }
  }

  void updateUnreadMessageCount(int count) {
    unreadMessageCount.value = count.clamp(0, 999);
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _parentApi.getChildren(),
        _parentApi.getAnnouncements(),
        _parentApi.getAttendance(),
        _parentApi.getNotifications(),
      ]);
      children.value = results[0] as List<StudentChild>;
      announcements.value = results[1] as List<ChildAnnouncement>;
      attendance.value = results[2] as List<ChildAttendance>;
      notifications.value = results[3] as List<AppNotification>;
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _parentApi.markNotificationAsRead(notificationId);
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = AppNotification(
          id: notifications[index].id,
          recipient: notifications[index].recipient,
          type: notifications[index].type,
          title: notifications[index].title,
          message: notifications[index].message,
          isRead: true,
          createdAt: notifications[index].createdAt,
        );
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      for (var notification in notifications.where((n) => !n.isRead)) {
        await _parentApi.markNotificationAsRead(notification.id);
      }
      notifications.value = notifications
          .map(
            (n) => AppNotification(
              id: n.id,
              recipient: n.recipient,
              type: n.type,
              title: n.title,
              message: n.message,
              isRead: true,
              createdAt: n.createdAt,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  void toggleChat() {
    showChat.value = !showChat.value;
  }

  Future<void> logout() async {
    try {
      await _authApi.logout();
    } catch (e) {
      // Continue even if logout fails
    }
    _auth.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}

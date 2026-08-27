import 'user_service.dart';

class NotificationService {
  final UserService _userService = UserService();

  Future<List<dynamic>> getNotifications() => _userService.getNotifications();
  Future<bool> markAsRead(String id) => _userService.markNotificationRead(id);
}

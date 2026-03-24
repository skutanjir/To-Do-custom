import 'package:pdbl_testing_custom_mobile/core/network/api_client.dart';

class NotificationService {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> getNotifications({int page = 1}) async {
    final response = await _api.get('/notifications?page=$page');
    return response.data;
  }

  Future<void> markAsRead(int id) async {
    await _api.post('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _api.post('/notifications/read-all');
  }

  Future<void> deleteNotification(int id) async {
    await _api.delete('/notifications/$id');
  }
}

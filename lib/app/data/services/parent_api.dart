import 'package:get/get.dart';
import '../providers/api_provider.dart';
import '../models/parent_models.dart';

class ParentApi {
  final ApiProvider _api = Get.find<ApiProvider>();

  Future<List<StudentChild>> getChildren() async {
    final response = await _api.get('/users/parent/children/');
    final List<dynamic> data = response.data;
    return data.map((json) => StudentChild.fromJson(json)).toList();
  }

  Future<List<ChildAnnouncement>> getAnnouncements() async {
    final response = await _api.get('/users/parent/announcements/');
    final List<dynamic> data = response.data;
    return data.map((json) => ChildAnnouncement.fromJson(json)).toList();
  }
}

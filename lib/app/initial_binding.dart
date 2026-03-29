import 'package:get/get.dart';
import 'modules/admin/admin_controller.dart';
import 'modules/teacher/teacher_controller.dart';
import 'modules/student/student_controller.dart';
import 'modules/parent/parent_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminController>(() => AdminController());
    Get.lazyPut<TeacherController>(() => TeacherController());
    Get.lazyPut<StudentController>(() => StudentController());
    Get.lazyPut<ParentController>(() => ParentController());
  }
}

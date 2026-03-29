import 'package:get/get.dart';
import 'parent_controller.dart';

class ParentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentController>(() => ParentController());
  }
}

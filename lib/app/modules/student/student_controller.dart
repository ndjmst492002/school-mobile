import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/providers/api_provider.dart';
import '../../data/services/auth_api.dart';
import '../../data/services/student_api.dart';
import '../../data/models/models.dart';
import '../../routes/app_routes.dart';

class StudentController extends GetxController {
  final AuthApi _authApi = AuthApi();
  final StudentApi _studentApi = StudentApi();

  final classes = <ClassModel>[].obs;
  final exercises = <Exercise>[].obs;
  final submissions = <Submission>[].obs;
  final announcements = <Announcement>[].obs;
  final isLoading = true.obs;
  final enrolling = Rxn<int>();
  final selectedExercise = Rxn<Exercise>();
  final selectedSubmitFile = Rxn<PlatformFile>();
  final isSubmitting = false.obs;

  AuthService get _auth => Get.find<AuthService>();
  String get userName => _auth.userFullName;
  int get userId => _auth.userId;

  int get enrolledCount =>
      classes.where((c) => c.students?.contains(userId) ?? false).length;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _studentApi.getAllClasses(),
        _studentApi.getExercises(),
        _studentApi.getSubmissions(),
        _studentApi.getAnnouncements(),
      ]);
      classes.value = results[0] as List<ClassModel>;
      exercises.value = results[1] as List<Exercise>;
      submissions.value = results[2] as List<Submission>;
      announcements.value = results[3] as List<Announcement>;
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool isEnrolled(int classId) {
    final cls = classes.firstWhereOrNull((c) => c.id == classId);
    return cls?.students?.contains(userId) ?? false;
  }

  Future<void> enrollInClass(int classId) async {
    enrolling.value = classId;
    try {
      await _studentApi.enrollInClass(classId);
      loadData();
      Get.snackbar('Success', 'Enrolled in class successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to enroll in class');
    } finally {
      enrolling.value = null;
    }
  }

  bool isSubmitted(int exerciseId) {
    return submissions.any((s) => s.exercise == exerciseId);
  }

  Submission? getSubmission(int exerciseId) {
    return submissions.firstWhereOrNull((s) => s.exercise == exerciseId);
  }

  bool isOverdue(Exercise exercise) {
    if (exercise.dueDate == null) return false;
    try {
      final dueDate = DateTime.parse(exercise.dueDate!);
      return dueDate.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  String downloadExerciseUrl(int exerciseId) {
    return _studentApi.downloadExerciseUrl(exerciseId);
  }

  void downloadExercise(int exerciseId) {
    final url = downloadExerciseUrl(exerciseId);
    debugPrint('Download URL: $url');
    if (kIsWeb) {
      html.window.open(url, '_blank');
    } else {
      Get.snackbar('Download', 'URL: $url');
    }
  }

  void openSubmitDialog(Exercise exercise) {
    selectedExercise.value = exercise;
    selectedSubmitFile.value = null;
  }

  void closeSubmitDialog() {
    selectedExercise.value = null;
    selectedSubmitFile.value = null;
  }

  Future<void> pickSubmitFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        selectedSubmitFile.value = result.files.first;
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  Future<void> submitExercise() async {
    if (selectedExercise.value == null || selectedSubmitFile.value == null)
      return;

    isSubmitting.value = true;
    try {
      final file = selectedSubmitFile.value!;
      String? filePath;
      Uint8List? fileBytes;
      String? fileName;

      if (kIsWeb) {
        fileBytes = file.bytes;
        fileName = file.name;
      } else {
        filePath = file.path;
      }

      await _studentApi.submitExercise(
        exerciseId: selectedExercise.value!.id,
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      closeSubmitDialog();
      loadData();
      Get.snackbar('Success', 'Exercise submitted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit exercise');
    } finally {
      isSubmitting.value = false;
    }
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

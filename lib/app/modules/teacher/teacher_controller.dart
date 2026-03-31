import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/providers/api_provider.dart';
import '../../data/services/auth_api.dart';
import '../../data/services/teacher_api.dart';
import '../../data/models/models.dart';
import '../../routes/app_routes.dart';

class TeacherController extends GetxController {
  final AuthApi _authApi = AuthApi();
  final TeacherApi _teacherApi = TeacherApi();

  final classes = <ClassModel>[].obs;
  final exercises = <Exercise>[].obs;
  final submissions = <Submission>[].obs;
  final announcements = <Announcement>[].obs;
  final isLoading = true.obs;
  final showUploadForm = false.obs;
  final showAnnouncementForm = false.obs;
  final showChat = false.obs;
  final gradingSubmission = Rxn<Submission>();
  final isGrading = false.obs;
  final isUploading = false.obs;
  final isPosting = false.obs;
  final selectedFile = Rxn<PlatformFile>();

  final uploadClassId = ''.obs;
  final announcementClassId = ''.obs;

  final uploadTitleController = TextEditingController();
  final uploadDescController = TextEditingController();
  final uploadDueDateController = TextEditingController();
  final announcementTitleController = TextEditingController();
  final announcementContentController = TextEditingController();
  final gradeController = TextEditingController();
  final feedbackController = TextEditingController();

  AuthService get _auth => Get.find<AuthService>();
  String get userName => _auth.userFullName;

  int get totalStudents =>
      classes.fold(0, (sum, cls) => sum + cls.studentCount);
  int get pendingCount => submissions.where((s) => s.grade == null).length;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  @override
  void onClose() {
    uploadTitleController.dispose();
    uploadDescController.dispose();
    uploadDueDateController.dispose();
    announcementTitleController.dispose();
    announcementContentController.dispose();
    gradeController.dispose();
    feedbackController.dispose();
    super.onClose();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      debugPrint('Loading teacher data...');
      final results = await Future.wait([
        _teacherApi.getClasses(),
        _teacherApi.getExercises(),
        _teacherApi.getSubmissions(),
        _teacherApi.getAnnouncements(),
      ]);
      classes.value = results[0] as List<ClassModel>;
      exercises.value = results[1] as List<Exercise>;
      submissions.value = results[2] as List<Submission>;
      announcements.value = results[3] as List<Announcement>;
      debugPrint(
        'Loaded ${classes.length} classes, ${exercises.length} exercises',
      );
    } catch (e) {
      debugPrint('Error loading data: $e');
      Get.snackbar(
        'Error',
        'Failed to load data: $e',
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void toggleUploadForm() {
    showUploadForm.value = !showUploadForm.value;
    if (!showUploadForm.value) {
      uploadTitleController.clear();
      uploadDescController.clear();
      uploadDueDateController.clear();
      uploadClassId.value = '';
      selectedFile.value = null;
    }
  }

  void toggleAnnouncementForm() {
    showAnnouncementForm.value = !showAnnouncementForm.value;
    if (!showAnnouncementForm.value) {
      announcementTitleController.clear();
      announcementContentController.clear();
      announcementClassId.value = '';
    }
  }

  void toggleChat() {
    showChat.value = !showChat.value;
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        selectedFile.value = result.files.first;
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  Future<void> uploadExercise() async {
    if (selectedFile.value == null || uploadClassId.value.isEmpty) {
      Get.snackbar('Error', 'Please select a file and class');
      return;
    }

    isUploading.value = true;
    try {
      debugPrint(
        'Uploading exercise: title=${uploadTitleController.text}, classId=${uploadClassId.value}',
      );

      final file = selectedFile.value!;
      String? filePath;
      Uint8List? fileBytes;
      String? fileName;

      if (kIsWeb) {
        fileBytes = file.bytes;
        fileName = file.name;
      } else {
        filePath = file.path;
      }

      await _teacherApi.createExercise(
        title: uploadTitleController.text,
        description: uploadDescController.text,
        classId: int.parse(uploadClassId.value),
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
        dueDate: uploadDueDateController.text.isNotEmpty
            ? uploadDueDateController.text
            : null,
      );
      toggleUploadForm();
      loadData();
      Get.snackbar('Success', 'Exercise uploaded successfully');
    } catch (e) {
      debugPrint('Error uploading exercise: $e');
      Get.snackbar('Error', 'Failed to upload exercise: $e');
    } finally {
      isUploading.value = false;
    }
  }

  void openGradingDialog(Submission submission) {
    gradingSubmission.value = submission;
    gradeController.text = submission.grade?.toString() ?? '';
    feedbackController.text = submission.feedback ?? '';
  }

  void closeGradingDialog() {
    gradingSubmission.value = null;
    gradeController.clear();
    feedbackController.clear();
  }

  Future<void> gradeSubmission() async {
    if (gradingSubmission.value == null || gradeController.text.isEmpty) return;

    final grade = double.tryParse(gradeController.text);
    if (grade == null || grade < 0 || grade > 20) {
      Get.snackbar('Error', 'Grade must be between 0 and 20');
      return;
    }

    isGrading.value = true;
    try {
      await _teacherApi.gradeSubmission(
        gradingSubmission.value!.id,
        grade,
        feedbackController.text,
      );
      closeGradingDialog();
      loadData();
      Get.snackbar('Success', 'Grade saved successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to grade submission');
    } finally {
      isGrading.value = false;
    }
  }

  void updateUploadClassId(String value) => uploadClassId.value = value;
  void updateAnnouncementClassId(String value) =>
      announcementClassId.value = value;

  Future<void> createAnnouncement() async {
    if (announcementTitleController.text.isEmpty ||
        announcementContentController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in both title and content');
      return;
    }

    isPosting.value = true;
    try {
      debugPrint(
        'Creating announcement: title=${announcementTitleController.text}',
      );
      final classId = announcementClassId.value.isNotEmpty
          ? int.tryParse(announcementClassId.value)
          : null;
      await _teacherApi.createAnnouncement(
        title: announcementTitleController.text,
        content: announcementContentController.text,
        classId: classId,
      );
      toggleAnnouncementForm();
      loadData();
      Get.snackbar('Success', 'Announcement posted successfully');
    } catch (e) {
      debugPrint('Error creating announcement: $e');
      Get.snackbar('Error', 'Failed to create announcement: $e');
    } finally {
      isPosting.value = false;
    }
  }

  String downloadSubmissionUrl(int submissionId) {
    return _teacherApi.downloadSubmissionUrl(submissionId);
  }

  // FIXED: Now works on both web and mobile
  Future<void> downloadSubmission(int submissionId) async {
    final url = downloadSubmissionUrl(submissionId);
    debugPrint('Download URL: $url');

    // Find the submission to check if it has a file
    final submission = submissions.firstWhereOrNull(
          (s) => s.id == submissionId,
    );
    if (submission == null) {
      Get.snackbar('Error', 'Submission not found');
      return;
    }

    if (submission.submissionFileUrl == null) {
      Get.snackbar('Error', 'No file attached to this submission');
      return;
    }

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Cannot open download link');
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
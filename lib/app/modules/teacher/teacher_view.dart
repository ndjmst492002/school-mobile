import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'teacher_controller.dart';
import '../chat/chat_view.dart';
import '../chat/chat_controller.dart';

class TeacherView extends GetView<TeacherController> {
  const TeacherView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Teacher Dashboard'),
          actions: [
            Obx(
                  () => controller.showChat.value
                  ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Get.delete<ChatController>();
                  controller.toggleChat();
                },
              )
                  : IconButton(
                icon: const Icon(Icons.chat),
                onPressed: () {
                  Get.put(ChatController());
                  controller.toggleChat();
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: controller.logout,
            ),
          ],
        ),
        body: controller.showChat.value
            ? ChatView(
          onClose: () {
            Get.delete<ChatController>();
            controller.toggleChat();
          },
        )
            : _buildContent(),
      );
    });
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: controller.loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
                  () => Text(
                'Welcome, ${controller.userName}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            _buildStatsCards(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildAnnouncementsCard(),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildClassesCard()),
                const SizedBox(width: 16),
                Expanded(child: _buildExercisesCard()),
              ],
            ),
            const SizedBox(height: 24),
            _buildSubmissionsCard(),
            const SizedBox(height: 24),
            _buildGradingDialog(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Obx(
          () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatChip('Announcements', '${controller.announcements.length}'),
            const SizedBox(width: 8),
            _buildStatChip('Students', '${controller.totalStudents}'),
            const SizedBox(width: 8),
            _buildStatChip('Exercises', '${controller.exercises.length}'),
            const SizedBox(width: 8),
            _buildStatChip('Submissions', '${controller.submissions.length}'),
            const SizedBox(width: 8),
            _buildStatChip('Pending', '${controller.pendingCount}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      label: Text(label),
    );
  }

  Widget _buildQuickActions() {
    return Obx(
          () => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.toggleUploadForm,
                  icon: const Icon(Icons.upload),
                  label: Text(
                    controller.showUploadForm.value ? 'Cancel' : 'Upload Exercise',
                    style: const TextStyle(fontSize: 11.9),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.toggleAnnouncementForm,
                  icon: const Icon(Icons.campaign),
                  label: Text(
                    controller.showAnnouncementForm.value ? 'Cancel' : 'Announcement',
                    style: const TextStyle(fontSize: 11.9),
                  ),
                ),
              ),
            ],
          ),
          if (controller.showUploadForm.value) _buildUploadForm(),
          if (controller.showAnnouncementForm.value) _buildAnnouncementForm(),
        ],
      ),
    );
  }

  Widget _buildUploadForm() {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Exercise',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.uploadTitleController,
              decoration: const InputDecoration(labelText: 'Title *'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.uploadDescController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (ctx) => GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    controller.uploadDueDateController.text =
                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: controller.uploadDueDateController,
                    decoration: InputDecoration(
                      labelText: 'Due Date',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            controller.uploadDueDateController.text =
                            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Obx(
                  () => DropdownButtonFormField<String>(
                value: controller.uploadClassId.value.isEmpty
                    ? null
                    : controller.uploadClassId.value,
                decoration: const InputDecoration(labelText: 'Select Class *'),
                items: controller.classes
                    .map(
                      (cls) => DropdownMenuItem(
                    value: cls.id.toString(),
                    child: Text('${cls.name} (${cls.studentCount})'),
                  ),
                )
                    .toList(),
                onChanged: (v) => controller.updateUploadClassId(v ?? ''),
              ),
            ),
            const SizedBox(height: 12),
            // File display section
            Obx(() {
              final selectedFile = controller.selectedFile.value;
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      selectedFile != null ? Icons.insert_drive_file : Icons.attach_file,
                      size: 20,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedFile != null
                            ? selectedFile.name
                            : 'No file selected',
                        style: TextStyle(
                          fontSize: 13,
                          color: selectedFile != null ? Colors.black : Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (selectedFile != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () {
                          controller.selectedFile.value = null;
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            // Buttons
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 400;

                if (isSmallScreen) {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: controller.pickFile,
                          icon: const Icon(Icons.folder_open, size: 18),
                          label: const Text('Choose File'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                            () => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isUploading.value
                                ? null
                                : controller.uploadExercise,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: Text(
                              controller.isUploading.value ? 'Uploading...' : 'Upload',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.pickFile,
                          icon: const Icon(Icons.folder_open, size: 18),
                          label: const Text('Choose File'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 140,
                        child: Obx(
                              () => ElevatedButton(
                            onPressed: controller.isUploading.value
                                ? null
                                : controller.uploadExercise,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: Text(
                              controller.isUploading.value ? 'Uploading...' : 'Upload',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementForm() {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Announcement',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.announcementTitleController,
              decoration: const InputDecoration(labelText: 'Title *'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.announcementContentController,
              decoration: const InputDecoration(labelText: 'Content *'),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            Obx(
                  () => DropdownButtonFormField<String>(
                value: controller.announcementClassId.value.isEmpty
                    ? null
                    : controller.announcementClassId.value,
                decoration: const InputDecoration(
                  labelText: 'Class (Optional)',
                ),
                items: [
                  const DropdownMenuItem(value: '', child: Text('All Classes')),
                  ...controller.classes.map(
                        (cls) => DropdownMenuItem(
                      value: cls.id.toString(),
                      child: Text(cls.name),
                    ),
                  ),
                ],
                onChanged: (v) => controller.updateAnnouncementClassId(v ?? ''),
              ),
            ),
            const SizedBox(height: 12),
            Obx(
                  () => ElevatedButton(
                onPressed: controller.isPosting.value
                    ? null
                    : controller.createAnnouncement,
                child: Text(controller.isPosting.value ? 'Posting...' : 'Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'My Announcements',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.announcements.isEmpty) {
                return const Text('No announcements');
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.announcements.length,
                itemBuilder: (context, index) {
                  final ann = controller.announcements[index];
                  return ListTile(
                    title: Text(
                      ann.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ann.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            if (ann.className != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Class: ${ann.className}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _formatDateTime(ann.createdAt),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 8,
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildClassesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'My Classes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.classes.isEmpty) {
                return const Text('No classes');
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.classes.length,
                itemBuilder: (context, index) {
                  final cls = controller.classes[index];
                  return ListTile(
                    title: Text(
                      cls.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (cls.description.isNotEmpty)
                          Text(
                            cls.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${cls.studentCount} students enrolled',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 8,
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Exercises',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.exercises.isEmpty) {
                return const Text('No exercises');
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.exercises.length,
                itemBuilder: (context, index) {
                  final ex = controller.exercises[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Exercise title - allow 2 lines
                        Text(
                          ex.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Class name
                        if (ex.className != null && ex.className!.isNotEmpty)
                          Text(
                            ex.className!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        // Due date
                        if (ex.dueDate != null)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Due: ${ex.dueDate}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange[700],
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        // Download button
                        if (ex.fileUrl != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: () => Get.snackbar('View', 'Opening file...'),
                              icon: const Icon(Icons.download, size: 16),
                              label: const Text(
                                'Download',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                        const Divider(height: 16),
                      ],
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Submissions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.submissions.isEmpty) {
                return const Text('No submissions');
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.submissions.length > 10
                    ? 10
                    : controller.submissions.length,
                itemBuilder: (context, index) {
                  final sub = controller.submissions[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                sub.exerciseTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Grade badge
                            if (sub.grade != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${sub.grade}/20',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Pending',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Student name
                        Row(
                          children: [
                            const Icon(Icons.person, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                sub.studentName ?? 'Student',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Submission date
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Submitted: ${_formatDateTime(sub.submittedAt)}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Action buttons
                        Row(
                          children: [
                            if (sub.submissionFileUrl != null)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => controller.downloadSubmission(sub.id),
                                  icon: const Icon(Icons.download, size: 16),
                                  label: const Text(
                                    'Download',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                            if (sub.submissionFileUrl != null) const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => controller.openGradingDialog(sub),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  backgroundColor: sub.grade == null ? Colors.orange : Colors.blue,
                                ),
                                child: Text(
                                  sub.grade == null ? 'Grade' : 'Edit Grade',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                      ],
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGradingDialog() {
    return Obx(() {
      if (controller.gradingSubmission.value == null)
        return const SizedBox.shrink();
      return Container(
        color: Colors.black54,
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Grade Submission',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.gradeController,
                    decoration: const InputDecoration(
                      labelText: 'Grade (0-20)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.feedbackController,
                    decoration: const InputDecoration(labelText: 'Feedback'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                              () => ElevatedButton(
                            onPressed: controller.isGrading.value
                                ? null
                                : controller.gradeSubmission,
                            child: Text(
                              controller.isGrading.value ? 'Saving...' : 'Save',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.closeGradingDialog,
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDateTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}
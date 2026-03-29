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
      () => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildStatChip('Announcements', '${controller.announcements.length}'),
          _buildStatChip('Students', '${controller.totalStudents}'),
          _buildStatChip('Exercises', '${controller.exercises.length}'),
          _buildStatChip('Submissions', '${controller.submissions.length}'),
          _buildStatChip('Pending', '${controller.pendingCount}'),
        ],
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
                    controller.showUploadForm.value
                        ? 'Cancel'
                        : 'Upload Exercise',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.toggleAnnouncementForm,
                  icon: const Icon(Icons.campaign),
                  label: Text(
                    controller.showAnnouncementForm.value
                        ? 'Cancel'
                        : 'Announcement',
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
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: controller.pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: Text(
                    controller.selectedFile.value != null
                        ? controller.selectedFile.value!.name
                        : 'Choose File',
                  ),
                ),
                const SizedBox(width: 12),
                Obx(
                  () => ElevatedButton(
                    onPressed: controller.isUploading.value
                        ? null
                        : controller.uploadExercise,
                    child: Text(
                      controller.isUploading.value ? 'Uploading...' : 'Upload',
                    ),
                  ),
                ),
              ],
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
          children: [
            const Text(
              'My Announcements',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.announcements.isEmpty)
                return const Text('No announcements');
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.announcements.length,
                itemBuilder: (context, index) {
                  final ann = controller.announcements[index];
                  return ListTile(
                    title: Text(ann.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ann.content, maxLines: 2),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (ann.className != null) ...[
                              Text(
                                'Class: ${ann.className}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              _formatDateTime(ann.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildClassesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Classes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.classes.isEmpty) return const Text('No classes');
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.classes.length,
                itemBuilder: (context, index) {
                  final cls = controller.classes[index];
                  return ListTile(
                    title: Text(cls.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (cls.description.isNotEmpty) Text(cls.description),
                        Text(
                          '${cls.studentCount} students enrolled',
                          style: const TextStyle(fontSize: 12),
                        ),
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

  Widget _buildExercisesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exercises',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.exercises.isEmpty)
                return const Text('No exercises');
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.exercises.length,
                itemBuilder: (context, index) {
                  final ex = controller.exercises[index];
                  return ListTile(
                    title: Text(ex.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ex.className ?? ''),
                        if (ex.dueDate != null)
                          Text(
                            'Due: ${ex.dueDate}',
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                    trailing: ex.fileUrl != null
                        ? IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () =>
                                Get.snackbar('View', 'Opening file...'),
                            tooltip: 'View file',
                          )
                        : null,
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
          children: [
            const Text(
              'Submissions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.submissions.isEmpty)
                return const Text('No submissions');
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.submissions.length > 10
                    ? 10
                    : controller.submissions.length,
                itemBuilder: (context, index) {
                  final sub = controller.submissions[index];
                  return ListTile(
                    title: Text(sub.exerciseTitle),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Student: ${sub.studentName ?? "Student"}'),
                        Text(
                          'Submitted: ${_formatDateTime(sub.submittedAt)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        if (sub.grade != null)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Grade: ${sub.grade}/20',
                              style: const TextStyle(fontSize: 12),
                            ),
                          )
                        else
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Pending Grade',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (sub.submissionFileUrl != null)
                          IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () =>
                                controller.downloadSubmission(sub.id),
                            tooltip: 'Download submission',
                          ),
                        ElevatedButton(
                          onPressed: () => controller.openGradingDialog(sub),
                          child: Text(sub.grade == null ? 'Grade' : 'Edit'),
                        ),
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

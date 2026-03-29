import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/parent_models.dart';
import 'parent_controller.dart';
import '../chat/chat_view.dart';
import '../chat/chat_controller.dart';

class ParentView extends GetView<ParentController> {
  const ParentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Parent Dashboard'),
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
            : _buildBody(),
      );
    });
  }

  Widget _buildBody() {
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
            _buildAnnouncementsCard(),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildChildrenCard()),
                const SizedBox(width: 16),
                Expanded(child: _buildImportantInfoCard()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Obx(
      () => GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        children: [
          _buildStatCard(
            'My Children',
            '${controller.children.length}',
            'Enrolled students',
            Colors.blue,
            Icons.group,
          ),
          _buildStatCard(
            'Average Progress',
            controller.children.isNotEmpty ? 'Good' : 'N/A',
            'Overall status',
            Colors.green,
            Icons.trending_up,
          ),
          _buildStatCard(
            'Enrolled Classes',
            controller.children.isNotEmpty ? 'Active' : 'N/A',
            'Class status',
            Colors.purple,
            Icons.menu_book,
          ),
          _buildStatCard(
            'Notifications',
            '${controller.children.isNotEmpty ? controller.children.length : 0}',
            'Children linked',
            Colors.orange,
            Icons.notifications,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Icon(icon, size: 16, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
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
              'Announcements',
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
                  final childAnn = controller.announcements[index];
                  final ann = childAnn.announcement;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            childAnn.childName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('From: ${ann.teacherName ?? "Teacher"}'),
                          const SizedBox(height: 4),
                          Text(
                            ann.title,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(ann.content),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateTime(ann.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildChildrenCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Children',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.children.isEmpty)
                return const Text('No children linked');
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.children.length,
                itemBuilder: (context, index) {
                  final child = controller.children[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                child.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Active',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          if (child.enrollmentDate != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Enrolled: ${_formatDate(child.enrollmentDate!)}',
                            ),
                          ],
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              if (child.phoneNumber != null)
                                _buildInfoChip('Phone', child.phoneNumber!),
                              if (child.address != null)
                                _buildInfoChip('Address', child.address!),
                              if (child.parentOccupation != null)
                                _buildInfoChip(
                                  'Parent Occupation',
                                  child.parentOccupation!,
                                ),
                              if (child.dateOfBirth != null)
                                _buildInfoChip(
                                  'Date of Birth',
                                  _formatDate(child.dateOfBirth!),
                                ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildInfoChip(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildImportantInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Important Information',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.children.isEmpty)
                return const Text(
                  'Contact the school administration to link your children to your account.',
                );
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.children.length,
                itemBuilder: (context, index) {
                  final child = controller.children[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            child.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.notifications,
                            Colors.blue,
                            'You are linked as the parent of this student',
                          ),
                          if (child.phoneNumber != null)
                            _buildInfoRow(
                              Icons.phone,
                              Colors.green,
                              'Contact number: ${child.phoneNumber}',
                            ),
                          _buildInfoRow(
                            Icons.book,
                            Colors.purple,
                            'Check their exercises and assignments regularly',
                          ),
                        ],
                      ),
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

  Widget _buildInfoRow(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

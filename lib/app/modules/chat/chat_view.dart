import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chat_controller.dart';

class ChatView extends GetView<ChatController> {
  final VoidCallback? onClose;

  const ChatView({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Contacts sidebar
        SizedBox(
          width: 250,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(right: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Messages',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 20),
                            onPressed: controller.loadContacts,
                          ),
                          if (onClose != null)
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: onClose,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.contacts.isEmpty) {
                      return const Center(child: Text('No contacts available'));
                    }
                    return ListView.builder(
                      itemCount: controller.contacts.length,
                      itemBuilder: (context, index) {
                        final contact = controller.contacts[index];
                        return Obx(
                          () => ListTile(
                            selected:
                                controller.selectedContact.value?.userId ==
                                contact.userId,
                            selectedTileColor: Colors.blue[50],
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                contact.fullName.isNotEmpty
                                    ? contact.fullName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(contact.fullName),
                            subtitle: Text(contact.role),
                            onTap: () => controller.selectContact(contact),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        // Chat area
        Expanded(
          child: Obx(() {
            if (controller.selectedContact.value == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    const Text('Select a contact to start chatting'),
                  ],
                ),
              );
            }
            return Column(
              children: [
                // Chat header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          controller.selectedContact.value!.fullName[0]
                              .toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.selectedContact.value!.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${controller.selectedContact.value!.role}${controller.isWsConnected.value ? ' • Connected' : ' • Connecting...'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Messages
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Obx(
                      () => ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.messages.length,
                        itemBuilder: (context, index) {
                          final msg = controller.messages[index];
                          final isOwn = controller.isOwnMessage(msg);
                          return Align(
                            alignment: isOwn
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.6,
                              ),
                              decoration: BoxDecoration(
                                color: isOwn ? Colors.blue : Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg.content,
                                    style: TextStyle(
                                      color: isOwn
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    controller.formatTime(msg.createdAt),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isOwn
                                          ? Colors.white70
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Input area
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: controller.updateNewMessage,
                          onSubmitted: (_) => controller.sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Obx(
                        () => ElevatedButton(
                          onPressed:
                              controller.isSending.value ||
                                  controller.newMessage.value.isEmpty
                              ? null
                              : controller.sendMessage,
                          child: const Icon(Icons.send),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

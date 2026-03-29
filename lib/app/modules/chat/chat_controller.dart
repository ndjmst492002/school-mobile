import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../data/services/chat_api.dart';
import '../../data/providers/api_provider.dart';
import '../../data/models/chat_models.dart';

class ChatController extends GetxController {
  final ChatApi _chatApi = ChatApi();

  final contacts = <Contact>[].obs;
  final selectedContact = Rxn<Contact>();
  final messages = <ChatMessage>[].obs;
  final newMessage = ''.obs;
  final isLoading = true.obs;
  final isSending = false.obs;
  final isWsConnected = false.obs;

  WebSocketChannel? _wsChannel;
  StreamSubscription? _wsSubscription;
  Timer? _reconnectTimer;

  AuthService get _auth => Get.find<AuthService>();
  int get currentUserId => _auth.userId;

  @override
  void onInit() {
    super.onInit();
    debugPrint('ChatController onInit - role: ${_auth.role}');
    loadContacts();
  }

  @override
  void onClose() {
    disconnectWebSocket();
    super.onClose();
  }

  Future<void> loadContacts() async {
    isLoading.value = true;
    try {
      final auth = Get.find<AuthService>();
      debugPrint('Current user role: ${auth.role}, userId: ${auth.userId}');

      final data = await _chatApi.getContacts();
      debugPrint('Loaded ${data.length} contacts');
      for (var c in data) {
        debugPrint(
          'Contact: id=${c.id}, userId=${c.userId}, name=${c.fullName}, role=${c.role}',
        );
      }
      contacts.value = data;
    } catch (e) {
      debugPrint('Error loading contacts: $e');
      Get.snackbar('Error', 'Failed to load contacts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMessages(int contactId) async {
    try {
      final data = await _chatApi.getMessages(contactId);
      messages.value = data;
    } catch (e) {
      // Handle error
    }
  }

  void selectContact(Contact contact) {
    selectedContact.value = contact;
    loadMessages(contact.userId);
    connectWebSocket();
  }

  Future<void> connectWebSocket() async {
    disconnectWebSocket();
    try {
      final ticket = await _chatApi.getWsTicket();
      _wsChannel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:8000/ws/chat/?ticket=$ticket'),
      );

      _wsSubscription = _wsChannel!.stream.listen(
        (data) {
          _handleWsMessage(data);
        },
        onError: (error) {
          isWsConnected.value = false;
        },
        onDone: () {
          isWsConnected.value = false;
        },
      );
      isWsConnected.value = true;
    } catch (e) {
      isWsConnected.value = false;
    }
  }

  void _handleWsMessage(dynamic data) {
    try {
      final decoded = jsonDecode(data as String);
      final type = decoded['type'];

      if (type == 'message_sent' || type == 'new_message') {
        final msgData = decoded['message'];
        final msg = ChatMessage.fromJson(msgData);

        final contactUserId = selectedContact.value?.userId;
        if (contactUserId == null) return;

        final condition1 =
            msg.sender == currentUserId && msg.receiver == contactUserId;
        final condition2 =
            msg.sender == contactUserId && msg.receiver == currentUserId;

        if (condition1 || condition2) {
          final exists = messages.any((m) => m.id == msg.id);
          if (!exists) {
            messages.add(msg);
          }
        }
      }
    } catch (e) {
      // Handle parse error
    }
  }

  void disconnectWebSocket() {
    _wsSubscription?.cancel();
    _wsChannel?.sink.close();
    _wsChannel = null;
    _wsSubscription = null;
    _reconnectTimer?.cancel();
    isWsConnected.value = false;
  }

  Future<void> sendMessage() async {
    if (newMessage.value.isEmpty || selectedContact.value == null) return;

    isSending.value = true;
    try {
      final contactUserId = selectedContact.value!.userId;
      debugPrint(
        'Sending to userId: $contactUserId, message: ${newMessage.value}',
      );

      final ws = _wsChannel;
      if (ws != null) {
        ws.sink.add(
          '{"type":"chat_message","receiver_id":$contactUserId,"content":"${newMessage.value}"}',
        );
        newMessage.value = '';
      } else {
        await _chatApi.sendMessage(contactUserId, newMessage.value);
        loadMessages(contactUserId);
        newMessage.value = '';
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      Get.snackbar('Error', 'Failed to send message: $e');
    } finally {
      isSending.value = false;
    }
  }

  void updateNewMessage(String value) {
    newMessage.value = value;
  }

  bool isOwnMessage(ChatMessage msg) {
    return msg.sender == currentUserId;
  }

  String formatTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}

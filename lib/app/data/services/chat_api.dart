import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../providers/api_provider.dart';
import '../models/chat_models.dart';

class ChatApi {
  final ApiProvider _api = Get.find<ApiProvider>();

  Future<List<Contact>> getContacts() async {
    final response = await _api.get('/users/chat/contacts/');
    debugPrint('API Response for contacts: ${response.data}');
    final List<dynamic> data = response.data;
    return data.map((json) => Contact.fromJson(json)).toList();
  }

  Future<List<ChatMessage>> getMessages(int contactId) async {
    final response = await _api.get('/users/chat/messages/$contactId/');
    final List<dynamic> data = response.data;
    return data.map((json) => ChatMessage.fromJson(json)).toList();
  }

  Future<ChatMessage> sendMessage(int contactId, String content) async {
    final response = await _api.post(
      '/users/chat/messages/$contactId/',
      data: {'content': content},
    );
    return ChatMessage.fromJson(response.data);
  }

  Future<String> getWsTicket() async {
    final response = await _api.post('/users/ws-ticket/');
    return response.data['ticket'];
  }
}

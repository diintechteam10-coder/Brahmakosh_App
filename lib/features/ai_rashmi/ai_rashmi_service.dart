import 'dart:convert';

import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/common/api_urls.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:http/http.dart' as http;

import 'model/agents_response_model.dart';

class ChatSummary {
  final String chatId;
  final String title;
  final int messageCount;
  final String lastMessage;
  final String createdAt;
  final String updatedAt;

  ChatSummary({
    required this.chatId,
    required this.title,
    required this.messageCount,
    required this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
  });
}

class ChatMessage {
  final String role;
  final String content;

  ChatMessage({required this.role, required this.content});
}

class AiRashmiService {
  /// First API: create chat
  /// POST  { "title": "My First Chat" }
  Future<String> createChat({String title = 'My First Chat'}) async {
    final token = StorageService.getString(AppConstants.keyAuthToken);

    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    String? chatId;
    await callWebApi(
      null,
      '${ApiUrls.apiUrl}/chat',
      {'title': title},
      token: token,
      showLoader: false,
      hideLoader: true,
      onResponse: (http.Response response) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        chatId = data['data']?['chatId']?.toString();
      },
      onError: (e) {
        // handled by caller
      },
    );

    if (chatId == null) {
      throw Exception('Failed to create chat');
    }
    return chatId!;
  }

  /// History API: get all chats for current user
  /// GET {{base_url}}/api/mobile/chat
  Future<List<ChatSummary>> fetchHistory() async {
    final token = StorageService.getString(AppConstants.keyAuthToken);

    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final List<ChatSummary> chats = [];

    await callWebApiGet(
      null,
      '${ApiUrls.apiUrl}/chat',
      token: token,
      showLoader: false,
      hideLoader: true,
      shouldLogoutOn401: false,
      onResponse: (http.Response response) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (data['data']?['chats'] as List?) ?? [];
        for (final item in list) {
          final map = item as Map<String, dynamic>;
          chats.add(
            ChatSummary(
              chatId: map['chatId']?.toString() ?? '',
              title: map['title']?.toString() ?? 'Untitled chat',
              messageCount: map['messageCount'] is int
                  ? map['messageCount'] as int
                  : int.tryParse(map['messageCount']?.toString() ?? '0') ?? 0,
              lastMessage: map['lastMessage']?.toString() ?? '',
              createdAt: map['createdAt']?.toString() ?? '',
              updatedAt: map['updatedAt']?.toString() ?? '',
            ),
          );
        }
      },
      onError: (e) {
        // handled by caller
      },
    );

    return chats;
  }

  /// Get all messages of a specific chat (for history open)
  Future<List<ChatMessage>> fetchMessages(String chatId) async {
    final token = StorageService.getString(AppConstants.keyAuthToken);

    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final List<ChatMessage> messages = [];

    await callWebApiGet(
      null,
      '${ApiUrls.apiUrl}/chat/$chatId',
      token: token,
      showLoader: false,
      hideLoader: true,
      onResponse: (http.Response response) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (data['data']?['messages'] as List?) ?? [];
        for (final item in list) {
          final map = item as Map<String, dynamic>;
          final role = map['role']?.toString() ?? 'assistant';
          final content = map['content']?.toString() ?? '';
          if (content.isEmpty) continue;
          messages.add(ChatMessage(role: role, content: content));
        }
      },
      onError: (e) {
        // handled by caller
      },
    );

    return messages;
  }

  /// Second API: send message in existing chat
  /// POST body: { "message": "hi" }
  Future<String> sendMessage({
    required String chatId,
    required String message,
  }) async {
    final token = StorageService.getString(AppConstants.keyAuthToken);

    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    String? assistantReply;
    await callWebApi(
      null,
      '${ApiUrls.apiUrl}/chat/$chatId/message',
      {'message': message},
      token: token,
      showLoader: false,
      hideLoader: true,
      onResponse: (http.Response response) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        assistantReply = data['data']?['assistantMessage']?['content']
            ?.toString();
      },
      onError: (e) {
        // handled by caller
      },
    );

    if (assistantReply == null) {
      throw Exception('Failed to send message');
    }
    return assistantReply!;
  }
  Future<List<AgentResponseData>> fetchAgents() async {
    final token = StorageService.getString(AppConstants.keyAuthToken);

    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final List<AgentResponseData> agents = [];

    await callWebApiGet(
      null,
      '${ApiUrls.baseUrl}/api/mobile/agents',
      token: token,
      showLoader: false,
      hideLoader: true,
      onResponse: (http.Response response) {
        final resModel = AgentResponseModel.fromJson(jsonDecode(response.body));
        if (resModel.success == true && resModel.data != null) {
          agents.addAll(resModel.data!);
        }
      },
      onError: (e) {
        // handled by caller
      },
    );

    return agents;
  }
}
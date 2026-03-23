import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/itransport.dart';

import '../../core/api_service.dart';
import 'ChatState.dart';

class ChatCubit extends Cubit<ChatState> {
  final ApiService api;
  HubConnection? _connection;
  int? _currentConversationId;

  ChatCubit(this.api) : super(ChatInitial());

  Future<int?> startConversation(
      int userId,
      int jobId,
      int companyId,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (token.isEmpty) {
        emit(ChatFailure("No token found"));
        return null;
      }

      final result = await api.startConversation(token, userId, jobId, companyId);
      return result["conversationId"];
    } catch (e) {
      emit(ChatFailure(e.toString()));
      return null;
    }
  }

  Future<void> loadChatMessages(int conversationId) async {
    emit(ChatLoading());
    try {
      _currentConversationId = conversationId;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final messages = await api.loadChatMessages(token, conversationId);
      emit(ChatMessagesLoaded(messages));

      await _startSignalR(token);
    } catch (e) {
      emit(ChatFailure(e.toString()));
    }
  }

  Future<void> sendMessage(int conversationId, String message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";
      final myId = prefs.getString("appUser") ?? "";

      final currentState = state;
      if (currentState is ChatMessagesLoaded) {
        final tempMsg = {
          "message": message,
          "dateTime": DateTime.now().toIso8601String(),
          "senderId": myId,
          "messageId": 0,
          "isPending": true,
        };
        final updated = List<Map<String, dynamic>>.from(currentState.messages);
        updated.add(tempMsg);
        emit(ChatMessagesLoaded(updated));
      }

      final result = await api.sendMessage(token, conversationId, message);
      final realMessageId = result["messageId"] ?? 0;

      final afterSend = state;
      if (afterSend is ChatMessagesLoaded) {
        final updated = afterSend.messages.map((msg) {
          if (msg["isPending"] == true && msg["messageId"] == 0) {
            return {
              ...Map<String, dynamic>.from(msg),
              "messageId": realMessageId,
              "isPending": false,
            };
          }
          return msg;
        }).toList();
        emit(ChatMessagesLoaded(updated));
      }

    } catch (e) {
      emit(ChatFailure(e.toString()));
    }
  }

  Future<void> _startSignalR(String token) async {
    if (_connection != null &&
        _connection!.state == HubConnectionState.Connected) {
      return;
    }

    _connection = HubConnectionBuilder()
        .withUrl(
      "http://devjob.runasp.net/messageHub",
      options: HttpConnectionOptions(
        accessTokenFactory: () async => token,
        transport: HttpTransportType.WebSockets,
      ),
    )
        .withAutomaticReconnect()
        .build();

    _connection!.on("ReceiveMessage", (arguments) {
      if (arguments == null || arguments.isEmpty) return;

      final data = arguments.first as Map<String, dynamic>;

      final rawConvId = data["ConversationId"] ?? data["conversationId"];
      final incomingConvId = rawConvId is int
          ? rawConvId
          : int.tryParse(rawConvId.toString());

      if (incomingConvId != _currentConversationId) return;

      final currentState = state;
      if (currentState is ChatMessagesLoaded) {

        final incomingId = data["MessageId"] ?? data["messageId"] ?? 0;

        final alreadyExists = currentState.messages.any((msg) {
          final msgId = msg["messageId"];
          return msgId != null && msgId != 0 && msgId == incomingId;
        });

        if (alreadyExists) return;


        final newMessage = {
          "message": data["Message"] ?? "",
          "dateTime": data["SendAt"] ?? "",
          "senderId": data["Sender"] ?? "",
          "messageId": incomingId,
          "isPending": false,
        };

        final updated = List<Map<String, dynamic>>.from(currentState.messages);
        updated.add(newMessage);
        emit(ChatMessagesLoaded(updated));
      }
    });

    _connection!.on("DeleteMessage", (arguments) {
      if (arguments == null || arguments.isEmpty) return;

      final data = arguments.first as Map<String, dynamic>;
      final rawId = data["messageId"] ?? data["MessageId"];
      if (rawId == null) return;

      final messageId = rawId is int ? rawId : int.tryParse(rawId.toString());
      if (messageId == null) return;

      final currentState = state;
      if (currentState is ChatMessagesLoaded) {
        final updated = currentState.messages.where((msg) {
          final msgId = msg["messageId"];
          final normalizedMsgId =
          msgId is int ? msgId : int.tryParse(msgId.toString());
          return normalizedMsgId != messageId;
        }).toList();
        emit(ChatMessagesLoaded(updated));
      }
    });

    _connection!.on("UpdateMessage", (arguments) {
      if (arguments == null || arguments.isEmpty) return;

      final data = arguments.first as Map<String, dynamic>;
      final rawId = data["messageId"] ?? data["MessageId"];
      final newMessage = data["newMessage"] ?? data["NewMessage"] ?? "";

      if (rawId == null) return;
      final messageId = rawId is int ? rawId : int.tryParse(rawId.toString());
      if (messageId == null) return;

      final currentState = state;
      if (currentState is ChatMessagesLoaded) {
        final updated = currentState.messages.map((msg) {
          final rawMsgId = msg["messageId"];
          final normalizedMsgId =
          rawMsgId is int ? rawMsgId : int.tryParse(rawMsgId.toString());
          if (normalizedMsgId == messageId) {
            return {
              ...Map<String, dynamic>.from(msg),
              "message": newMessage,
              "isEdited": true,
            };
          }
          return Map<String, dynamic>.from(msg);
        }).toList();
        emit(ChatMessagesLoaded(updated));
      }
    });

    _connection!.on("updateMessageNumber", (arguments) {
      if (arguments == null || arguments.isEmpty) return;
      final data = arguments.first as Map<String, dynamic>;
      final userId = data["user"];
      final newCount = data["newMessage"];
      if (userId != null && newCount != null) {
        emit(MessageCountUpdated(
          userId: userId is int ? userId : int.tryParse(userId.toString()) ?? 0,
          newCount: newCount is int
              ? newCount
              : int.tryParse(newCount.toString()) ?? 0,
        ));
      }
    });

    await _connection!.start();
  }

  @override
  Future<void> close() async {
    await _connection?.stop();
    return super.close();
  }

  Future<void> loadAllChats() async {
    emit(ChatLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (token.isEmpty) {
        emit(ChatFailure("No token found"));
        return;
      }

      final chats = await api.getAllDeveloperChats(token);
      emit(ChatLoaded(chats));
    } catch (e) {
      emit(ChatFailure(e.toString()));
    }
  }

  Future<void> deleteMessage(int messageId, int conversationId) async {

    if (messageId <= 0) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";
      if (token.isEmpty) {
        emit(ChatFailure("No token found"));
        return;
      }
      await api.deleteMessage(token, messageId, conversationId);

    } catch (e) {
      emit(ChatFailure(e.toString()));
    }
  }

  Future<void> updateMessage(
      int messageId,
      int conversationId,
      String newMessage,
      ) async {

    if (messageId <= 0) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";
      if (token.isEmpty) {
        emit(ChatFailure("No token found"));
        return;
      }
      await api.updateMessage(token, messageId, conversationId, newMessage);

    } catch (e) {
      emit(ChatFailure(e.toString()));
    }
  }
}
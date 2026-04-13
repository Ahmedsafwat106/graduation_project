import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/chat/ChatCubit.dart';
import '../features/chat/ChatState.dart';

class ChatDetailsScreen extends StatefulWidget {
  final int conversationId;

  const ChatDetailsScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  String? myId;
  String? myRole;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMyId();
    context.read<ChatCubit>().loadChatMessages(widget.conversationId);
  }

  Future<void> _loadMyId() async {
    final prefs = await SharedPreferences.getInstance();
    myRole = prefs.getString("role") ?? "developer";

    String? appUser = prefs.getString("appUser");

    if (appUser == null || appUser.isEmpty) {
      final token = prefs.getString("token") ?? "";
      if (token.isNotEmpty) {
        try {
          final parts = token.split(".");
          if (parts.length == 3) {
            String payload = parts[1];

            while (payload.length % 4 != 0) {
              payload += "=";
            }
            final decoded = jsonDecode(
              utf8.decode(base64Url.decode(payload)),
            );

            appUser = decoded[
            "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"
            ];

            if (appUser != null && appUser.isNotEmpty) {
              await prefs.setString("appUser", appUser);
            }
          }
        } catch (e) {
          print("❌ Token decode error: $e");
        }
      }
    }

    setState(() {
      myId = appUser;
    });

    print("✅ myId final => $myId");
  }

  bool _isMyMessage(Map msg) {
    final senderId = msg["senderId"];
    if (senderId == null || myId == null) return false;

    final senderStr = senderId.toString().trim().toLowerCase();
    final myStr = myId!.trim().toLowerCase();

    print("🔍 senderId=$senderStr | myId=$myStr | match=${senderStr == myStr}");

    return senderStr == myStr;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    await context
        .read<ChatCubit>()
        .sendMessage(widget.conversationId, text);

    _scrollToBottom();
  }

  void _showMessageOptions(Map msg) {
    final text = msg["message"] ?? "";
    final messageId = msg["messageId"];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF1FA463),
              ),
              title: const Text("Edit Message"),
              onTap: () {
                Navigator.pop(context);
                final editController =
                TextEditingController(text: text.toString());
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text("Edit Message"),
                    content: TextField(
                      controller: editController,
                      autofocus: true,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF1FA463),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          if (messageId != null &&
                              editController.text.trim().isNotEmpty) {
                            context.read<ChatCubit>().updateMessage(
                              messageId,
                              widget.conversationId,
                              editController.text.trim(),
                            );
                          }
                        },
                        child: const Text(
                          "Save",
                          style: TextStyle(color: Color(0xFF1FA463)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                "Delete Message",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                if (messageId != null && messageId > 0) {
                  context.read<ChatCubit>().deleteMessage(
                    messageId,
                    widget.conversationId,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildMessageItem(Map msg) {
    final text = msg["message"] ?? "";
    final date = msg["dateTime"] ?? "";
    final isMe = _isMyMessage(msg);
    final isEdited = msg["isEdited"] == true;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: isMe ? () => _showMessageOptions(msg) : null,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            gradient: isMe
                ? const LinearGradient(
              colors: [Color(0xFF1FA463), Color(0xFF159957)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: isMe ? null : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: isMe
                  ? const Radius.circular(20)
                  : const Radius.circular(4),
              bottomRight: isMe
                  ? const Radius.circular(4)
                  : const Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                text.toString(),
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: isMe ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isEdited)
                    Text(
                      "edited • ",
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe
                            ? Colors.white.withOpacity(0.7)
                            : Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  Text(
                    date.toString().length >= 16
                        ? date.toString().substring(11, 16)
                        : "",
                    style: TextStyle(
                      fontSize: 11,
                      color: isMe
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.done_all,
                      size: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7F6),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1FA463), Color(0xFF159957)],
              ),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1FA463), Color(0xFF159957)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Chat #${widget.conversationId}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Online",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: BlocConsumer<ChatCubit, ChatState>(
              listener: (context, state) {
                if (state is ChatMessagesLoaded) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child:CircularProgressIndicator(color: Color(0xFF1FA463), strokeWidth: 3));
                }

                if (state is ChatMessagesLoaded) {
                  final messages = state.messages;

                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 60,
                              color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          const Text(
                            "No messages yet",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const Text(
                            "Start the conversation!",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageItem(messages[index]);
                    },
                  );
                }

                if (state is ChatFailure) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),

          _buildInputField(),
        ],
      ),
    );
  }
}
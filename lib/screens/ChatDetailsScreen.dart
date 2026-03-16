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

  final TextEditingController _messageController =
  TextEditingController();
  final ScrollController _scrollController =
  ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMyId();
    context
        .read<ChatCubit>()
        .loadChatMessages(widget.conversationId);
  }



  Future<void> _loadMyId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      myId = prefs.getString("appUser");
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    await context
        .read<ChatCubit>()
        .sendMessage(widget.conversationId, text);

    _messageController.clear();

    await Future.delayed(
        const Duration(milliseconds: 300));

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration:
        const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  Widget _buildMessageItem(Map msg) {
    final text = msg["message"] ?? "";
    final date = msg["dateTime"] ?? "";
    final senderId = msg["senderId"];
    final messageId = msg["messageId"];
    final isMe = senderId != null && senderId.toString() == myId;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(

        onLongPress: isMe
            ? () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            builder: (_) => Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF1FA463),
                    ),
                    title: const Text("Edit Message"),
                    onTap: () {
                      Navigator.pop(context);
                      final editController = TextEditingController(
                        text: text.toString(),
                      );
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Edit Message"),
                          content: TextField(
                            controller: editController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
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
                                style: TextStyle(
                                  color: Color(0xFF1FA463),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // ✅ Delete
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    title: const Text(
                      "Delete Message",
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (messageId != null) {
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
            : null,

        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            gradient: isMe
                ? const LinearGradient(
              colors: [
                Color(0xFF1FA463),
                Color(0xFF159957),
              ],
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
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                text.toString(),
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: isMe ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
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
            color:
            Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7F6),
                borderRadius:
                BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1FA463),
                  Color(0xFF159957),
                ],
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

  Widget _buildBody() {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        // ✅ scroll لأسفل أوتوماتيك لما تيجي رسالة جديدة
        if (state is ChatMessagesLoaded) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      },
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChatMessagesLoaded) {
          final messages = state.messages;

          if (messages.isEmpty) {
            return const Center(
              child: Text(
                "No messages yet",
                style: TextStyle(fontSize: 16, color: Colors.grey),
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
            padding:
            const EdgeInsets.fromLTRB(16, 50, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1FA463),
                  Color(0xFF159957),
                ],
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
                    color:
                    Colors.white.withOpacity(0.2),
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () =>
                        Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Chat #${widget.conversationId}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(child: _buildBody()),

          _buildInputField(),
        ],
      ),
    );
  }
}
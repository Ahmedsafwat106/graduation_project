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
  int? myId;
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
    setState(() {
      myId = prefs.getInt("userId");
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    // إرسال الرسالة للـ API
    await context.read<ChatCubit>().sendMessage(
      widget.conversationId,
      text,
    );

    _messageController.clear();

    // Scroll لآخر رسالة (UX احترافي)
    await Future.delayed(const Duration(milliseconds: 300));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildMessageItem(Map msg) {
    final text = msg["message"] ?? "";
    final date = msg["dateTime"] ?? "";
    final senderId = msg["senderId"];

    final isMe = senderId == myId;

    return Align(
      alignment:
      isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFFDCF8C6) // رسالتي أخضر
              : Colors.white,          // رسالة الطرف التاني أبيض
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
            isMe ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight:
            isMe ? const Radius.circular(0) : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text.toString(),
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date.toString().length >= 16
                  ? date.toString().substring(11, 16)
                  : "",
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: "Type a message",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.green,
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {

        if (state is ChatLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is ChatMessagesLoaded) {
          final messages = state.messages;

          if (messages.isEmpty) {
            return const Center(
              child: Text(
                "No messages yet",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              return _buildMessageItem(msg);
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
      appBar: AppBar(
        title: Text("Chat #${widget.conversationId}"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          _buildInputField(), // 🔥 مرتبط بـ send-message API
        ],
      ),
    );
  }
}
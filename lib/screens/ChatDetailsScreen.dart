import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().loadChatMessages(widget.conversationId);
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
    final senderId = msg["senderId"] ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            date.toString(),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            "Sender: $senderId",
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(
              Icons.send,
              color: Colors.green,
              size: 28,
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
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
      myId = prefs.getInt("userId");
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

  /// ================= MODERN MESSAGE BUBBLE =================
  Widget _buildMessageItem(Map msg) {
    final text = msg["message"] ?? "";
    final date = msg["dateTime"] ?? "";
    final senderId = msg["senderId"];
    final isMe = senderId == myId;

    return Align(
      alignment:
      isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin:
        const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth:
          MediaQuery.of(context).size.width * 0.75,
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
              color:
              Colors.black.withOpacity(0.05),
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
                color:
                isMe ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              date.toString().length >= 16
                  ? date.toString()
                  .substring(11, 16)
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
    );
  }

  /// ================= MODERN INPUT BAR =================
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

  /// ================= CHAT BODY =================
  Widget _buildBody() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {

        if (state is ChatLoading) {
          return const Center(
              child: CircularProgressIndicator());
        }

        if (state is ChatMessagesLoaded) {
          final messages = state.messages;

          if (messages.isEmpty) {
            return const Center(
              child: Text(
                "No messages yet",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(
                16, 12, 16, 10),
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
              style:
              const TextStyle(color: Colors.red),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  /// ================= MAIN BUILD (MODERN HEADER) =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Column(
        children: [

          /// Gradient Chat Header (موحد مع المشروع)
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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/chat/ChatCubit.dart';
import '../features/chat/ChatState.dart';
import 'ChatDetailsScreen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() =>
      _ChatListScreenState();
}

class _ChatListScreenState
    extends State<ChatListScreen> {

  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().loadAllChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: SafeArea(
        child: Column(
          children: [

            /// ================= MODERN GRADIENT HEADER =================
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
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
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// Top Bar
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        "Messages",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Modern Search Bar
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.search,
                            color: Color(0xFF1FA463)),
                        hintText: "Search conversations...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// ================= CHAT LIST =================
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {

                  if (state is ChatLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is ChatLoaded) {
                    final chats = state.chats;

                    if (chats.isEmpty) {
                      return const Center(
                        child: Text(
                          "No chats yet",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          16, 4, 16, 20),
                      itemCount: chats.length,
                      itemBuilder: (context, index) {

                        final chat = chats[index];
                        final conversationId =
                        chat["conversationId"];

                        return InkWell(
                          borderRadius:
                          BorderRadius.circular(22),
                          onTap: () {
                            if (conversationId == null) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatDetailsScreen(
                                  conversationId:
                                  conversationId,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                                bottom: 14),
                            padding:
                            const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.05),
                                  blurRadius: 14,
                                  offset:
                                  const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [

                                /// Modern Avatar
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient:
                                    const LinearGradient(
                                      colors: [
                                        Color(0xFF1FA463),
                                        Color(0xFF159957),
                                      ],
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(
                                        18),
                                  ),
                                  child: const Icon(
                                    Icons.chat_bubble_outline,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),

                                const SizedBox(width: 14),

                                /// Name + Last Message
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [

                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              chat["userName"] ??
                                                  "Unknown",
                                              style:
                                              const TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                FontWeight
                                                    .bold,
                                                color: Color(
                                                    0xFF1E1E1E),
                                              ),
                                              overflow:
                                              TextOverflow
                                                  .ellipsis,
                                            ),
                                          ),
                                          if (chat["dateTime"] !=
                                              null)
                                            Text(
                                              chat["dateTime"]
                                                  .toString()
                                                  .substring(
                                                  0, 10),
                                              style:
                                              const TextStyle(
                                                fontSize: 12,
                                                color:
                                                Colors.grey,
                                              ),
                                            ),
                                        ],
                                      ),

                                      const SizedBox(height: 6),

                                      Text(
                                        chat["lastMessage"] ??
                                            "No messages yet",
                                        maxLines: 2,
                                        overflow:
                                        TextOverflow
                                            .ellipsis,
                                        style:
                                        const TextStyle(
                                          color:
                                          Colors.grey,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  if (state is ChatFailure) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(
                            color: Colors.red),
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
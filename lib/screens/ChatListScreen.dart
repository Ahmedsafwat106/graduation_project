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

            /// ================= HEADER =================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 15),
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

                  /// Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.search),
                        hintText: "Search conversations...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// ================= LIST =================
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
                        child: Text("No chats yet"),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: chats.length,
                      itemBuilder: (context, index) {

                        final chat = chats[index];
                        final conversationId = chat["conversationId"];

                        return InkWell(
                          onTap: () {
                            if (conversationId == null) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatDetailsScreen(
                                  conversationId: conversationId,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin:
                            const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                )
                              ],
                            ),
                            child: Row(
                              children: [

                                /// Avatar
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor:
                                  Colors.green.shade100,
                                  child: const Icon(
                                    Icons.rocket_launch,
                                    color: Colors.green,
                                  ),
                                ),

                                const SizedBox(width: 15),

                                /// Name + Message
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
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
                      child: Text(state.message),
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
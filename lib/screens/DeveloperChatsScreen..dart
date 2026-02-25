import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/chat/ChatCubit.dart';
import '../features/chat/ChatState.dart';
import 'ChatDetailsScreen.dart';

class DeveloperChatsScreen extends StatefulWidget {
  const DeveloperChatsScreen({super.key});

  @override
  State<DeveloperChatsScreen> createState() =>
      _DeveloperChatsScreenState();
}

class _DeveloperChatsScreenState
    extends State<DeveloperChatsScreen> {

  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().loadDeveloperChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: Colors.green,
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
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
              itemCount: chats.length,
              itemBuilder: (context, index) {

                final chat = chats[index];
                final conversationId = chat["conversationId"];

                return ListTile(
                  onTap: () {
                    if (conversationId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Invalid conversation"),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailsScreen(
                          conversationId: conversationId,
                        ),
                      ),
                    );
                  },
                  title: Text(
                    (chat["companyName"] ?? "Unknown Company").toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    (chat["lastMessage"] ?? "No messages yet").toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (chat["dateTime"] != null)
                        Text(
                          chat["dateTime"]
                              .toString()
                              .substring(0, 10),
                          style: const TextStyle(fontSize: 12),
                        ),
                      if ((chat["unReadMessage"] ?? 0) > 0)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            chat["unReadMessage"].toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
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
    );
  }
}
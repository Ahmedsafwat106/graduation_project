import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/chat/ChatCubit.dart';
import '../features/chat/ChatState.dart';


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
    context.read<ChatCubit>().loadAllChats();
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
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChatLoaded) {

            if (state.chats.isEmpty) {
              return const Center(child: Text("No chats yet"));
            }

            return ListView.builder(
              itemCount: state.chats.length,
              itemBuilder: (context, index) {

                final chat = state.chats[index];
                return ListTile(
                  title: Text(chat["companyName"] ?? ""),
                  subtitle: Text(chat["lastMessage"] ?? ""),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Builder(
                        builder: (_) {
                          final dateTime = chat["dateTime"];
                          return Text(
                            dateTime != null && dateTime.toString().length >= 10
                                ? dateTime.toString().substring(0, 10)
                                : "",
                          );
                        },
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
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}
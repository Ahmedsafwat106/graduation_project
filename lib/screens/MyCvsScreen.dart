import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/AuthCubit.dart';
import '../features/auth/AuthState.dart';

class MyCvsScreen extends StatefulWidget {
  const MyCvsScreen({super.key});

  @override
  State<MyCvsScreen> createState() => _MyCvsScreenState();
}

class _MyCvsScreenState extends State<MyCvsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().loadCvs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My CVs"),
        backgroundColor: Colors.green,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess && state.message == "CV_DELETED") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("CV deleted successfully")),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CvsLoaded) {
            if (state.cvs.isEmpty) {
              return const Center(child: Text("No CVs uploaded yet"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.cvs.length,
              itemBuilder: (context, index) {
                final cv = state.cvs[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf,
                          color: Colors.red, size: 30),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          "CV ID: ${cv['id']}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          context
                              .read<AuthCubit>()
                              .deleteCv(cv['id']);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }

          return const Center(child: Text("Failed to load CVs"));
        },
      ),
    );
  }
}

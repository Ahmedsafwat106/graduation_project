import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/AuthCubit.dart';
import '../features/auth/AuthState.dart';

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final title = TextEditingController();
  final description = TextEditingController();
  final location = TextEditingController();
  final salary = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Job"),
        backgroundColor: Colors.green,
      ),

      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess && state.message == "JOB_ADDED") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Job Added Successfully")),
            );
            Navigator.pop(context);
          }
        },

        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _field("Job Title", title),
                _field("Description", description),
                _field("Location", location),
                _field("Salary", salary),

                const SizedBox(height: 25),

                state is AuthLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    if (title.text.isEmpty ||
                        description.text.isEmpty ||
                        location.text.isEmpty ||
                        salary.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Please fill all fields")));
                      return;
                    }

                    context.read<AuthCubit>().addJob(
                      title.text,
                      description.text,
                      location.text,
                      salary.text,
                    );
                  },
                  child: const Text("Add Job"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _field(String hint, TextEditingController c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: hint,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

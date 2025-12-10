import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/AuthCubit.dart';
import '../features/auth/AuthState.dart';

class EditCompanyScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const EditCompanyScreen({required this.data, super.key});

  @override
  State<EditCompanyScreen> createState() => _EditCompanyScreenState();
}

class _EditCompanyScreenState extends State<EditCompanyScreen> {
  late TextEditingController company;
  late TextEditingController phone;
  late TextEditingController city;
  late TextEditingController field;

  @override
  void initState() {
    company = TextEditingController(text: widget.data["companyName"]);
    phone = TextEditingController(text: widget.data["phone"] ?? "");
    city = TextEditingController(text: widget.data["city"] ?? "");
    field = TextEditingController(text: widget.data["field"] ?? "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FFFA),
      appBar: AppBar(
        title: const Text("Edit Company"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Company Updated ✓")));
            Navigator.pop(context);
          }
        },

        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _field("Company Name", company),
                _field("Phone", phone),
                _field("City", city),
                _field("Field", field),

                const SizedBox(height: 25),

                state is AuthLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  onPressed: () {
                    context.read<AuthCubit>().updateCompany(
                      company.text,
                      phone.text,
                      city.text,
                      field.text,
                    );
                  },
                  child: const Text("Save Changes"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

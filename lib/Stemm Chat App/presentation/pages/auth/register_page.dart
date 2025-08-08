// presentation/screens/register_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../manager/auth_controller.dart';
import '../../widget/custom_Toast.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AuthController>(context);
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Create an Account",
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.05),

                TextFormField(
                  controller: controller.registerFullName,
                  decoration: _buildInputDecoration(
                    hintText: 'Full Name',
                    icon: Icons.person_outline,
                  ),
                ),
                const SizedBox(height: 16.0),

                TextFormField(
                  controller: controller.registerEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration(
                    hintText: 'Email Address',
                    icon: Icons.email_outlined,
                  ),
                ),
                const SizedBox(height: 16.0),

                TextFormField(
                  controller: controller.registerPhone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: _buildInputDecoration(
                    hintText: 'Phone Number',
                    icon: Icons.phone_outlined,
                  ),
                ),
                const SizedBox(height: 16.0),

                TextFormField(
                  controller: controller.registerPassword,
                  obscureText: true,
                  decoration: _buildInputDecoration(
                    hintText: 'Password',
                    icon: Icons.lock_outline,
                  ),
                ),

                SizedBox(height: size.height * 0.03),

                ElevatedButton(
                  onPressed: controller.isLoading
                      ? null
                      : () async {
                          if (controller.registerFullName.text.isEmpty ||
                              controller.registerEmail.text.isEmpty ||
                              controller.registerPhone.text.isEmpty ||
                              controller.registerPassword.text.isEmpty) {
                            customToastMsg("All fields are required");
                          } else if (controller.registerPassword.text.length <
                              6) {
                            customToastMsg(
                              "Password must be at least 6 characters",
                            );
                          } else {
                            await controller.register(
                              context,
                              controller.registerEmail.text,
                              controller.registerPassword.text,
                              controller.registerFullName.text,
                              controller.registerPhone.text,
                            );
                          }
                        },

                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF00BF6D),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: const StadiumBorder(),
                  ),
                  child: controller.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Register", style: TextStyle(fontSize: 16)),
                ),
                SizedBox(height: size.height * 0.02),

                TextButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(color: Color(0xFF00BF6D)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF5FCF9),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0 * 1.5,
        vertical: 16.0,
      ),
      border: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
    );
  }
}

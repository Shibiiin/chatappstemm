import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../manager/auth_controller.dart';
import '../../routes/appRoutes.dart';
import '../../widget/custom_Toast.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AuthController>(context);
    final size = MediaQuery.sizeOf(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Login Here!",
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.05),
              Column(
                children: [
                  TextFormField(
                    controller: controller.loginEmail,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Email';
                      }
                      return null;
                    },
                    inputFormatters: [LengthLimitingTextInputFormatter(25)],
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: Color(0xFFF5FCF9),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0 * 1.5,
                        vertical: 16.0,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                    ),
                    onSaved: (name) {
                      // Save it
                    },
                  ),
                  const SizedBox(height: 10.0),

                  ///Phone number textfield
                  TextFormField(
                    controller: controller.loginPassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
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
                    ),
                  ),

                  SizedBox(height: size.height * 0.02),

                  Consumer<AuthController>(
                    builder: (context, value, child) {
                      return ElevatedButton(
                        onPressed: controller.isLoading
                            ? null // Disable button while loading
                            : () async {
                                if (controller.loginEmail.text.isEmpty) {
                                  customToastMsg("Email should be entered");
                                } else if (controller
                                    .loginPassword
                                    .text
                                    .isEmpty) {
                                  customToastMsg("Password should be entered");
                                } else {
                                  final user = await controller.loginUser();
                                  if (user != null && context.mounted) {
                                    customToastMsg("Login Successful!");
                                    context.go(AppRoutes.dashboard);
                                  } else {
                                    customToastMsg(
                                      "Login Failed. Check credentials.",
                                    );
                                  }
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
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Login",
                                style: TextStyle(fontSize: 16),
                              ),
                      );
                    },
                  ),
                  SizedBox(height: size.height * 0.02),

                  TextButton(
                    onPressed: () {
                      context.go(AppRoutes.register);
                    },
                    child: const Text(
                      "Don't have an account? Register Now",
                      style: TextStyle(color: Color(0xFF00BF6D)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

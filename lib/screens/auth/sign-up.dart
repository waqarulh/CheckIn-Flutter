import 'package:checkin/services/bloc/auth-bloc/auth_bloc.dart';
import 'package:checkin/services/bloc/auth-bloc/auth_event.dart';
import 'package:checkin/services/bloc/auth-bloc/auth_state.dart';
import 'package:checkin/widgets/custom-button.dart';
import 'package:checkin/widgets/custom-feild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            String errorMessage = state.message;
            if (errorMessage.contains(']')) {
              errorMessage = errorMessage.split(']')[1].trim();
            }
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(errorMessage)));
          }
          if (state is Authenticated) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.deepPurple,
                      child: FittedBox(
                        fit: BoxFit
                            .contain, // Ensures the icon scales to fit within the circle
                        child: Icon(
                          Icons.person_4,
                          color: Colors.white,
                          size: 150,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'REGISTER!',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    const Text('Get started by creating your account'),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomTextField(
                      hintText: 'Enter your email',
                      controller: emailController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      hintText: 'Enter your password',
                      controller: passwordController,
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      hintText: 'Enter your confirm password',
                      controller: confirmPasswordController,
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your confirm your password';
                        }
                        if (value != passwordController.text) {
                          return 'Please confirm your password';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
                      if (state is AuthLoading) {
                        return CircularProgressIndicator(); // Show loader
                      }
                      return CustomButton(
                          label: 'Sign Up',
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              BlocProvider.of<AuthBloc>(context).add(
                                SignUpEvent(
                                  emailController.text,
                                  passwordController.text,
                                ),
                              );
                            }
                          });
                    }),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        child: RichText(
                          text: const TextSpan(
                            text:
                                "Already have an account? ", // Default text style
                            style: TextStyle(
                              color: Colors
                                  .black, // Color for "Don't have an account?"
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text:
                                    'Login', // Different part with different style
                                style: TextStyle(
                                  color:
                                      Colors.deepPurple, // Color for "Sign Up"
                                  fontWeight:
                                      FontWeight.bold, // Optional styling
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

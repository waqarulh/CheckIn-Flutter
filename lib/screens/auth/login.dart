import 'package:checkin/services/bloc/auth-bloc/auth_bloc.dart';
import 'package:checkin/services/bloc/auth-bloc/auth_event.dart';
import 'package:checkin/services/bloc/auth-bloc/auth_state.dart';
import 'package:checkin/widgets/custom-button.dart';
import 'package:checkin/widgets/custom-feild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  LoginScreen({super.key});

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
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(errorMessage),
              duration: Duration(milliseconds: 500),
            ));
          }
          if (state is Authenticated) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.deepPurple,
                      child: FittedBox(
                        fit: BoxFit
                            .contain,
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
                      'LOGIN!',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                        'Enter your credentials to access your account.'),
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/signup');
                        },
                        child: RichText(
                          text: const TextSpan(
                            text:
                                "Don't have an account? ", // Default text style
                            style: TextStyle(
                              color: Colors
                                  .black,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text:
                                    'Sign Up',
                                style: TextStyle(
                                  color:
                                      Colors.deepPurple,
                                  fontWeight:
                                      FontWeight.bold,
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
                    BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
                      if (state is AuthLoading) {
                        return CircularProgressIndicator();
                      }
                      return CustomButton(
                          label: 'Login',
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              BlocProvider.of<AuthBloc>(context).add(
                                LoginEvent(
                                  emailController.text,
                                  passwordController.text,
                                ),
                              );
                            }
                          });
                    })
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // This import doesn't need changing as it's from a third-party package
import 'login_bloc.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login or Sign Up'),
      ),
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            Navigator.of(context).pushReplacementNamed('/menu');
          } else if (state is LoginError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.error}')),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                if (state is LoginLoading)
                  CircularProgressIndicator()
                else
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          BlocProvider.of<LoginBloc>(context).add(
                            LoginWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text,
                            ),
                          );
                        },
                        child: Text('Sign In'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          BlocProvider.of<LoginBloc>(context).add(
                            SignUpWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text,
                            ),
                          );
                        },
                        child: Text('Sign Up'),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

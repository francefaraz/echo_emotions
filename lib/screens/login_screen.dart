import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:echo_emotions/models/user.dart';
import 'package:echo_emotions/providers/user_provider.dart';
import 'package:echo_emotions/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSigningIn = false;

  Future<void> _signInWithEmailAndPassword() async {
    setState(() {
      _isSigningIn = true;
    });

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await _handleUser(userCredential.user);
    } on FirebaseAuthException catch (e) {
      // Handle sign-in errors
      print(e);
      // Show error message to user
    } finally {
      setState(() {
        _isSigningIn = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isSigningIn = true;
    });

    try {
      final googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      await _handleUser(userCredential.user);
    } on FirebaseAuthException catch (e) {
      // Handle sign-in errors
      print(e);
      // Show error message to user
    } finally {
      setState(() {
        _isSigningIn = false;
      });
    }
  }

  Future<void> _handleUser(User? user) async {
    if (user != null) {
      final String? username = user.displayName ?? user.email?.split('@')[0];
      final _user = MyUser(uid: user.uid, email: user.email.toString(), username: username);

      try {
        Provider.of<UserProvider>(context, listen: false).setUser(_user);
        await Navigator.pushReplacementNamed(context, '/');

        // await Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const HomeScreen()),
        // );
      } catch (e) {
        print("Error navigating to HomeScreen: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Login',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isSigningIn
                              ? null
                              : () => _signInWithEmailAndPassword(),
                          child: const Text('Sign In'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isSigningIn ? null : _signInWithGoogle,
                          child: const Text('Sign In with Google'),
                        ),
                        if (_isSigningIn) const CircularProgressIndicator(),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/register');
                          },
                          child: const Text('Don\'t have an account? Sign up'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:echo_emotions/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:echo_emotions/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:echo_emotions/models/user.dart';

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSigningIn = false;

  Future<void> _signInWithEmailAndPassword() async {
    print("HELLO IM HERE");
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
      print("ERROR");
      print(e);
      // Show error message to user
    } finally {
      setState(() {
        _isSigningIn = false;
      });
    }
  }

  Future<void> _signUpWithEmailAndPassword() async {
    setState(() {
      _isSigningIn = true;
    });

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await _handleUser(userCredential.user);
    } on FirebaseAuthException catch (e) {
      // Handle sign-up errors
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

  // Future<void> _handleUser(User? user) async{
  //   // Handle user data and navigation to home screen
  //   print("USER IS: ${user}");
  //   if (user != null) {
  //     print("in here");
  //     // Assuming you have a way to fetch user's name from Firebase or other sources
  //     final String? username = user?.displayName ??
  //         '${user?.email?.split(' @')[0]}'; // Default to email without domain if no username provided
  //     print("USER NAME IS ${username}");
  //     final _user = MyUser(
  //         uid: user.uid, email: user.email.toString(), username: username);
  //     Provider.of<UserProvider>(context, listen: true).setUser(_user);
  //     print("CAME HERE");
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => const HomeScreen()),
  //     );
  //   }
  // }

  Future<void> _handleUser(User? user) async {
    // Handle user data and navigation to home screen
    print("USER IS: ${user}");
    if (user != null) {
      print("in here");
      // Assuming you have a way to fetch user's name from Firebase or other sources
      final String? username = user?.displayName ??
          '${user?.email?.split('@')[0]}'; // Default to email without domain if no username provided
      print("USER NAME IS ${username}");
      final _user = MyUser(
          uid: user.uid, email: user.email.toString(), username: username);

      try {
        Provider.of<UserProvider>(context, listen: false).setUser(_user);
        print("CAME HERE");
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } catch (e) {
        print("Error navigating to HomeScreen: $e");
        // Handle the error, e.g., show an error message to the user
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
                  // App logo or title
                  // Image.asset('assets/your_logo.png'), // Replace with your logo
                  const SizedBox(height: 20),
                  Text(
                    'Welcome!',
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
                          onPressed: _isSigningIn
                              ? null
                              : () => _signUpWithEmailAndPassword(),
                          child: const Text('Sign Up'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isSigningIn ? null : _signInWithGoogle,
                          child: const Text('Sign In with Google'),
                        ),
                        if (_isSigningIn) const CircularProgressIndicator(),
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

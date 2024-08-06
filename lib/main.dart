import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_emotions/screens/authentication.dart';
import 'package:echo_emotions/screens/login_screen.dart';
import 'package:echo_emotions/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:echo_emotions/screens/home_screen.dart';
import 'package:echo_emotions/providers/user_provider.dart';

final jsonString = """[]
""";

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child:const MyApp(),
    ),
  );
// runApp(const MyApp());
}
// await importQuotes();
Future<void> importQuotes() async {
  final firestore = FirebaseFirestore.instance;
  final quotesCollection = firestore.collection('posts');

  try {
    // Assuming jsonString is your JSON data as a string
    final jsonData = jsonDecode(jsonString) as List<dynamic>;

    for (final quoteData in jsonData) {
      final updatedQuoteData = {
        'text': quoteData['quote'],
        'author': quoteData['quoteAuthor'],
        'likes': 0,
        'dislikes': 0,
        'userId': "iwK9aQymjwSCNFw7V929B5Ui3CE2",
        'category': 'inspirational',
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Add the document and capture the reference
      final docRef = await quotesCollection.add(updatedQuoteData);

      // Get the document ID
        final docId = docRef.id;

      // Update the document with the ID
      await docRef.update({'id': docId});

      print('Document added with ID: $docId');
    }

    // This will print after the loop is done
    print("done with for loop");

  } catch (e) {
    print('Error importing quotes: $e');
  }
}
/*Future<void> importQuotes() async {
  final firestore = FirebaseFirestore.instance;
  final quotesCollection = firestore.collection('posts');

  try {
    final jsonData = jsonDecode(jsonString) as List<dynamic>;


    for (final quoteData in jsonData) {
      final updatedQuoteData = {
        'text': quoteData['quote'],
        'author': quoteData['quoteAuthor'],
        'likes':0,
        'dislikes':0,
        'userId':"iwK9aQymjwSCNFw7V929B5Ui3CE2",
        'category': 'inspirational',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await quotesCollection.add(updatedQuoteData);
    }
    print("done with for loop ");

  } catch (e) {
    print('Error importing quotes: $e');
  }
}
*/
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return
//     ChangeNotifierProvider(
//       create: (context) => UserProvider(),
//       child: MaterialApp(
//         title:
//         'Post Sharing App',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//         ),
//         home: const HomeScreen(), // Initially show HomeScreen
//         routes: {
//           '/authentication': (context) => const Authentication(),
//           '/login': (context) => const LoginScreen(),
//           '/register': (context) => const RegisterScreen(),
//         },
//       ),
//     );
//   }
// }
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Post Sharing App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
          '/':(context) => const HomeScreen(),
          '/authentication': (context) => const Authentication(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
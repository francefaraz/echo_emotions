import 'package:flutter/material.dart';

class InspireScreen extends StatelessWidget {
  const InspireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspire'),
      ),
      body: const Center(
        child: Text('Inspire Screen'),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class DeactivateAppScreen extends StatelessWidget {
  const DeactivateAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '',
      initialRoute: '/',
      routes: {
        '/': (context) => Scaffold(
          body: const Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 100),
              Text('Sorry this app no longer available'),
            ],
          )),
        ),
      },
    );
  }
}

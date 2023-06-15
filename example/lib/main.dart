import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_windows/firebase_windows.dart';

import 'debug_widget.dart';
import 'firebase_options.dart';
import 'view/auth_page.dart';

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _debugTextEditingController =
      TextEditingController();

  bool get isInitialized => Firebase.apps.isNotEmpty;

  String? get appName => isInitialized ? Firebase.apps.first.name : null;

  Future<void> initializeDefault() async {
    FirebaseApp app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    setState(() {});
    log('Initialized default app $app');
  }

  void apps() {
    final List<FirebaseApp> apps = Firebase.apps;
    log('Currently initialized apps: $apps');
  }

  void options() {
    final FirebaseApp app = Firebase.app();
    final options = app.options;
    log('Current options for app ${app.name}: $options');
  }

  Future<void> openAuthPage() async {
    await Navigator.push<AuthPage>(
      context,
      MaterialPageRoute(builder: (context) => AuthPage(app: Firebase.app())),
    );
  }

  void log(String msg) {
    if (kDebugMode) print(msg);
    _debugTextEditingController.text += '$msg\n';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            Text('Initialized app name: $appName\n'),
            SizedBox(
              width: 800,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: initializeDefault,
                    child: const Text('Initialize default app'),
                  ),
                  ElevatedButton(
                    onPressed: apps,
                    child: const Text('List apps'),
                  ),
                  ElevatedButton(
                    onPressed: isInitialized ? options : null,
                    child: const Text('List default options'),
                  ),
                  ElevatedButton(
                    onPressed: isInitialized ? openAuthPage : null,
                    child: const Text('Open Auth page'),
                  ),
                ],
              ),
            ),
            DebugWidget(controller: _debugTextEditingController),
          ],
        ),
      ),
    );
  }
}

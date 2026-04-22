import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:payflow/payflow_app.dart';
import 'package:payflow/shared/widgets/error_boundary/error_boundary.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  late final Future<FirebaseApp> firebaseInitialize;

  @override
  void initState() {
    super.initState();
    firebaseInitialize = Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebaseInitialize,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          log('Error when initializing Firebase: ${snapshot.error}');
          return const Material(
            child: Center(
              child: Text(
                'Oops, Unexpected error! :/',
                textDirection: TextDirection.ltr,
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return const ErrorBoundary(
            child: PayFlowApp(),
          );
        }
        return const Material(
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

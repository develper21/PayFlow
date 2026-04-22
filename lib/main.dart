import 'package:flutter/material.dart';

import 'package:payflow/app_widget.dart';
import 'package:payflow/shared/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService().init();

  runApp(const AppWidget());
}

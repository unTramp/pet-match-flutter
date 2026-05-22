import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'presentation/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const PetMatchApp());
}

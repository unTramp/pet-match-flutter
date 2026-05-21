import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'presentation/app.dart';
import 'presentation/details/cubit/breed_detail_cubit.dart';
import 'presentation/questionnaire/cubit/questionnaire_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  // Cubit-фабрики регистрируются здесь, чтобы не образовывать цикл импортов
  // между core/di и presentation.
  sl.registerFactory(() => QuestionnaireCubit(sl(), sl(), sl(), sl()));
  sl.registerFactory(() => BreedDetailCubit(sl()));

  runApp(const PetMatchApp());
}

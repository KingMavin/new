import 'package:flutter/material.dart';

import 'package:immortal_path/game/persistence/shared_prefs_save_repository.dart';
import 'package:immortal_path/state/game_controller.dart';
import 'package:immortal_path/ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = GameController(repository: SharedPrefsSaveRepository());
  await controller.initialize();
  runApp(ImmortalPathApp(controller: controller));
}

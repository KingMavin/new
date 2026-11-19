import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:immortal_path/audio/audio_players_gateway.dart';
import 'package:immortal_path/game/persistence/shared_prefs_save_repository.dart';
import 'package:immortal_path/state/game_controller.dart';
import 'package:immortal_path/ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final controller = GameController(
    repository: SharedPrefsSaveRepository(),
    audio: AudioPlayersGateway(),
  );
  await controller.initialize();
  runApp(ImmortalPathApp(controller: controller));
}

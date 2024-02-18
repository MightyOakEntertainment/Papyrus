import 'settings_manager.dart';
import 'package:get_it/get_it.dart';

final serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register services
  final settingsManagerService = await SettingsManager.getInstance();
  serviceLocator.registerSingleton(settingsManagerService);
}
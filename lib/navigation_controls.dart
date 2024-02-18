import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'settings_manager.dart';

class NavigationControls extends StatelessWidget {
   NavigationControls({super.key, required this.manager, required this.controller});

  final SettingsManager manager;
  final WebViewController controller;

  String  _codexURL     = "http://192.168.0.0:9810/f/0/1";

  Future<void> _loadSettings() async {
      _codexURL = manager.codexURL ?? "http://192.168.0.0:9810/f/0/1";
  }

  @override
  Widget build(BuildContext context) {
    _loadSettings();
    return Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            controller.reload();
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            if (await controller.canGoBack()) {
              await controller.goBack();
            } else {
              messenger.showSnackBar(
                const SnackBar(content: Text('No back history item')),
              );
              return;
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            if (await controller.canGoForward()) {
              await controller.goForward();
            } else {
              messenger.showSnackBar(
                const SnackBar(content: Text('No forward history item')),
              );
              return;
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            controller.loadRequest(Uri.parse(_codexURL));
          },
        ),
      ],
    );
  }
}

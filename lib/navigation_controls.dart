import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'settings_manager.dart';

class NavigationControls extends StatelessWidget {
   const NavigationControls({super.key, required this.manager, required this.controller, required this.codexURL});

  final SettingsManager manager;
  final InAppWebViewController controller;
  final String codexURL;

  @override
  Widget build(BuildContext context) {
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
            controller.loadUrl(urlRequest: URLRequest(url: WebUri(codexURL)));
          },
        ),
      ],
    );
  }
}

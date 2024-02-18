import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'about.dart';
import 'settings.dart';
import 'navigation_controls.dart';
import 'settings_manager.dart';
import 'service_locator.dart';

import 'globals.dart' as globals;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupServiceLocator();

  runApp(const Papyrus());
}

class Papyrus extends StatelessWidget {
  const Papyrus({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Papyrus',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(),
        useMaterial3: true,
      ),
      home: const PanelWidget(),
    );
  }
}

class AppPanel {
  const AppPanel(this.title, this.icon, this.selectedIcon, this.panel);

  final String title;
  final Widget icon;
  final Widget selectedIcon;
  final Widget panel;
}

class PanelWidget extends StatefulWidget {
  const PanelWidget({super.key});

  @override
  State<PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget> {
  int _panelIndex = 0;
  int loadingPercentage = 0;
  bool fullscreenMode = false;
  bool shadowColor = false;
  bool showWebControls = true;
  double? scrolledUnderElevation;
  String _codexURL = 'http://0.0.0.0:9810/f/0/1';
  List<MenuItemButton> webViewMenu = List<MenuItemButton>.empty(growable: true);

  final settingsManager = serviceLocator<SettingsManager>();

  late final WebViewController controller;

  final cookieManager = WebViewCookieManager();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /*Future<void> _onListCookies(WebViewController controller) async {
    final String cookies = await controller
        .runJavaScriptReturningResult('document.cookie') as String;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(cookies.isNotEmpty ? cookies : 'There are no cookies.'),
      ),
    );
  }*/

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _codexURL = prefs.getString('codexURL') ?? globals.codexPath;
      controller.loadRequest(Uri.parse(_codexURL),);
    });
  }

  Future<void> _onClearCookies() async {
    final hadCookies = await cookieManager.clearCookies();
    String message = 'There were cookies. Now, they are gone!';
    if (!hadCookies) {
      message = 'There were no cookies to clear.';
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  _onSelectItem(int index) {
    setState(() => _panelIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }

  List<AppPanel> panels = List<AppPanel>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    _loadSettings();
    controller = WebViewController()
      ..loadRequest(
        Uri.parse(globals.codexPath),
      );
    controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onProgress: (progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageFinished: (url) {
            if (url.contains('/c/')) {
              setState(() {
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
                fullscreenMode = true;
              });
            }else{
              setState(() {
                SystemChrome.setEnabledSystemUIMode( SystemUiMode.manual, overlays: [ SystemUiOverlay.top, SystemUiOverlay.bottom, ], );
                fullscreenMode = false;
              });
            }
            setState(() {
              loadingPercentage = 100;
            });
          },
        ),
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    panels.add(AppPanel('Codex', Icon(Icons.visibility_outlined), Icon(Icons.visibility), WebViewWidget(controller: controller)));
    panels.add(AppPanel('Settings', Icon(Icons.settings_outlined), Icon(Icons.settings), SettingsPanel(manager: settingsManager)));
    panels.add(AppPanel('About', Icon(Icons.info_outlined), Icon(Icons.info), AboutPanel()));
  }


  @override
  Widget build(BuildContext context) {
    webViewMenu.clear();
    webViewMenu.add(MenuItemButton(
      onPressed: () =>
          setState(() => showWebControls = !showWebControls),
      child: showWebControls ? const Text('Hide Web Controls') : const Text('Show Web Controls'),
    ),);
    /*webViewMenu.add(MenuItemButton(
      onPressed: () =>
          setState(() => _onListCookies(controller)),
      child: const Text('List cookies'),
    ),);*/
    webViewMenu.add(MenuItemButton(
      onPressed: () =>
          setState(() => _onClearCookies()),
      child: const Text('Clear cookies'),
    ),);

    return Scaffold(
      key: _scaffoldKey,
      appBar: !fullscreenMode ? AppBar(
        // Can be a straight color using Colors.amber for example
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(panels[_panelIndex].title),
        scrolledUnderElevation: scrolledUnderElevation,
        shadowColor: shadowColor ? Theme.of(context).colorScheme.shadow : null,
        actions: <Widget>[
          if(_panelIndex == 0) ...[
            if(showWebControls) ...[
              NavigationControls(controller: controller),
            ],
            MenuAnchor(
            builder: (BuildContext context, MenuController controller, Widget? child) {
              return IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }},
                icon: const Icon(Icons.more_vert),
                tooltip: 'Show menu',
              );},
            menuChildren: webViewMenu,
          ),
          ],
        ],
      ) : null,
      body: Stack(
        children: [
          panels[_panelIndex].panel,
          if (loadingPercentage < 100)
            LinearProgressIndicator(
              value: loadingPercentage / 100.0,
            ),
        ],
      ),
      drawer: NavigationDrawer(
        onDestinationSelected: _onSelectItem,
        selectedIndex: _panelIndex,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text(
              'Papyrus',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ...panels.map(
                (AppPanel panel) {
              return NavigationDrawerDestination(
                label: Text(panel.title),
                icon: panel.icon,
                selectedIcon: panel.selectedIcon,
              );
            },
          ),
        ],
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';

import 'about.dart';
import 'settings.dart';
import 'navigation_controls.dart';
import 'settings_manager.dart';
import 'service_locator.dart';


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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        ),
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
  double? scrolledUnderElevation;
  List<MenuItemButton> webViewMenu = List<MenuItemButton>.empty(growable: true);

  final settingsManager = serviceLocator<SettingsManager>();

  String  _codexURL     = "http://192.168.0.0:9810/f/0/1";
  bool    _webControls  = false;
  //Not Needed Until OPDS Implementation
  /*bool    _opdsV2       = false;
  String  _opdsURL      = "http://192.168.0.0:9810/opds/v1.2/r/0/1";
  String  _opdsUsername = "";
  String  _opdsPassword = "";*/

  Future<void> _loadSettings() async {
    //Not Needed Until OPDS Implementation
    /*final username = await settingsManager.getUsername();
    final password = await settingsManager.getPassword();*/
    setState(() {
      _codexURL     = settingsManager.codexURL;
      _webControls  = settingsManager.showWebControls;
      //Not Needed Until OPDS Implementation
      /*_opdsV2       = settingsManager.opdsV2;
      _opdsURL      = settingsManager.opdsURL;
      _opdsUsername = username;
      _opdsPassword = password;*/
      controller.loadRequest(Uri.parse(_codexURL),);
    });
  }

  late final WebViewController controller;

  final cookieManager = WebViewCookieManager();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //Lists -- for Codex so kind of useless but kept for future reference
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
    controller = WebViewController();
    _loadSettings();
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

    panels.add(AppPanel('Codex', const Icon(Icons.visibility_outlined), const Icon(Icons.visibility), WebViewWidget(controller: controller)));
    panels.add(AppPanel('Settings', const Icon(Icons.settings_outlined), const Icon(Icons.settings), SettingsPanel(manager: settingsManager)));
    panels.add(const AppPanel('About', Icon(Icons.info_outlined), Icon(Icons.info), AboutPanel()));
  }


  @override
  Widget build(BuildContext context) {
    webViewMenu.clear();
    webViewMenu.add(MenuItemButton(
      onPressed: () =>
          setState(() {
            _webControls = !_webControls;
            settingsManager.showWebControls = _webControls;
          }),
      child: _webControls ? const Text('Hide Web Controls') : const Text('Show Web Controls'),
    ),);

    //Kept encase I want to re-enable the 'List Cookies' Option
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
        backgroundColor: Colors.black,//Theme.of(context).colorScheme.inversePrimary,
        title: Text(panels[_panelIndex].title),
        scrolledUnderElevation: scrolledUnderElevation,
        shadowColor: shadowColor ? Theme.of(context).colorScheme.shadow : null,
        actions: <Widget>[
          if(_panelIndex == 0) ...[
            if(_webControls) ...[
              NavigationControls(manager: settingsManager, controller: controller, codexURL: _codexURL),
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
      drawer: Drawer(
        child: Column(
            children: <Widget>[
              Expanded(
                  child: ListView(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 16, 10),
                        child: Text(
                          'Papyrus',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        title: Text(panels[0].title),
                        leading: _panelIndex == 0 ? panels[0].selectedIcon : panels[0].icon,
                        //selected: _panelIndex == 0,
                        onTap: () => _onSelectItem(0),
                        tileColor: _panelIndex == 0 ? Theme.of(context).colorScheme.inversePrimary : Colors.transparent,
                      ),
                      ListTile(
                        title: Text(panels[1].title),
                        leading: _panelIndex == 1 ? panels[1].selectedIcon : panels[1].icon,
                        //selected: _panelIndex == 1,
                        onTap: () => _onSelectItem(1),
                        tileColor: _panelIndex == 1 ? Theme.of(context).colorScheme.inversePrimary : Colors.transparent,
                      ),
                    ],
                  )
              ),
              const Divider(),
              Align(
                alignment: FractionalOffset.bottomCenter,
                child:ListTile(
                  title: Text(panels[2].title),
                  leading: _panelIndex == 2 ? panels[2].selectedIcon : panels[2].icon,
                  //selected: _panelIndex == 2,
                  onTap: () => _onSelectItem(2),
                  tileColor: _panelIndex == 2 ? Theme.of(context).colorScheme.inversePrimary : Colors.transparent,
                ),
              )
            ]
        ),
      ),
    );
  }
}



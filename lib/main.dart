import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/services.dart';

import 'about.dart';
import 'downloads.dart';
import 'opds.dart';
import 'settings.dart';
import 'sliding_appbar.dart';
import 'navigation_controls.dart';
import 'settings_manager.dart';
import 'service_locator.dart';

//Main Starts Here!
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupServiceLocator();

  runApp(Papyrus());
}

// ┌─────────────────────────────────────────────────────────────────────┐
// | Theme Settings / Root Widget                                        |
// └─────────────────────────────────────────────────────────────────────┘

//Method for getting the current Accent Color based on it's index
Color getAccentColor(int index) {
  switch (index) {
    case 0:
      return Colors.blue;
    case 1:
      return Colors.deepPurple;
    case 2:
      return const Color.fromARGB(255, 255, 156, 0);
    case 3:
      return Colors.red;
  }
  return Colors.blue;
}

//The Root Widget / Theme Settings
class Papyrus extends StatelessWidget {
  Papyrus({super.key});

  final settingsManager = serviceLocator<SettingsManager>();

  // This is where we set all Theme Settings when possible
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Papyrus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: getAccentColor(settingsManager.accentColor),
          brightness: Brightness.dark,
          background: const Color.fromARGB(255, 18, 18, 18),
        ),
        useMaterial3: true,
        drawerTheme: const DrawerThemeData(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Color.fromARGB(255, 33, 33, 33),
        ),
        dividerTheme: const DividerThemeData(
          color: Color.fromARGB(255, 42, 42, 42),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 33, 33, 33), //Theme.of(context).colorScheme.inversePrimary,
          shadowColor: Theme.of(context).colorScheme.shadow,
        ),
        menuTheme: MenuThemeData(
          style: MenuStyle(
            surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return getAccentColor(settingsManager.accentColor);
              }
              return const Color.fromARGB(255, 42, 42, 42);
            }),
          )
        ),
        menuButtonTheme: MenuButtonThemeData(
            style: ButtonStyle(
              surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.pressed)) {
                  return getAccentColor(settingsManager.accentColor);
                }
                return const Color.fromARGB(255, 42, 42, 42);
              }),
            ),
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          surfaceTintColor: Colors.transparent,
          color: const Color.fromARGB(255, 42, 42, 42),
        ),
        inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
      ),
      //builder: (context, child) => SafeArea(child: child!), //Safeguard against Camera Notches
      home: const PanelWidget(),
    );
  }
}

// ┌─────────────────────────────────────────────────────────────────────┐
// | Main Widget / Master Panel                                          |
// └─────────────────────────────────────────────────────────────────────┘

//Struct of an AppPanel
class AppPanel {
  const AppPanel(this.title, this.icon, this.selectedIcon, this.panel);

  final String title;
  final Widget icon;
  final Widget selectedIcon;
  final Widget panel;
}

//Our Main Widget that contains the AppBar, Navigation Drawer, all Panels & any Controllers
class PanelWidget extends StatefulWidget {
  const PanelWidget({super.key});

  @override
  State<PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget> with SingleTickerProviderStateMixin {
  int _panelIndex = 2;
  int loadingPercentage = 0;
  bool fullscreenMode = false;
  static double defaultBarHeight = 56; //default is 56 but 80 was required before SafeArea keeping for customization
  double barHeight = defaultBarHeight; //Is resized during build to compensate for Camera Notches
  double? scrolledUnderElevation;

  List<AppPanel> panels = List<AppPanel>.empty(growable: true);
  List<MenuItemButton> webViewMenu = List<MenuItemButton>.empty(growable: true);

  final settingsManager = serviceLocator<SettingsManager>();

  String  _codexURL     = "http://192.168.0.0:9810/f/0/1";
  bool    _webControls  = false;
  //Not Needed Until OPDS Implementation
  /*bool    _opdsV2       = false;
  String  _opdsURL      = "http://192.168.0.0:9810/opds/v1.2/r/0/1";
  String  _opdsUsername = "";
  String  _opdsPassword = "";*/

  //Allows for Asynchronous Loading of Settings
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
    });
  }

  late final InAppWebViewController webViewController;

  final cookieManager = CookieManager();
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
    final hadCookies = await cookieManager.deleteAllCookies();
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

  //Method used to wrap any Drawer Button with a Card that only shows when selected
  //This is done to give a Navigation Drawer like effect but with more customization
  Card panelButton(int index){
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60.0)),
      surfaceTintColor: Colors.transparent,
      color: _panelIndex == index ? Theme.of(context).colorScheme.inversePrimary : Colors.transparent,
      shadowColor: _panelIndex == index ? Theme.of(context).colorScheme.shadow : Colors.transparent,
      child: ListTile(
        title: Text(panels[index].title),
        leading: _panelIndex == index ? panels[index].selectedIcon : panels[index].icon,
        selected: _panelIndex == index,
        onTap: () => _onSelectItem(index),
      ),
    );
  }

  //Ran at build to compensate for Camera Notches while maintaining status bar theming
  void handleCameraNotch(){
    double notchSize = MediaQuery.of(context).viewPadding.top;

    if(notchSize > 0){
      barHeight = defaultBarHeight + notchSize;
    }
  }

  //Method used to return a setup InAppWebView
  InAppWebView webView(){
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(_codexURL)),
      initialSettings: InAppWebViewSettings(
          useOnDownloadStart: true
      ),
      onWebViewCreated: (controller) {
        webViewController = controller;
      },
        onLoadStart: (controller, url) {
        setState(() {
          loadingPercentage = 0;
        });
        },
        onProgressChanged: (controller, progress) {
        setState(() {
          loadingPercentage = progress;
        });
        },
        onLoadStop: (controller, url) async {
        setState(() {
          loadingPercentage = 100;
        });
        },
        onUpdateVisitedHistory: (controller, url, androidIsReload) {
          setState(() {
            String newUrl = url.toString();
            if (newUrl.contains('/c/')) {
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
          });
        },
    );
  }

  @override
  void initState() {
    super.initState();

    _loadSettings();

    //Populate the Panels list during Init as atm it does not need to be reloaded on each State Change
    //This may change if a dynamic number of OPDS Libraries are eventually allowed
    //Note: The list starts with About as 0 will always be used for the last panel in the drawer!
    panels.add(const AppPanel('About', Icon(Icons.info_outlined), Icon(Icons.info), AboutPanel()));
    panels.add(AppPanel('Settings', const Icon(Icons.settings_outlined), const Icon(Icons.settings), SettingsPanel(manager: settingsManager)));
    panels.add(AppPanel('Codex', const Icon(Icons.visibility_outlined), const Icon(Icons.visibility), webView()));
    panels.add(const AppPanel('OPDS', Icon(Icons.rss_feed_outlined), Icon(Icons.rss_feed), OpdsPanel()));
    panels.add(const AppPanel('Downloads', Icon(Icons.download_outlined), Icon(Icons.download), DownloadsPanel()));
  }

  @override
  Widget build(BuildContext context) {
    handleCameraNotch();

    //We Populate the Web View Menu during build to accommodate changing the label on the Web Controls option
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

    //This is our root Scaffold which contains the master AppBar & Drawer
    //The Body contains a universal loading bar and an AppPanel based on the current index
    return Scaffold(
      key: _scaffoldKey,
      appBar: SlidingAppBar(
          visible: !fullscreenMode,
          appBar: AppBar(
            title: Text(panels[_panelIndex].title),
            toolbarHeight: barHeight,
            scrolledUnderElevation: scrolledUnderElevation,
            actions: <Widget>[
              if(_panelIndex == 2) ...[
                if(_webControls) ...[
                  NavigationControls(manager: settingsManager, controller: webViewController, codexURL: _codexURL),
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
          )),
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
                      paddedTitle(const Text('Network Libraries')),
                      panelButton(2),
                      panelButton(3),
                      const Divider(),
                      paddedTitle(const Text('Local Library')),
                      panelButton(4),
                      const Divider(),
                      panelButton(1),
                    ],
                  )
              ),
              const Divider(),
              Align(
                alignment: FractionalOffset.bottomCenter,
                child:panelButton(0),
              )
            ]
        ),
      ),
    );
  }
}



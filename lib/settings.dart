import 'package:flutter/material.dart';

import 'main.dart';
import 'settings_manager.dart';

Padding paddedList(ListView list){
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
    child:list,
  );
}

Padding paddedTitle(Text text){
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 6, 0, 6),
    child:text,
  );
}

Padding paddedTopBottom(ListTile tile){
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
    child:tile,
  );
}

Padding paddedTop(ListTile tile){
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
    child:tile,
  );
}

String getAccentName(int index) {
  switch (index) {
    case 0:
      return 'Blue';
    case 1:
      return 'Purple';
    case 2:
      return 'Orange';
    case 3:
      return 'Red';
  }
  return 'Blue';
}

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({super.key, required this.manager});

  final SettingsManager manager;

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {

  List<MenuItemButton> accentsMenu = List<MenuItemButton>.empty(growable: true);

  String  _codexURL      = "http://192.168.0.0:9810/f/0/1";
  bool    _opdsV2        = false;
  String  _opdsURL       = "http://192.168.0.0:9810/opds/v1.2/r/0/1";
  String  _opdsUsername  = "";
  String  _opdsPassword  = "";

  Future<void> _loadSettings() async {
    final username = await widget.manager.getUsername();
    final password = await widget.manager.getPassword();
    setState(() {
      _codexURL     = widget.manager.codexURL;
      _opdsV2       = widget.manager.opdsV2;
      _opdsURL      = widget.manager.opdsURL;
      _opdsUsername = username;
      _opdsPassword = password;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();

    accentsMenu.clear();
    accentsMenu.add(MenuItemButton(
      leadingIcon: const Icon(Icons.circle, color: Colors.blue),
      onPressed: () =>
          setState(() {
            widget.manager.accentColor = 0;
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Papyrus()), (route) => false);
          }),
      child: const Text('Blue'),
    ),);
    accentsMenu.add(MenuItemButton(
      leadingIcon: const Icon(Icons.circle, color: Colors.deepPurple),
      onPressed: () =>
          setState(() {
            widget.manager.accentColor = 1;
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Papyrus()), (route) => false);
          }),
      child: const Text('Purple'),
    ),);
    accentsMenu.add(MenuItemButton(
      leadingIcon: const Icon(Icons.circle, color: Color.fromARGB(255, 204, 123, 25)),
      onPressed: () =>
          setState(() {
            widget.manager.accentColor = 2;
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Papyrus()), (route) => false);
          }),
      child: const Text('Orange'),
    ),);
    accentsMenu.add(MenuItemButton(
      leadingIcon: const Icon(Icons.circle, color: Colors.red),
      onPressed: () =>
          setState(() {
            widget.manager.accentColor = 3;
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Papyrus()), (route) => false);
          }),
      child: const Text('Red'),
    ),);
  }

  @override
  Widget build(BuildContext context) {
    return paddedList(ListView(
        children: <Widget>[
          paddedTitle(const Text('Codex')),
          Card(
            child: paddedTopBottom(ListTile(
              leading: const Icon(Icons.visibility),
              title: TextField(
                controller: TextEditingController()..text = _codexURL,
                keyboardType: TextInputType.url,
                onSubmitted: (String? value) {
                  setState(() {
                    _codexURL = value!;
                    widget.manager.codexURL = _codexURL;
                  });
                  },
                decoration: const InputDecoration(
                  hintText: 'This is for your Codex Homepage.',
                  labelText: 'Codex URL',
                ),
              ),
            )),
          ),
          paddedTitle(const Text('OPDS')),
          Card(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                paddedTop(ListTile(
                  leading: const Icon(Icons.warning),
                  title: const Text('Use OPDS v2.0'),
                  subtitle: const Text('OPDS v2 is experimental and not widely or well supported!'),
                  trailing: Switch(
                    onChanged: (bool? value) {
                      setState(() {
                        _opdsV2 = value!;
                        widget.manager.opdsV2 = _opdsV2;
                      });
                      },
                    value: _opdsV2,
                  ),
                )),
                paddedTopBottom(ListTile(
                  leading: const Icon(Icons.rss_feed),
                  title: TextField(
                    controller: TextEditingController()..text = _opdsURL,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      hintText: 'This is for your OPDS Feeds URL.',
                      labelText: 'OPDS URL',
                    ),
                    onSubmitted: (String? value) {
                      setState(() {
                        _opdsURL = value!;
                        widget.manager.opdsURL = _opdsURL;
                      });
                      },
                  ),
                )),
              ],
            ),
          ),
          paddedTitle(const Text('Optional')),
          Card(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                paddedTop(ListTile(
                  leading: const Icon(Icons.person),
                  title: TextField(
                    controller: TextEditingController()..text = _opdsUsername,
                    decoration: const InputDecoration(
                      hintText: 'Optionally you may add your OPDS Username.',
                      labelText: 'OPDS Username',
                    ),
                    onSubmitted: (String? value) {
                      setState(() {
                        _opdsUsername = value!;
                        widget.manager.setUsername(_opdsUsername);
                      });
                    },
                  ),
                )),
                paddedTopBottom(ListTile(
                  leading: const Icon(Icons.password),
                  title: TextField(
                    obscureText: true,
                    controller: TextEditingController()..text = _opdsPassword,
                    decoration: const InputDecoration(
                      hintText: 'Optionally you may add your OPDS Password.',
                      labelText: 'OPDS Password',
                    ),
                    onSubmitted: (String? value) {
                      setState(() {
                        _opdsPassword = value!;
                        widget.manager.setPassword(_opdsPassword);
                      });
                    },
                  ),
                )),
              ],
            ),
          ),
          paddedTitle(const Text('Papyrus')),
          Card(
            child: paddedTopBottom(ListTile(
              leading: const Icon(Icons.palette),
              title: Text('Accent Color'),
              subtitle: Text(getAccentName(widget.manager.accentColor)),
                trailing: MenuAnchor(
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
                  menuChildren: accentsMenu,
                ),
            )),
          ),
        ],
      ));
  }
}
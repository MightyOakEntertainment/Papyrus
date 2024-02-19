import 'package:flutter/material.dart';

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

Padding paddedTile(ListTile tile){
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
    child:tile,
  );
}

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({super.key, required this.manager});

  final SettingsManager manager;

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {

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
  }

  @override
  Widget build(BuildContext context) {
    return paddedList(ListView(
        children: <Widget>[
          paddedTitle(const Text('Codex')),
          Card(
            child: paddedTile(ListTile(
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
                paddedTile(ListTile(
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
                paddedTile(ListTile(
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
                paddedTile(ListTile(
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
                paddedTile(ListTile(
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
        ],
      ));
  }
}
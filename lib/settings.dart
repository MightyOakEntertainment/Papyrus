import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({super.key});

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  final storage = const FlutterSecureStorage();

  String _codexURL = 'http://0.0.0.0:9810/f/0/1';
  bool _opdsV2 = false;
  String _opdsURL = 'http://0.0.0.0:9810/opds/v1.2/r/0/1';
  String _opdsUsername = '';
  String _opdsPassword = '';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _codexURL = prefs.getString('codexURL') ?? 'http://0.0.0.0:9810/f/0/1';
      _opdsV2 = prefs.getBool('opdsV2') ?? false;
      _opdsURL = prefs.getString('opdsURL') ?? 'http://0.0.0.0:9810/opds/v1.2/r/0/1';
    });

    final username = await storage.read(key: 'username') ?? '';
    final password = await storage.read(key: 'password') ?? '';
  }

  Future<void> _saveCodexURL() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('codexURL', _codexURL);
    });
  }

  Future<void> _saveOpdsV2() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool('opdsV2', _opdsV2);
    });
  }

  Future<void> _saveOpdsURL() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('opdsURL', _opdsURL);
    });
  }

  Future<void> _saveOpdsUsername() async {
    setState(() async {
      await storage.write(key: 'username', value: _opdsUsername!);
    });
  }

  Future<void> _saveOpdsPassword() async {
    setState(() async {
      await storage.write(key: 'password', value: _opdsPassword!);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    _loadSettings();
    return ListView(
      children: <Widget>[
        Text('Codex'),
        Card(
          child: ListTile(
            leading: Icon(Icons.visibility),
            title: Text('Codex URL'),
            subtitle: TextFormField(
              initialValue: _codexURL!,
              decoration: const InputDecoration(
                hintText: 'This is for your Codex Homepage.',
                labelText: 'URL',
              ),
              onSaved: (String? value) {
                setState(() {
                  _codexURL = value!;
                  _saveCodexURL();
                });
              },
            ),
          ),
        ),
        Text('OPDS'),
        Card(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.warning),
                title: Text('Use OPDS v2.0'),
                subtitle: Text('OPDS v2 is experimental and not widely or well supported!'),
                trailing: Switch(
                  onChanged: (bool? value) {
                    setState(() {
                      _opdsV2 = value!;
                      _saveOpdsV2();
                    });
                    },
                  value: _opdsV2,
                ),
              ),
              ListTile(
                leading: Icon(Icons.rss_feed),
                title: Text('OPDS URL'),
                subtitle: TextFormField(
                  initialValue: _opdsURL!,
                  decoration: const InputDecoration(
                    hintText: 'This is for your OPDS Feeds URL.',
                    labelText: 'URL',
                  ),
                  onSaved: (String? value) {
                    setState(() {
                      _opdsURL = value!;
                      _saveOpdsURL();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Text('Optional'),
        Card(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.person),
                title: Text('OPDS Username'),
                subtitle: TextFormField(
                  initialValue: _opdsUsername!,
                  decoration: const InputDecoration(
                    hintText: 'Optionally you may add your OPDS Username.',
                    labelText: 'Username',
                  ),
                  onSaved: (String? value) {
                    setState(() {
                      _opdsUsername = value!;
                      _saveOpdsUsername();
                    });
                  },
                ),
              ),
              ListTile(
                leading: Icon(Icons.password),
                title: Text('OPDS Password'),
                subtitle: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Optionally you may add your OPDS Password.',
                    labelText: 'Password',
                  ),
                  onSaved: (String? value) {
                    setState(() {
                      _opdsPassword = value!;
                      _saveOpdsPassword();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
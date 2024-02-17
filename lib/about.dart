import 'package:flutter/material.dart';

class AboutPanel extends StatefulWidget {
  const AboutPanel({super.key});

  @override
  State<AboutPanel> createState() => _AboutPanelState();
}

class _AboutPanelState extends State<AboutPanel> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: const Text('From Mighty Oak Entertainment\nThank You!'),
    );
  }
}
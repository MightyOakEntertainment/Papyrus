import 'package:flutter/material.dart';

class OpdsPanel extends StatefulWidget {
  const OpdsPanel({super.key});

  @override
  State<OpdsPanel> createState() => _OpdsPanelState();
}

class _OpdsPanelState extends State<OpdsPanel> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.rss_feed),
    );
  }
}
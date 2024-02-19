import 'package:flutter/material.dart';

class DownloadsPanel extends StatefulWidget {
  const DownloadsPanel({super.key});

  @override
  State<DownloadsPanel> createState() => _DownloadsPanelState();
}

class _DownloadsPanelState extends State<DownloadsPanel> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.download),
    );
  }
}
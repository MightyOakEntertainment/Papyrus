import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _launchUrl(Uri url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}

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
      child: GestureDetector(
        onTap: () {
          _launchUrl(Uri.parse('https://github.com/MightyOakEntertainment/Papyrus'));
          },
        child: SvgPicture.asset('assets/svg/Mighty-Oak-Entertainment-Logo.svg', colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),),
      ),
    );
  }
}
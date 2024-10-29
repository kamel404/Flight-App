import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  final bool autoRefresh;
  final VoidCallback toggleAutoRefresh;
  final Uri flutterUrl = Uri.parse('https://flutter.dev');
  final Uri githubUrl = Uri.parse('https://github.com/kamel404');

  SettingsPage({
    super.key,
    required this.autoRefresh,
    required this.toggleAutoRefresh,
  });

  Future<void> _launchFlutterWebsite() async {
    if (await canLaunchUrl(flutterUrl)) {
      await launchUrl(flutterUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $flutterUrl';
    }
  }

  Future<void> _launchMyGithub() async {
    if (await canLaunchUrl(githubUrl)) {
      await launchUrl(githubUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $githubUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('Auto Refresh'),
            value: autoRefresh,
            onChanged: (value) {
              toggleAutoRefresh();
            },
          ),
          ListTile(
            title: const Text('Visit Flutter Official Website'),
            trailing: const Icon(Icons.open_in_new),
            onTap: _launchFlutterWebsite,
          ),
          ListTile(
            title: const Text('Visit My Github'),
            trailing: const Icon(Icons.open_in_new),
            onTap: _launchMyGithub,
          ),
        ],
      ),
    );
  }
}

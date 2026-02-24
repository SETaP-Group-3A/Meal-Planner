import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Account'),
            onTap: () => Navigator.pushNamed(context, '/settings/account'),
          ),
          ListTile(
            title: Text('Accessibility'),
            onTap: () => Navigator.pushNamed(context, '/settings/accessibility'),
          )
        ],
      ),
    );
  }
}

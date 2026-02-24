import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account Settings')),
      body: Center(child: Text('Account settings go here')),
    );
  }
}

class AccessibilitySettingsScreen extends StatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  State<AccessibilitySettingsScreen> createState() => _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState extends State<AccessibilitySettingsScreen> {

  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> saveSettings(bool isDarkMode) async {
    setState(() {
      _isDarkMode = isDarkMode;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Accessibility Settings')),
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SwitchListTile(
            title: Text('Dark Mode'),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              saveSettings(value);
            },
          )
        ],
      )),
    );
  }
}
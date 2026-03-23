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
            onTap: () =>
                Navigator.pushNamed(context, '/settings/accessibility'),
          ),
        ],
      ),
    );
  }
}

class AccountSettingsScreen extends StatefulWidget {
  AccountSettingsScreen({super.key});

  final List<String> testGoals = ["Save Money", "Eat Healthier", "Travel Less"];

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  final _formKey = GlobalKey<FormState>();

  static const _kPrefUsername = 'user.username';
  static const _kPrefEmail = 'user.email';
  static const _kPrefAddress = 'user.address';
  static const _kPrefAddressOptOut = 'user.addressOptOut';

  bool _addressOptOut = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _addressOptOut = prefs.getBool(_kPrefAddressOptOut) ?? false;

      _usernameController.text = prefs.getString(_kPrefUsername) ?? 'JohnDoe';
      _emailController.text = prefs.getString(_kPrefEmail) ?? '';
      _addressController.text = _addressOptOut
          ? ''
          : (prefs.getString(_kPrefAddress) ?? '');
    });
  }

  Future<void> _setAddressOptOut(bool value) async {
    setState(() {
      _addressOptOut = value;
      if (_addressOptOut) {
        _addressController.clear();
      }
      _formKey.currentState?.validate();
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrefAddressOptOut, value);

    if (value) {
      await prefs.remove(_kPrefAddress);
    }
  }

  Future<void> _saveUserDetails() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefUsername, _usernameController.text.trim());
    await prefs.setString(_kPrefEmail, _emailController.text.trim());

    await prefs.setBool(_kPrefAddressOptOut, _addressOptOut);
    if (_addressOptOut) {
      await prefs.remove(_kPrefAddress);
    } else {
      await prefs.setString(_kPrefAddress, _addressController.text.trim());
    }

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('User details updated')));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account Settings')),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(
                  'Your details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Update the information used for your account and distance calculation to shops. '
                  'These details are stored locally on this device.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    helperText: 'This is how your name will appear in the app.',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return 'Username is required';
                    if (s.length < 3)
                      return 'Username must be at least 3 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    helperText:
                        'We’ll use this for account-related communication.',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return 'Email is required';
                    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(s);
                    if (!ok) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Address (optional)',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Tooltip(
                      message:
                          'If you opt out, features that rely on your location/address '
                          '(like distance calculations) may not be functinal or accurate.',
                      child: const Icon(Icons.info_outline, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('I prefer not to provide an address'),
                  value: _addressOptOut,
                  onChanged: _setAddressOptOut,
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _addressController,
                  enabled: !_addressOptOut,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    helperText: _addressOptOut
                        ? 'Address is disabled because you opted out.'
                        : 'Used for shopping lists and distance calculation.',
                    border: const OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  minLines: 2,
                  maxLines: 3,
                  validator: (v) {
                    if (_addressOptOut) return null;
                    final s = (v ?? '').trim();
                    if (s.isEmpty)
                      return 'Address is required (or opt out above)';
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveUserDetails,
                    child: const Text('Save'),
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                Text('Goals', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  'Choose what you want to focus on so we can tailor recepies and items to help you best.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),

                Text("I want to..."),
                DropdownButton(
                  hint: Text(widget.testGoals[0]),
                  items: widget.testGoals.map((goal) {
                    return DropdownMenuItem(value: goal, child: Text(goal));
                  }).toList(),
                  onChanged: (value) {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AccessibilitySettingsScreen extends StatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  State<AccessibilitySettingsScreen> createState() =>
      _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState
    extends State<AccessibilitySettingsScreen> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode =
          prefs.getBool('isDarkMode') ??
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark;
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
      body: Center(
        child: Column(
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
            ),
          ],
        ),
      ),
    );
  }
}

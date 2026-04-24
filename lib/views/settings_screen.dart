import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_service.dart';
// temp controller
class ThemeController {
  static const _kPrefThemeMode = 'theme.mode'; // 'system' | 'light' | 'dark'
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(
    ThemeMode.system,
  );

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPrefThemeMode) ?? 'system';
    themeMode.value = switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    await prefs.setString(_kPrefThemeMode, isDark ? 'dark' : 'light');
  }
}

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

  bool _addressOptOut = false;
  bool _isSaving = false;
  bool? _geocodeSuccess;

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
      _addressOptOut = prefs.getBool(kPrefAddressOptOut) ?? false;

      _usernameController.text = prefs.getString(_kPrefUsername) ?? 'JohnDoe';
      _emailController.text = prefs.getString(_kPrefEmail) ?? '';
      _addressController.text = _addressOptOut
          ? ''
          : (prefs.getString(kPrefAddress) ?? '');
    });
  }

  Future<void> _setAddressOptOut(bool value) async {
    setState(() {
      _addressOptOut = value;
      _geocodeSuccess = null; // clear any previous feedback
      if (_addressOptOut) {
        _addressController.clear();
      }
      _formKey.currentState?.validate();
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kPrefAddressOptOut, value);

    if (value) {
      // upon opting out remove address and cached coordinates
      await prefs.remove(kPrefAddress);
      await prefs.remove(kPrefLat);
      await prefs.remove(kPrefLon);
    }
  }

  Future<void> _saveUserDetails() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isSaving = true;
      _geocodeSuccess = null;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefUsername, _usernameController.text.trim());
    await prefs.setString(_kPrefEmail, _emailController.text.trim());

    await prefs.setBool(kPrefAddressOptOut, _addressOptOut);
    if (_addressOptOut) {
      // remove address and cached coordinates upon opting out
      await prefs.remove(kPrefAddress);
      await prefs.remove(kPrefLat);
      await prefs.remove(kPrefLon);
    } else {
      final address = _addressController.text.trim();
      await prefs.setString(kPrefAddress, address);
      // geocoding if a valid address is provided
      if (address.isNotEmpty) {
        final coords = await resolveAndCacheUserCoordinates();
 
        if (mounted) {
          setState(() => _geocodeSuccess = coords != null);
        }
      }
    }

    if (!mounted) return;

    setState(() => _isSaving = false);
 
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User details updated')),
    );
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
                        'We\'ll use this for account-related communication.',
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
                  onChanged: _addressOptOut == false && _isSaving
                      ? null
                      : _setAddressOptOut,
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _addressController,
                  enabled: !_addressOptOut && !_isSaving,
                  decoration: InputDecoration(
                    labelText: 'Postcode',
                    helperText: _addressOptOut
                        ? 'Postcode is disabled because you opted out.'
                        : 'Used for shopping lists and distance calculations.',
                    border: const OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  minLines: 1,
                  maxLines: 2,
                  validator: (v) {
                    if (_addressOptOut) return null;
                    final s = (v ?? '').trim();
                    if (s.isEmpty)
                      return 'Postcode is required (or opt out above)';
                    return null;
                  },
                ),

                // geocode result after a save attempt
                if (_geocodeSuccess != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _geocodeSuccess!
                            ? Icons.check_circle_outline
                            : Icons.warning_amber_rounded,
                        size: 16,
                        color: _geocodeSuccess!
                            ? Colors.green
                            : Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _geocodeSuccess!
                              ? 'Location resolved — store distances will be calculated from your postcode.'
                              : 'Could not resolve this postcode. Distance sorting will use stored values until a valid postcode is saved.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _geocodeSuccess!
                                    ? Colors.green
                                    : Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveUserDetails,
                    child: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Accessibility Settings')),
      body: Center(
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeController.themeMode,
          builder: (context, mode, _) {
            final isDark = mode == ThemeMode.dark;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SwitchListTile(
                  title: Text('Dark Mode'),
                  value: isDark,
                  onChanged: (value) {
                    // This will update app-wide once MaterialApp listens to ThemeController.themeMode.
                    ThemeController.setDarkMode(value);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_planner/models/weekly_goals.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import 'store_locator_screen.dart';

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
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Account'),
            onTap: () => Navigator.pushNamed(context, '/settings/account'),
          ),
          ListTile(
            title: const Text('Accessibility'),
            onTap: () =>
                Navigator.pushNamed(context, '/settings/accessibility'),
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Store Locator'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StoreLocatorScreen()),
            ),
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
  static const _kPrefGoalType = 'goal';

  bool _addressOptOut = false;
  bool _isSaving = false;
  bool? _geocodeSuccess;

  GoalType _selectedGoalType = GoalType.money;

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

      _usernameController.text = prefs.getString(_kPrefUsername) ?? '';
      _emailController.text = prefs.getString(_kPrefEmail) ?? '';
      _addressController.text = _addressOptOut
          ? ''
          : (prefs.getString(kPrefAddress) ?? '');

      final rawGoal = prefs.getString(_kPrefGoalType) ?? 'money';
      _selectedGoalType = GoalTypes.fromDbString(rawGoal);
    });
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

    await prefs.setString(_kPrefGoalType, _selectedGoalType.toString());

    await prefs.setBool(kPrefAddressOptOut, _addressOptOut);

    if (_addressOptOut) {
      await prefs.remove(kPrefAddress);
      await prefs.remove(kPrefLat);
      await prefs.remove(kPrefLon);
    } else {
      final address = _addressController.text.trim();
      await prefs.setString(kPrefAddress, address);

      if (address.isNotEmpty) {
        final coords = await resolveAndCacheUserCoordinates();
        if (mounted) {
          setState(() => _geocodeSuccess = coords != null);
        }
      }
    }

    if (!mounted) return;

    // Ensure the WeeklyGoals provider is updated when the user changes goal type.
    try {
      final accountEmailPref = prefs.getString('accountEmail');
      if (mounted) {
        final weekly = Provider.of<WeeklyGoals>(context, listen: false);
        await weekly.updateGoalType(newType: _selectedGoalType, accountEmail: accountEmailPref);
      }
    } catch (_) {
      // Best-effort: if provider isn't available or update fails, continue silently.
    }

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('User details updated')));
  }

  // UI helper only
  String _goalLabel(GoalType type) {
    switch (type) {
      case GoalType.money:
        return "Save Money";
      case GoalType.calories:
        return "Eat Healthier";
      case GoalType.distance:
        return "Travel Less";
    }
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
      appBar: AppBar(title: const Text('Account Settings')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(
                  'Your details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                SwitchListTile(
                  title: const Text('Opt out of address'),
                  value: _addressOptOut,
                  onChanged: (v) => setState(() => _addressOptOut = v),
                ),

                TextFormField(
                  controller: _addressController,
                  enabled: !_addressOptOut,
                  decoration: const InputDecoration(
                    labelText: 'Postcode',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ FIXED DROPDOWN
                Text("Goal Type"),

                DropdownButton<GoalType>(
                  value: _selectedGoalType,
                  items: GoalType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_goalLabel(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedGoalType = value);
                  },
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _isSaving ? null : _saveUserDetails,
                  child: _isSaving
                      ? const CircularProgressIndicator()
                      : const Text('Save'),
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
      appBar: AppBar(title: const Text('Accessibility Settings')),
      body: Center(
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeController.themeMode,
          builder: (context, mode, _) {
            final isDark = mode == ThemeMode.dark;
            return SwitchListTile(
              title: const Text('Dark Mode'),
              value: isDark,
              onChanged: (value) {
                ThemeController.setDarkMode(value);
              },
            );
          },
        ),
      ),
    );
  }
}

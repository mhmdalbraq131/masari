import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/app_settings_service.dart';
import '../services/security_service.dart';
import '../widgets/branded_app_bar.dart';
import '../widgets/responsive_container.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _savePin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_pinController.text.trim() != _confirmController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pinMismatch)),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await context.read<SecurityService>().setPin(_pinController.text.trim());
      if (!mounted) return;
      _pinController.clear();
      _confirmController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pinSaved)),
      );
    } on FormatException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pinInvalid)),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _toggleBiometrics(bool enabled) async {
    final security = context.read<SecurityService>();
    if (enabled) {
      final canUse = await security.canUseBiometrics();
      if (!canUse) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).deviceNoBiometrics),
          ),
        );
        await security.setBiometricsEnabled(false);
        return;
      }
    }
    await security.setBiometricsEnabled(enabled);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final hasPin = context.watch<SecurityService>().hasPin;
    final biometricsEnabled = context
        .watch<SecurityService>()
        .biometricsEnabled;
    final settings = context.watch<AppSettingsService>();

    return Scaffold(
      appBar: BrandedAppBar(title: t.settingsTitle),
      body: SafeArea(
        child: ResponsiveContainer(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                t.securityTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(t.biometricsLabel),
                          subtitle: Text(t.biometricsSubtitle),
                          value: biometricsEnabled,
                          onChanged: _toggleBiometrics,
                        ),
                        const Divider(height: 24),
                        Text(
                          hasPin ? t.pinStatusSet : t.pinStatusNotSet,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _pinController,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          maxLength: 4,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            labelText: t.pinNew,
                            hintText: '••••',
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.length != 4) return t.pinInvalid;
                            if (int.tryParse(v) == null) return t.pinInvalid;
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmController,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          maxLength: 4,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            labelText: t.pinConfirm,
                            hintText: '••••',
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.length != 4) return t.pinInvalid;
                            if (int.tryParse(v) == null) return t.pinInvalid;
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _saving ? null : _savePin,
                          child: Text(_saving ? t.pinSaving : t.pinSave),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                t.preferencesTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(t.languageLabel),
                        trailing: DropdownButton<Locale>(
                          value: settings.locale,
                          onChanged: (value) {
                            if (value == null) return;
                            context.read<AppSettingsService>().setLocale(value);
                          },
                          items: const [
                            DropdownMenuItem(
                              value: Locale('ar'),
                              child: Text('العربية'),
                            ),
                            DropdownMenuItem(
                              value: Locale('en'),
                              child: Text('English'),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 0),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(t.themeLabel),
                        trailing: DropdownButton<ThemeMode>(
                          value: settings.themeMode,
                          onChanged: (value) {
                            if (value == null) return;
                            context.read<AppSettingsService>().setThemeMode(
                              value,
                            );
                          },
                          items: [
                            DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Text(t.themeDark),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.light,
                              child: Text(t.themeLight),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Text(t.themeSystem),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

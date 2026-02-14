import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';
import '../widgets/branded_app_bar.dart';
import '../widgets/responsive_container.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'محمد أحمد';
  String _email = 'mohammed@email.com';
  String _phone = '05xxxxxxxx';
  bool _biometric = true;
  bool _twoFactor = false;
  bool _loginAlerts = true;
  String _language = 'العربية';
  String _theme = 'داكن';

  void _openEditProfile() {
    final nameController = TextEditingController(text: _name);
    final emailController = TextEditingController(text: _email);
    final phoneController = TextEditingController(text: _phone);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('تعديل البيانات', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'الاسم')),
            const SizedBox(height: 10),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'البريد الإلكتروني')),
            const SizedBox(height: 10),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'رقم الهاتف')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _name = nameController.text.trim();
                  _email = emailController.text.trim();
                  _phone = phoneController.text.trim();
                });
                Navigator.of(context).pop();
              },
              child: const Text('حفظ التغييرات'),
            ),
          ],
        ),
      ),
    );
  }

  void _openAvatarPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('التقاط صورة'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('اختيار من المعرض'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(title: 'الملف الشخصي'),
      body: ResponsiveContainer(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('الملف الشخصي'),
                    subtitle: const Text('عرض وتعديل بيانات الحساب'),
                    onTap: _openEditProfile,
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.airplane_ticket_outlined),
                    title: const Text('رحلاتي'),
                    subtitle: const Text('عرض الحجوزات الحالية والسابقة'),
                    onTap: () => context.go('/mytrips'),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('الإعدادات'),
                    subtitle: const Text('إعدادات التطبيق والتفضيلات'),
                    onTap: () => context.go('/settings'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: GestureDetector(
                  onTap: _openAvatarPicker,
                  child: const CircleAvatar(
                    radius: 24,
                    child: Icon(Icons.person),
                  ),
                ),
                title: Text(_name),
                subtitle: Text(_email),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _openEditProfile,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SectionHeader(title: 'إعدادات الأمان'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('تسجيل الدخول بالبصمة'),
                    value: _biometric,
                    onChanged: (v) => setState(() => _biometric = v),
                  ),
                  const Divider(height: 0),
                  SwitchListTile(
                    title: const Text('المصادقة الثنائية'),
                    value: _twoFactor,
                    onChanged: (v) => setState(() => _twoFactor = v),
                  ),
                  const Divider(height: 0),
                  SwitchListTile(
                    title: const Text('تنبيهات تسجيل الدخول'),
                    value: _loginAlerts,
                    onChanged: (v) => setState(() => _loginAlerts = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionHeader(title: 'اللغة والمظهر'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('اللغة'),
                    trailing: DropdownButton<String>(
                      value: _language,
                      onChanged: (value) => setState(() => _language = value ?? _language),
                      items: const [
                        DropdownMenuItem(value: 'العربية', child: Text('العربية')),
                        DropdownMenuItem(value: 'English', child: Text('English')),
                      ],
                    ),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    title: const Text('المظهر'),
                    trailing: DropdownButton<String>(
                      value: _theme,
                      onChanged: (value) => setState(() => _theme = value ?? _theme),
                      items: const [
                        DropdownMenuItem(value: 'داكن', child: Text('داكن')),
                        DropdownMenuItem(value: 'فاتح', child: Text('فاتح')),
                        DropdownMenuItem(value: 'النظام', child: Text('النظام')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionHeader(title: 'بيانات التواصل'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('الهاتف'),
                    subtitle: Text(_phone),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.mail_outline),
                    title: const Text('البريد الإلكتروني'),
                    subtitle: Text(_email),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('تسجيل الخروج'),
                onTap: () async {
                  await context.read<AuthService>().logout();
                  if (!context.mounted) return;
                  context.go('/login');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

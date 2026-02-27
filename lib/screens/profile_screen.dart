import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';
import '../l10n/app_localizations.dart';
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
            Text(
              'تعديل البيانات',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'الاسم'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'رقم الهاتف'),
            ),
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
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: BrandedAppBar(title: t.profileTitle),
      body: ResponsiveContainer(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _openAvatarPicker,
                      child: const CircleAvatar(
                        radius: 28,
                        child: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_name, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(_email, style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 4),
                          Text(_phone, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _openEditProfile,
                      child: Text(t.editProfile),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.airplane_ticket_outlined),
                    title: Text(t.myTripsLabel),
                    subtitle: Text(t.myTripsSubtitle),
                    onTap: () => context.go('/mytrips'),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.insert_chart_outlined),
                    title: Text(t.reportsLabel),
                    subtitle: Text(t.reportsSubtitle),
                    onTap: () => context.go('/reports'),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.notifications_none),
                    title: const Text('الإشعارات'),
                    subtitle: const Text('اطلاع على آخر التنبيهات'),
                    onTap: () => context.go('/notifications'),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.mosque_outlined),
                    title: const Text('طلباتي للحج والعمرة'),
                    subtitle: const Text('متابعة حالة الطلبات والتفاصيل'),
                    onTap: () => context.go('/hajj-umrah/my-applications'),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: Text(t.settingsLabel),
                    subtitle: Text(t.settingsSubtitle),
                    onTap: () => context.go('/settings'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: Text(t.phoneLabel),
                    subtitle: Text(_phone),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.mail_outline),
                    title: Text(t.emailLabel),
                    subtitle: Text(_email),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: Text(t.logoutLabel),
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

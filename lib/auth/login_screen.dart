import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';
import '../data/models/user_role.dart';
import '../widgets/branded_app_bar.dart';
import '../widgets/responsive_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  bool _remember = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final auth = context.read<AuthService>();
      await auth.restoreSession();
      if (!mounted) return;
      if (auth.isLoggedIn) {
        context.go(auth.role == UserRole.admin ? '/admin' : '/home');
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    final result = await context.read<AuthService>().login(
          username: _usernameController.text,
          password: _passwordController.text,
          remember: _remember,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
      return;
    }
    final auth = context.read<AuthService>();
    context.go(auth.role == UserRole.admin ? '/admin' : '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: const BrandedAppBar(title: 'تسجيل الدخول'),
          body: SafeArea(
            child: ResponsiveContainer(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('اسم المستخدم'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(hintText: 'username'),
                        validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 12),
                      const Text('كلمة المرور'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscure = !_obscure),
                            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        value: _remember,
                        onChanged: (value) => setState(() => _remember = value ?? true),
                        title: const Text('تذكرني'),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        child: const Text('دخول'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () async {
                          await context.read<AuthService>().loginGuest();
                          if (!mounted) return;
                          context.go('/home');
                        },
                        child: const Text('الدخول كضيف'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: const Text('إنشاء حساب جديد'),
                      ),
                      TextButton(
                        onPressed: () => context.go('/forgot'),
                        child: const Text('نسيت كلمة المرور؟'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_loading)
          Container(
            color: Colors.black45,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

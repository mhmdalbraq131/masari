import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../logic/app_state.dart';
import '../../data/models/user_role.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  bool _remember = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<AppState>();
      if (!state.isLoggedIn) return;
      context.go(state.role == UserRole.admin ? '/admin' : '/home');
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة الحقول بشكل صحيح')),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    final email = _emailController.text.trim().toLowerCase();
    final role = email.contains('admin') ? UserRole.admin : UserRole.user;
    await context.read<AppState>().login(
          role: role,
          username: email,
          remember: _remember,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    context.go(role == UserRole.admin ? '/admin' : '/home');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
                      const Text('البريد الإلكتروني'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(hintText: 'email@gmail.com'),
                        validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 12),
                      const Text('كلمة المرور'),
                      const SizedBox(height: 6),
                      TextFormField(
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
                          await context.read<AppState>().loginGuest();
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

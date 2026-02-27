import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';
import '../data/models/user_role.dart';
import '../widgets/branded_app_bar.dart';
import '../widgets/responsive_container.dart';

class LoginScreen extends StatefulWidget {
  final bool adminMode;
  final String? title;

  const LoginScreen({super.key, this.adminMode = false, this.title});

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
  bool? _adminExists;

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
        return;
      }
      if (widget.adminMode) {
        final exists = await auth.hasAdminUser();
        if (!mounted) return;
        setState(() => _adminExists = exists);
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
    final auth = context.read<AuthService>();
    final isAdminSetup = widget.adminMode && _adminExists == false;
    final result = isAdminSetup
        ? await auth.register(
            username: _usernameController.text,
            password: _passwordController.text,
            role: UserRole.admin,
            remember: true,
          )
        : await auth.login(
            username: _usernameController.text,
            password: _passwordController.text,
            remember: _remember,
            requiredRole: widget.adminMode ? UserRole.admin : null,
          );
    if (!mounted) return;
    setState(() => _loading = false);
    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
      return;
    }
    context.go(auth.role == UserRole.admin ? '/admin' : '/home');
  }

  @override
  Widget build(BuildContext context) {
    final adminCheckPending = widget.adminMode && _adminExists == null;
    final isAdminSetup = widget.adminMode && _adminExists == false;
    return Stack(
      children: [
        Scaffold(
          appBar: BrandedAppBar(
            title: widget.title ?? (widget.adminMode ? 'دخول المدير' : 'تسجيل الدخول'),
          ),
          body: SafeArea(
            child: ResponsiveContainer(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.adminMode && _adminExists == false)
                        const Text('لا يوجد حساب مدير بعد، سيتم إنشاؤه الآن.'),
                      if (widget.adminMode && _adminExists == false)
                        const SizedBox(height: 12),
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
                      if (!widget.adminMode) ...[
                        CheckboxListTile(
                          value: _remember,
                          onChanged: (value) => setState(() => _remember = value ?? true),
                          title: const Text('تذكرني'),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        const SizedBox(height: 8),
                      ],
                      ElevatedButton(
                        onPressed: _loading || adminCheckPending ? null : _submit,
                        child: Text(isAdminSetup ? 'إنشاء حساب المدير' : 'دخول'),
                      ),
                      if (adminCheckPending) ...[
                        const SizedBox(height: 8),
                        const Center(child: CircularProgressIndicator()),
                      ],
                      const SizedBox(height: 8),
                      if (!widget.adminMode) ...[
                        TextButton(
                          onPressed: () async {
                            final auth = context.read<AuthService>();
                            final router = GoRouter.of(context);
                            await auth.loginGuest();
                            if (!mounted) return;
                            router.go('/home');
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
                      ] else
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('العودة لتسجيل المستخدم'),
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

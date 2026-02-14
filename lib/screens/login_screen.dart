import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/responsive_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future<void> _submit() async {
    // التحقق من صحة النموذج
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة الحقول')),
      );
      return;
    }
    // محاكاة تحميل
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: ResponsiveContainer(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      const Text(
                        'تسجيل الدخول',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 24),
                      const Text('البريد الإلكتروني'),
                      const SizedBox(height: 6),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(hintText: 'email@gmail.com'),
                        validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text('كلمة المرور'),
                      const SizedBox(height: 6),
                      TextFormField(
                        obscureText: true,
                        decoration: const InputDecoration(hintText: '••••••••'),
                        validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        child: const Text('دخول'),
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

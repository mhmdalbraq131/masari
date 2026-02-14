import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';

class AuthRequired extends StatefulWidget {
  final Widget child;
  final String? reason;

  const AuthRequired({super.key, required this.child, this.reason});

  @override
  State<AuthRequired> createState() => _AuthRequiredState();
}

class _AuthRequiredState extends State<AuthRequired> {
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    if (auth.isLoggedIn) {
      return widget.child;
    }
    if (!_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('تسجيل الدخول مطلوب'),
            content: Text(widget.reason ?? 'يرجى تسجيل الدخول للمتابعة'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/login');
                },
                child: const Text('تسجيل الدخول'),
              ),
            ],
          ),
        );
      });
    }
    return const SizedBox.shrink();
  }
}

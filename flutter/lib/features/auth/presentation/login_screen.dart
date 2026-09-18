import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/password_field.dart';
import '../application/auth_controller.dart';
import 'auth_error_text.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _submitting = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _looksLikeEmail => _identifierController.text.contains('@');

  Future<void> _submit() async {
    final t = ref.read(appStringsProvider);
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;
    if (identifier.isEmpty || password.isEmpty) {
      setState(() => _error = t('auth.errGeneric'));
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });

    // Stage 35H: captured *before* the await, not read again afterwards —
    // a successful login flips auth state, which rebuilds the whole
    // GoRouter (see app_router.dart's doc comment) starting a fresh
    // redirect pass from its own `initialLocation`. Reading the query
    // param off `context` again after that reset could see a route that's
    // already moved on, silently losing the destination.
    final next = GoRouterState.of(context).uri.queryParameters['next'];

    final result = await ref.read(authControllerProvider.notifier).login(
          email: _looksLikeEmail ? identifier : null,
          phone: _looksLikeEmail ? null : identifier,
          password: password,
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    switch (result) {
      case ApiOk():
        // Return to the protected action that sent the user here (see
        // AppRoutes.loginWithNext) when there is one, so signing in
        // doesn't strand them back at the generic home screen.
        context.go(next != null && next.isNotEmpty ? Uri.decodeComponent(next) : AppRoutes.home);
      case ApiErr(:final error):
        setState(() => _error = authErrorText(t, error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark ? AppColors.gradientDark : AppColors.gradientLight;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                ShaderMask(
                  shaderCallback: (bounds) => gradient.createShader(bounds),
                  child: Text(
                    'CodeSchool.kz',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t('auth.loginTitle'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _identifierController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.username],
                  decoration: InputDecoration(labelText: t('auth.emailOrPhone')),
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _passwordController,
                  label: t('auth.password'),
                  showLabel: t('auth.showPassword'),
                  hideLabel: t('auth.hidePassword'),
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: Text(_submitting ? t('auth.submitting') : t('auth.loginSubmit')),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _submitting ? null : () => context.go(AppRoutes.register),
                  child: Text('${t('auth.noAccount')} ${t('auth.toRegister')}'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

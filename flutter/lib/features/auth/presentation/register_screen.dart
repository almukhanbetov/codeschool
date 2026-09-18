import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/password_field.dart';
import '../../../shared/models/app_role.dart';
import '../application/auth_controller.dart';
import 'auth_error_text.dart';

/// `users.PublicRoles` (backend/internal/users/model.go) — admin accounts
/// are never self-registered, so [AppRole.admin] is deliberately excluded.
const _publicRoles = [AppRole.student, AppRole.teacher, AppRole.parent];

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  AppRole _role = AppRole.student;
  String? _error;
  bool _submitting = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  bool get _looksLikeEmail => _identifierController.text.contains('@');

  Future<void> _submit() async {
    final t = ref.read(appStringsProvider);
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;
    final firstName = _firstNameController.text.trim();

    if (identifier.isEmpty) {
      setState(() => _error = t('auth.errNeedEmailOrPhone'));
      return;
    }
    if (password.length < 8) {
      setState(() => _error = t('auth.errPasswordShort'));
      return;
    }
    if (firstName.isEmpty) {
      setState(() => _error = t('auth.errFirstNameRequired'));
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    final result = await ref.read(authControllerProvider.notifier).register(
          email: _looksLikeEmail ? identifier : null,
          phone: _looksLikeEmail ? null : identifier,
          password: password,
          firstName: firstName,
          lastName: _lastNameController.text.trim().isEmpty ? null : _lastNameController.text.trim(),
          role: _role,
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    switch (result) {
      case ApiOk():
        context.go(AppRoutes.home);
      case ApiErr(:final error):
        setState(() => _error = authErrorText(t, error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appStringsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t('auth.registerTitle'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _firstNameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: t('auth.firstName')),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _lastNameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: t('auth.lastName')),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _identifierController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: t('auth.emailOrPhone')),
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _passwordController,
                  label: t('auth.password'),
                  showLabel: t('auth.showPassword'),
                  hideLabel: t('auth.hidePassword'),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 4),
                Text(t('auth.passwordHint'), style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                DropdownButtonFormField<AppRole>(
                  initialValue: _role,
                  decoration: InputDecoration(labelText: t('auth.role')),
                  items: _publicRoles
                      .map((r) => DropdownMenuItem(value: r, child: Text(t('common.role.${r.name}'))))
                      .toList(),
                  onChanged: (r) => setState(() => _role = r ?? AppRole.student),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: Text(_submitting ? t('auth.submitting') : t('auth.registerSubmit')),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _submitting ? null : () => context.go(AppRoutes.login),
                  child: Text('${t('auth.haveAccount')} ${t('auth.toLogin')}'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

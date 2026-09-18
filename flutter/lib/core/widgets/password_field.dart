import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Password input with a show/hide toggle — the mobile equivalent of the
/// web's `PasswordInput.tsx`. Defaults to obscured; never logs or persists
/// its value (Stage 35 brief §4/§16: passwords never touch storage/logs).
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.showLabel,
    required this.hideLabel,
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String showLabel;
  final String hideLabel;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscured,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: IconButton(
          icon: Icon(_obscured ? LucideIcons.eye : LucideIcons.eyeOff),
          tooltip: _obscured ? widget.showLabel : widget.hideLabel,
          onPressed: () => setState(() => _obscured = !_obscured),
        ),
      ),
    );
  }
}

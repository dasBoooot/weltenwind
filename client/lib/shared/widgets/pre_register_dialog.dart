import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../dialogs/pre_register_fullscreen_dialog.dart';

/// 🎨 Pre Register Dialog - Wrapper for Fullscreen Version
/// 
/// This is a wrapper that maintains backward compatibility
/// while using the new fullscreen dialog system.
class PreRegisterDialog extends StatefulWidget {
  final String worldName;
  final Function(String email) onPreRegister;

  const PreRegisterDialog({
    super.key,
    required this.worldName,
    required this.onPreRegister,
  });

  @override
  State<PreRegisterDialog> createState() => _PreRegisterDialogState();

  /// 🚀 Show PreRegister Dialog (uses new fullscreen version)
  static Future<bool?> show(
    BuildContext context, {
    required String worldName,
    required Future<void> Function(String email) onPreRegister,
  }) {
    return showPreRegisterDialog(
      context,
      worldName: worldName,
      onPreRegister: onPreRegister,
    );
  }
}

class _PreRegisterDialogState extends State<PreRegisterDialog> {
  @override
  Widget build(BuildContext context) {
    // This widget now automatically shows the fullscreen dialog
    // when used in showDialog() calls
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showPreRegisterDialog(
        context,
        worldName: widget.worldName,
        onPreRegister: (email) async {
          await widget.onPreRegister(email);
        },
      ).then((result) {
        // Pop this placeholder dialog and return the result
        Navigator.of(context).pop(result);
      });
    });

    // Return an invisible placeholder while the fullscreen dialog is shown
    return const SizedBox.shrink();
  }
}

// Old implementation kept for reference but not used
class _OldPreRegisterDialogState extends State<PreRegisterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onPreRegister(_emailController.text.trim());
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).preRegistrationSuccess),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
                          content: Text(AppLocalizations.of(context).errorGenericWithDetails(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      title: Text(
        'Vorregistrierung für ${widget.worldName}',
        style: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Geben Sie Ihre E-Mail-Adresse ein, um sich für diese Welt vorzuregistrieren:',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context).authForgotPasswordEmailLabel,
                labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                prefixIcon: Icon(Icons.email, color: colorScheme.primary),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.error),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'E-Mail-Adresse ist erforderlich';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Bitte geben Sie eine gültige E-Mail-Adresse ein';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.onSurfaceVariant,
          ),
                            child: Text(AppLocalizations.of(context).buttonCancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                  ),
                )
                                    : Text(AppLocalizations.of(context).worldPreRegisterButton),
        ),
      ],
    );
  }
} 
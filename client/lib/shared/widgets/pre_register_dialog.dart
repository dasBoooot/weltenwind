import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

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
}

class _PreRegisterDialogState extends State<PreRegisterDialog> {
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
          const SnackBar(
            content: Text('Vorregistrierung erfolgreich!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler: ${e.toString()}'),
            backgroundColor: theme.colorScheme.error,
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
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A), // Dunkler Hintergrund
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      title: Text(
        'Vorregistrierung für ${widget.worldName}',
        style: const TextStyle(
          color: Colors.white,
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
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white), // Weiße Schrift
              decoration: InputDecoration(
                labelText: 'E-Mail-Adresse',
                labelStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.email, color: theme.colorScheme.primary),
                filled: true,
                fillColor: const Color(0xFF2D2D2D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red[400]!),
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
            foregroundColor: Colors.grey[400],
          ),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Vorregistrieren'),
        ),
      ],
    );
  }
} 
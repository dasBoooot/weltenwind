import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class InviteDialog extends StatefulWidget {
  final String worldName;

  const InviteDialog({
    super.key,
    required this.worldName,
  });

  @override
  State<InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends State<InviteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    // Simuliere API-Aufruf für E-Mail-Versand
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop(_emailController.text.trim());
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
        'Einladung für ${widget.worldName}',
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
              'Geben Sie die E-Mail-Adresse der Person ein, die Sie einladen möchten:',
              style: TextStyle(
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              autofocus: true, // Barrierefreiheit: Sofortiger Fokus
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
        // Bessere Button-Abstände mit Padding
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[400],
            ),
            child: const Text('Abbrechen'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ElevatedButton(
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
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Einladung senden'),
          ),
        ),
      ],
    );
  }
} 
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../../config/logger.dart';
import '../../../config/env.dart';
import '../../../core/services/api_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/index.dart';
import '../../../main.dart';

/// Modulares Widget zum Versenden von Einladungen
/// Kann überall in der App verwendet werden wo Invites gesendet werden sollen
class InviteWidget extends StatefulWidget {
  /// ID der Welt für die eingeladen werden soll
  final String worldId;
  
  /// Name der Welt (für Anzeige)
  final String worldName;
  
  /// Callback der aufgerufen wird wenn Invite erfolgreich versendet wurde
  final VoidCallback? onInviteSent;
  
  /// Ob das Widget als Dialog angezeigt werden soll
  final bool isDialog;
  
  /// Custom Padding
  final EdgeInsets? padding;
  
  /// ApiService direkt übergeben - löst Provider-Probleme
  final ApiService? apiService;

  const InviteWidget({
    super.key,
    required this.worldId,
    required this.worldName,
    this.onInviteSent,
    this.isDialog = false,
    this.padding,
    this.apiService,
  });

  @override
  State<InviteWidget> createState() => _InviteWidgetState();
}

class _InviteWidgetState extends State<InviteWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  
  bool _isLoading = false;
  String? _error;
  String? _inviteLink;
  bool _sendEmail = true; // Standardmäßig E-Mail versenden

  @override
  void initState() {
    super.initState();
    // Debug-Log entfernt für saubere Logs
    // Console debug entfernt
  }
  
  // E-Mail-Validierung Regex
  static final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendInvite() async {
    // Debug-Log entfernt für saubere Logs
    // Console debug entfernt
    
    // Prevent multiple simultaneous calls
    if (_isLoading) {
      AppLogger.app.w('⚠️ _sendInvite bereits aktiv - Aufruf ignoriert');
      // Console debug entfernt
      return;
    }
    
    // Console debug entfernt
    if (!_formKey.currentState!.validate()) {
      // Console debug entfernt
      return;
    }
    // Console debug entfernt

    // Entferntes Console Debug: //print('🔧 CONSOLE DEBUG: setState() aufgerufen - Loading wird gesetzt...'); // Console Log
    setState(() {
      _isLoading = true;
      _error = null;
      _inviteLink = null;
    });
    // Entferntes Console Debug: //print('🔧 CONSOLE DEBUG: setState() ERFOLGREICH abgeschlossen!'); // Console Log

    try {
      // Entferntes Console Debug: //print('🔧 CONSOLE DEBUG: Try-Block gestartet...'); // Console Log
      // Entferntes Console Debug: //print('🔧 CONSOLE DEBUG: ApiService wird geholt...'); // Console Log
      final apiService = widget.apiService ?? ServiceLocator.get<ApiService>();
      // Entferntes Console Debug: //print('🔧 CONSOLE DEBUG: ApiService erhalten: ${apiService.runtimeType}'); // Console Log
      
      final email = _emailController.text.trim().toLowerCase();
      // Entferntes Console Debug: //print('🔧 CONSOLE DEBUG: Email vorbereitet: $email'); // Console Log
      
      AppLogger.app.i('📧 Sende Invite', error: {
        'worldId': widget.worldId,
        'worldName': widget.worldName,
        'email': email,
        'sendEmail': _sendEmail
      });

      // API-Endpoint für Invite-Erstellung (ohne /api - wird von ApiService hinzugefügt)
      // Immer authentifizierten Endpoint verwenden um invitedBy zu setzen
      const endpoint = '/invites';
      // Entferntes Console Debug: //print('🔧 CONSOLE DEBUG: API-Call startet - Endpoint: $endpoint'); // Console Log
      // Entferntes Console Debug: //print('🔧 CONSOLE DEBUG: Request Data: worldId=${widget.worldId}, email=$email'); // Console Log
      
      final response = await apiService.post(endpoint, {
        'worldId': widget.worldId,
        'email': email,
        'sendEmail': _sendEmail, // Flag für E-Mail-Versand
      });
      
      // Entferntes Console Debug: //print('🔧 CONSOLE DEBUG: API-Response erhalten - Status: ${response.statusCode}'); // Console Log

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        // Entferntes Console Debug: //print('🔧 CONSOLE DEBUG: Response Data: $responseData'); // Console Log
        final invitesArray = responseData['data']['invites'] as List;
        // Entferntes Console Debug: //print('🔧 CONSOLE DEBUG: Invites Array: $invitesArray'); // Console Log
        final inviteData = invitesArray.first; // Erstes (und einziges) Invite
        final token = inviteData['token'];
        
        AppLogger.app.i('✅ Invite erfolgreich erstellt', error: {
          'inviteId': inviteData['id'],
          'token': token?.substring(0, 8),
          'email': email,
          'sendEmail': _sendEmail,
          'link': inviteData['link'],
        });

        if (mounted) {
          // Link aus Response holen oder aus Token generieren
          final serverLink = inviteData['link'];
          final token = inviteData['token'];
          final generatedLink = serverLink ?? '${kIsWeb ? Uri.base.origin : Env.clientUrl}/go/invite/$token';
          
          setState(() {
            _inviteLink = generatedLink;
          });
          // Entferntes Console Debug: //print('🔧 CONSOLE DEBUG: Server-Link: $serverLink'); // Console Log
          // Entferntes Console Debug: //print('🔧 CONSOLE DEBUG: Token: $token'); // Console Log
          // Entferntes Console Debug: //print('🔧 CONSOLE DEBUG: Final Link gesetzt: $_inviteLink'); // Console Log
          final l10n = AppLocalizations.of(context);
          
          // Erfolgsmeldung anzeigen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _sendEmail 
                  ? l10n.inviteWidgetSuccessWithEmail(email)
                  : l10n.inviteWidgetSuccessLinkOnly
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              duration: const Duration(seconds: 4),
              action: !_sendEmail ? SnackBarAction(
                label: l10n.inviteWidgetCopyLink,
                textColor: Colors.white,
                onPressed: () => _copyInviteLink(token),
              ) : null,
            ),
          );

          // Form zurücksetzen
          _emailController.clear();
          
          // Callback aufrufen
          widget.onInviteSent?.call();
          
          // Dialog NICHT automatisch schließen wenn Link erstellt wurde
          // Nur bei E-Mail-Versand schließen
          if (widget.isDialog && _sendEmail) {
            Navigator.of(context).pop();
          }
        }
      } else {
        final responseData = jsonDecode(response.body);
        setState(() {
          _error = responseData['error'] ?? 'Unbekannter Fehler beim Erstellen der Einladung';
        });
      }
    } catch (e) {
      // Entferntes Console Debug: //print('🔧 CONSOLE DEBUG: EXCEPTION gefangen: $e'); // Console Log
      AppLogger.app.e('❌ Fehler beim Senden der Einladung', error: e);
      
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
      // Entferntes Console Debug: //print('🔧 CONSOLE DEBUG: Error-State gesetzt: $_error'); // Console Log
    } finally {
      // Entferntes Console Debug: //print('🔧 CONSOLE DEBUG: Finally-Block erreicht - mounted: $mounted'); // Console Log
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Entferntes Console Debug: //print('🔧 CONSOLE DEBUG: Loading auf false gesetzt'); // Console Log
      }
    }
  }

  void _copyInviteLink(String linkOrToken) async {
    try {
      // Wenn es bereits ein vollständiger Link ist, direkt verwenden
      final link = linkOrToken.startsWith('http') 
          ? linkOrToken 
          : '${kIsWeb ? Uri.base.origin : Env.clientUrl}/go/invite/$linkOrToken';
      
      await Clipboard.setData(ClipboardData(text: link));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).inviteWidgetCopyLink),
            duration: const Duration(seconds: 1),
          ),
        );
      }
      AppLogger.app.i('📋 Invite-Link kopiert', error: {'link': link});
    } catch (e) {
      AppLogger.app.e('❌ Fehler beim Kopieren des Links', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler beim Kopieren des Links'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String? _validateEmail(String? value) {
    final l10n = AppLocalizations.of(context);
    
    if (value == null || value.trim().isEmpty) {
      return l10n.inviteWidgetEmailRequired;
    }
    
    if (!_emailRegex.hasMatch(value.trim())) {
      return l10n.inviteWidgetEmailInvalid;
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    // 🎯 THEME CONTEXT CONSUMER: Invite Widget kann später World-spezifisch erweitert werden
    return ThemeContextConsumer(
      componentName: 'InviteWidget',
      contextOverrides: const {
        'uiContext': 'invite-widget',
        'componentType': 'widget',
        'context': 'utility', // Utility widget, kann überall verwendet werden
      },
      builder: (context, theme, extensions) {
        return _buildInviteWidget(context, theme, l10n);
      },
    );
  }

  Widget _buildInviteWidget(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            if (!widget.isDialog) ...[
              Row(
                children: [
                  Icon(
                    Icons.email,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.inviteWidgetTitle(widget.worldName),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // E-Mail Input
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: l10n.inviteWidgetEmailLabel,
                hintText: l10n.inviteWidgetEmailHint,
                prefixIcon: const Icon(Icons.alternate_email),
                border: const OutlineInputBorder(),
                errorMaxLines: 2,
              ),
              onFieldSubmitted: (_) {
                if (!_isLoading) {
                  _sendInvite();
                }
              },
            ),
            
            const SizedBox(height: 12),

            // E-Mail versenden Option
            CheckboxListTile(
              title: Text(l10n.inviteWidgetSendEmailOption),
              subtitle: Text(l10n.inviteWidgetSendEmailHint),
              value: _sendEmail,
              onChanged: _isLoading ? null : (value) {
                setState(() {
                  _sendEmail = value ?? true;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 16),

            // Error Display
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Send Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _sendInvite,
              icon: _isLoading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(_sendEmail ? Icons.send : Icons.link),
              label: Text(
                _sendEmail 
                  ? l10n.inviteWidgetSendButton
                  : l10n.inviteWidgetCreateLinkButton
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            
            // Link-Anzeige wenn vorhanden
            if (_inviteLink != null) ...[
              const SizedBox(height: 20),
              Text(
                l10n.inviteWidgetLinkTitle,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        _inviteLink!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copyInviteLink(_inviteLink!),
                      tooltip: l10n.inviteWidgetCopyLink,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Helper-Method um das InviteWidget als Dialog anzuzeigen
Future<T?> showInviteDialog<T extends Object?>(
  BuildContext context, {
  required String worldId,
  required String worldName,
  VoidCallback? onInviteSent,
}) {
  final l10n = AppLocalizations.of(context);
  
  // ApiService direkt aus ServiceLocator holen - funktioniert überall!
  final apiService = ServiceLocator.get<ApiService>();
  
  return showDialog<T>(
    context: context,
    builder: (dialogContext) {
      // Debug-Log um zu sehen ob Dialog geladen wird
      // Debug-Log entfernt für saubere Logs
      // Entferntes Console Debug: //print('🔧 CONSOLE DEBUG: Invite-Dialog wird erstellt'); // Console Log
      
      // Theme direkt vom ursprünglichen Context holen
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      
      return AlertDialog(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          l10n.inviteWidgetDialogTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 450,
            minWidth: 350,
          ),
          child: InviteWidget(
            worldId: worldId,
            worldName: worldName,
            onInviteSent: onInviteSent,
            isDialog: true,
            apiService: apiService,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
            ),
            child: Text(l10n.inviteWidgetCancel),
          ),
        ],
      );
    },
  );
}
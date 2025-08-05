import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/language_switcher.dart';
import '../../theme/background_widget.dart';
import '../../shared/navigation/smart_navigation.dart';
import '../../shared/components/app_scaffold.dart';
import '../../config/logger.dart';
import '../../main.dart';

class InviteLandingPage extends StatefulWidget {
  final String token;

  const InviteLandingPage({
    super.key,
    required this.token,
  });

  @override
  State<InviteLandingPage> createState() => _InviteLandingPageState();
}

class _InviteLandingPageState extends State<InviteLandingPage> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _inviteData;
  
  @override
  void initState() {
    super.initState();
    _loadInviteData();
  }

  /// 🔧 Get World Theme from API data
  String? _getWorldTheme() {
    if (_inviteData != null && _inviteData!['world'] != null) {
      final worldData = _inviteData!['world'];
      
      // Use themeVariant if available, otherwise themeBundle
      final themeVariant = worldData['themeVariant'] as String?;
      if (themeVariant != null && themeVariant.isNotEmpty && themeVariant != 'standard') {
        AppLogger.app.d('🎨 [WORLD-THEME] Using themeVariant: $themeVariant');
        return themeVariant;
      }
      
      final themeBundle = worldData['themeBundle'] as String?;
      if (themeBundle != null && themeBundle != 'full-gaming') {
        AppLogger.app.d('🎨 [WORLD-THEME] Using themeBundle: $themeBundle');
        return themeBundle;
      }
    }
    return null;
  }

  /// 🔧 Race condition detection
  bool _isThemeCorrectForWorld(String? worldTheme, ThemeData theme) {
    if (worldTheme == null) return true;
    final primaryColor = theme.colorScheme.primary;
    final isDefaultTheme = primaryColor.r > 0.7 && primaryColor.g > 0.7 && primaryColor.b > 0.9;
    final isDefaultDarkTheme = primaryColor.r > 0.3 && primaryColor.r < 0.4 && primaryColor.g < 0.3;
    
    if (worldTheme != 'default' && (isDefaultTheme || isDefaultDarkTheme)) {
      AppLogger.app.w('🚨 [RACE-CONDITION] WorldTheme: $worldTheme, but theme is default (${primaryColor.toString()})');
      return false;
    }
    return true;
  }

  Future<void> _loadInviteData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final apiService = ServiceLocator.get<ApiService>();
      final response = await apiService.get('/invites/validate/${widget.token}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          setState(() {
            _inviteData = responseData['data'];
            _isLoading = false;
          });
        } else {
          setState(() {
            // Always use localized error messages, ignore server error messages
            _error = AppLocalizations.of(context).inviteErrorInvalidOrExpired;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          // Always use localized error messages, ignore server error messages
          _error = AppLocalizations.of(context).inviteErrorInvalidOrExpired;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = AppLocalizations.of(context).inviteErrorLoadingData(e.toString());
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptInvite() async {
    try {
      final apiService = ServiceLocator.get<ApiService>();
      final response = await apiService.post('/invites/accept/${widget.token}', {});
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final worldId = responseData['data']?['world']?['id'];
          final worldName = responseData['data']?['world']?['name'];
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).worldJoinSuccess(worldName ?? AppLocalizations.of(context).worldJoinUnknownWorld)),
                backgroundColor: Colors.green,
              ),
            );
            
            if (worldId != null) {
              await context.smartGo('/go/worlds/$worldId');
            } else {
              await context.smartGoNamed('world-list');
            }
          }
        } else {
          setState(() {
            // Always use localized error messages
            _error = AppLocalizations.of(context).inviteErrorAcceptFailed;
          });
        }
      } else {
        setState(() {
          // Always use localized error messages
          _error = AppLocalizations.of(context).inviteErrorAcceptFailed;
        });
      }
    } catch (e) {
      setState(() {
        _error = AppLocalizations.of(context).inviteErrorAcceptException(e.toString());
      });
    }
  }

  Future<void> _declineInvite() async {
    try {
      final apiService = ServiceLocator.get<ApiService>();
      final response = await apiService.post('/invites/decline/${widget.token}', {});
      
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).inviteDeclineSuccess),
              backgroundColor: Colors.orange,
            ),
          );
          await context.smartGoNamed('world-list');
        }
      } else {
        setState(() {
          // Always use localized error messages
          _error = AppLocalizations.of(context).inviteErrorDeclineFailed;
        });
      }
    } catch (e) {
      setState(() {
        _error = AppLocalizations.of(context).inviteErrorDeclineException(e.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Only use world theme if invite data is valid, otherwise use default
    final worldTheme = (_error == null && _inviteData != null) ? _getWorldTheme() : null;
    
    AppLogger.app.d('🎨 [BUILD] WorldTheme: $worldTheme, InviteData: ${_inviteData != null ? 'EXISTS' : 'NULL'}, Error: ${_error != null ? 'EXISTS' : 'NULL'}');

    return AppScaffold(
      key: ValueKey('invite-${worldTheme ?? (_error != null ? 'error' : 'loading')}-${_inviteData?['world']?['id']}'),
      themeContextId: 'invite-landing',
      themeBundleId: 'full-gaming',
      worldThemeOverride: worldTheme, // null for error cases = default theme
      componentName: 'InviteLandingPage',
      showBackgroundGradient: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.invitePageTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: LanguageSwitcher(),
          ),
        ],
      ),
      bodyBuilder: (context, theme, extensions) {
        final isReady = _isThemeCorrectForWorld(worldTheme, theme);
        if (worldTheme != null && !isReady) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return Theme(
          data: theme,
          child: _buildContent(context, worldTheme, theme, l10n),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, String? worldTheme, ThemeData theme, AppLocalizations l10n) {
    return BackgroundWidget(
      worldTheme: worldTheme,
      waitForWorldTheme: _error == null, // Don't wait for world theme on errors
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width > 900 ? 800 : 600,
          ),
          padding: const EdgeInsets.all(16.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _isLoading
              ? Center(
                key: const ValueKey('loading'),
                child: CircularProgressIndicator(color: theme.colorScheme.primary),
              )
            : _error != null
            ? _buildErrorState(context, theme, l10n, key: const ValueKey('error'))
            : _buildInviteContent(context, worldTheme, theme, l10n, key: const ValueKey('content')),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ThemeData theme, AppLocalizations l10n, {Key? key}) {
    return Center(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(_error!, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInviteData,
            child: Text(l10n.buttonRetry),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteContent(BuildContext context, String? worldTheme, ThemeData theme, AppLocalizations l10n, {Key? key}) {
    if (_inviteData == null) {
      return Center(key: key, child: Text(l10n.inviteErrorNoData));
    }

    final invite = _inviteData!['invite'];
    final world = _inviteData!['world'];
    final inviter = _inviteData!['inviter'];
    final userStatusRaw = _inviteData!['userStatus'];
    final userStatus = userStatusRaw is Map<String, dynamic> 
        ? userStatusRaw['status'] as String?
        : userStatusRaw as String?;

    return SingleChildScrollView(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAppBranding(context, l10n, theme),
          const SizedBox(height: 24),
          _buildWorldPreview(context, world, inviter, l10n, theme),
          const SizedBox(height: 24),
          _buildInviteDetails(context, l10n, invite, theme),
          const SizedBox(height: 16),
          _buildActions(context, l10n, userStatus, theme),
        ],
      ),
    );
  }

  Widget _buildAppBranding(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.explore, size: 32, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.landingSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorldPreview(BuildContext context, Map<String, dynamic>? world, Map<String, dynamic>? inviter, AppLocalizations l10n, ThemeData theme) {
    final worldName = world?['name'] ?? l10n.worldJoinUnknownWorldName;
    final inviterName = inviter?['username'] ?? l10n.worldJoinUnknownWorld;
    final worldDescription = world?['description'] ?? l10n.inviteNoDescription;
    final worldTheme = world?['themeBundle'] ?? world?['themeVariant'] ?? 'Standard';
    final worldCreator = world?['createdBy'] ?? world?['creator']?['username'] ?? '-';

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              theme.colorScheme.secondaryContainer.withValues(alpha: 0.2),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🎉 Emotional Headline
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.celebration, color: theme.colorScheme.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.inviteWelcomePersonal(inviterName, worldName),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // 🌍 World Preview Title
              Text(
                l10n.inviteWorldPreviewTitle(worldName),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 📝 World Description
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.description_outlined, size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          l10n.inviteWorldDescription,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      worldDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 📊 World Info Grid
              Row(
                children: [
                  Expanded(
                    child: _buildWorldInfoTile(
                      icon: Icons.palette_outlined,
                      label: l10n.inviteWorldTheme,
                      value: worldTheme,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildWorldInfoTile(
                      icon: Icons.person_outline,
                      label: l10n.inviteWorldCreator,
                      value: worldCreator,
                      theme: theme,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 🎯 Call to Action
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.rocket_launch, color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.inviteCallToAction,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorldInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInviteDetails(BuildContext context, AppLocalizations l10n, Map<String, dynamic>? invite, ThemeData theme) {
    return Card(
      color: theme.colorScheme.surface,
      child: ExpansionTile(
        leading: Icon(Icons.info_outline, color: theme.colorScheme.primary),
        title: Text(
          l10n.inviteDetailsTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildDetailRow(context, l10n.inviteDetailsEmail, invite?['email'] ?? '-', theme),
                const SizedBox(height: 8),
                _buildDetailRow(context, l10n.inviteDetailsCreated, _formatDate(invite?['createdAt']), theme),
                const SizedBox(height: 8),
                _buildDetailRow(context, l10n.inviteDetailsExpires, _formatDate(invite?['expiresAt']), theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildActions(BuildContext context, AppLocalizations l10n, String? userStatus, ThemeData theme) {
    switch (userStatus) {
      case 'not_registered':
      case 'not_logged_in':
        return _buildRegisterActions(context, l10n, theme);
      case 'needs_login':
      case 'user_exists_not_logged_in':
      case 'logged_out':
        return _buildLoginActions(context, l10n, theme);
      case 'correct_email':
      case 'can_accept':
        return _buildAcceptActions(context, l10n, theme);
      case 'wrong_email':
      case 'email_mismatch':
        return _buildWrongEmailActions(context, l10n, theme);
      case 'already_accepted':
      case 'invite_used':
        return _buildAlreadyAcceptedActions(context, l10n, theme);
      case null:
      case '':
        return _buildLoadingActions(context, l10n, theme);
      default:
        return Card(
          color: theme.colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(Icons.warning_amber_outlined, color: theme.colorScheme.onErrorContainer, size: 32),
                const SizedBox(height: 8),
                Text(
                  '${l10n.inviteActionUnknownStatus}: "$userStatus"',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onErrorContainer),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildRegisterActions(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    final inviteEmail = _inviteData?['invite']?['email'];
    
    return Card(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              l10n.inviteActionRegisterHint,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                // 🔧 FIX: Clear AuthService before navigation
                final authService = ServiceLocator.get<AuthService>();
                if (await authService.isLoggedIn()) {
                  AppLogger.app.i('Clearing auth session before register navigation');
                  await authService.logout();
                  
                  // Wait for logout to complete
                  await Future.delayed(const Duration(milliseconds: 100));
                }
                
                await context.smartGoNamed('register', extra: {
                  'invite_token': widget.token,
                  'email': inviteEmail,
                  'auto_accept_invite': true,
                  'redirect_to_invite': '/go/invite/${widget.token}',
                });
              },
              icon: const Icon(Icons.person_add),
              label: Text(l10n.inviteActionRegisterAndJoin),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                // 🔧 FIX: Clear AuthService before navigation  
                final authService = ServiceLocator.get<AuthService>();
                if (await authService.isLoggedIn()) {
                  AppLogger.app.i('Clearing auth session before login navigation');
                  await authService.logout();
                  
                  // Wait for logout to complete
                  await Future.delayed(const Duration(milliseconds: 100));
                }
                
                await context.smartGoNamed('login', extra: {
                  'invite_token': widget.token,
                  'redirect_to_invite': '/go/invite/${widget.token}',
                });
              },
              style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
              child: Text(l10n.inviteActionAlreadyHaveAccount),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginActions(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                l10n.inviteActionLoginHint.split('.').first,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.inviteActionLoginHint,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () async {
                // 🔧 FIX: Clear AuthService before navigation
                final authService = ServiceLocator.get<AuthService>();
                if (await authService.isLoggedIn()) {
                  AppLogger.app.i('Clearing auth session before login navigation');
                  await authService.logout();
                  
                  // Wait for logout to complete
                  await Future.delayed(const Duration(milliseconds: 100));
                }
                
                await context.smartGoNamed('login', extra: {
                  'invite_token': widget.token,
                  'auto_accept_invite': true,
                  'redirect_to_invite': '/go/invite/${widget.token}',
                });
              },
              icon: const Icon(Icons.key, size: 24),
              label: Text(
                l10n.inviteActionLogin,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptActions(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    final authService = ServiceLocator.get<AuthService>();
    final currentUser = authService.currentUser;
    
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_circle, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                l10n.inviteActionAcceptHint(currentUser?.username ?? l10n.worldJoinUnknownWorld),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.green.shade400, Colors.green.shade600]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _acceptInvite,
                    icon: const Icon(Icons.check_circle, size: 24),
                    label: Text(
                      l10n.inviteActionAccept,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _declineInvite,
                    icon: const Icon(Icons.cancel_outlined, size: 24),
                    label: Text(
                      l10n.inviteActionDecline,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade300, width: 2),
                      foregroundColor: Colors.red.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWrongEmailActions(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    final authService = ServiceLocator.get<AuthService>();
    final currentEmail = authService.currentUser?.email ?? 'N/A';
    final inviteEmail = _inviteData?['invite']?['email'];
    
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber, color: theme.colorScheme.error, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.inviteActionWrongEmailHint(currentEmail, inviteEmail ?? 'N/A'),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  await authService.logout();
                  if (mounted) {
                    final navigator = context;
                    await navigator.smartGoNamed('register', queryParameters: {
                      'redirect': '/go/invite/${widget.token}',
                      if (inviteEmail != null) 'email': inviteEmail,
                    });
                  }
                } catch (e) {
                  if (mounted) {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final localizations = AppLocalizations.of(context);
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text(localizations.errorLogout(e.toString()))),
                    );
                  }
                }
              },
              icon: const Icon(Icons.logout),
              label: Text(l10n.inviteActionLogoutAndRegister),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlreadyAcceptedActions(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              l10n.inviteStatusAlreadyAccepted,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await context.smartGoNamed('world-list');
                },
                icon: const Icon(Icons.explore),
                label: Text(l10n.buttonToWorlds),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingActions(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Card(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            // Loading indicator is self-explanatory, no text needed
          ],
        ),
      ),
    );
  }
}
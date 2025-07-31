import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/language_switcher.dart';
import '../../theme/background_widget.dart';
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
            _error = responseData['error'] ?? AppLocalizations.of(context).inviteErrorInvalidOrExpired;
            _isLoading = false;
          });
        }
      } else {
        final responseData = jsonDecode(response.body);
        setState(() {
          _error = responseData['error'] ?? AppLocalizations.of(context).inviteErrorInvalidOrExpired;
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
              context.go('/go/worlds/$worldId');
            } else {
              context.goNamed('world-list');
            }
          }
        } else {
          final responseData = jsonDecode(response.body);
          setState(() {
            _error = responseData['error'] ?? AppLocalizations.of(context).inviteErrorAcceptFailed;
          });
        }
      } else {
        final responseData = jsonDecode(response.body);
        setState(() {
          _error = responseData['error'] ?? AppLocalizations.of(context).inviteErrorAcceptFailed;
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
          context.goNamed('world-list');
        }
      } else {
        final responseData = jsonDecode(response.body);
        setState(() {
          _error = responseData['error'] ?? AppLocalizations.of(context).inviteErrorDeclineFailed;
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
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.invitePageTitle),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: LanguageSwitcher(),
          ),
        ],
      ),
      body: BackgroundWidget(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width > 900 ? 800 : 600, // 🎯 RESPONSIVE BREITE
            ),
            padding: const EdgeInsets.all(16.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500), // 🎯 SMOOTH TRANSITION
              child: _isLoading
                  ? const Center(
                      key: ValueKey('loading'),
                      child: CircularProgressIndicator(),
                    )
                  : _error != null
                      ? _buildErrorState(
                          context, 
                          l10n,
                          key: const ValueKey('error'),
                        )
                      : _buildContent(
                          context, 
                          l10n,
                          key: const ValueKey('content'),
                        ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, AppLocalizations l10n, {Key? key}) {
    return Center(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInviteData,
            child: Text(l10n.buttonRetry),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n, {Key? key}) {
    if (_inviteData == null) {
      return Center(
        key: key,
        child: Text(l10n.inviteErrorNoData),
      );
    }

    final invite = _inviteData!['invite'];
    final world = _inviteData!['world'];
    final inviter = _inviteData!['inviter'];
    
    // 🔧 FIX: userStatus kann ein Objekt sein - extrahiere das 'status' Feld
    final userStatusRaw = _inviteData!['userStatus'];
    final userStatus = userStatusRaw is Map<String, dynamic> 
        ? userStatusRaw['status'] as String?
        : userStatusRaw as String?;
    


    return SingleChildScrollView(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🎮 APP BRANDING SECTION
          _buildAppBranding(context, l10n),
          const SizedBox(height: 16),
          
          // 🖼️ HERO IMAGE (optional)
          _buildHeroImage(context, world),
          
          // 🎨 HERO SECTION - Modernes Design
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor.withValues(alpha: 0.8),
                  Theme.of(context).primaryColor.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                // 🎮 Gaming Icon statt Mail
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.gamepad,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                
                // 🎯 Einladungs-Header
                Text(
                  l10n.inviteWelcomeTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // 🌍 Welt-Name prominent
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    world?['name'] ?? l10n.worldJoinUnknownWorldName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                
                // 👤 Einlader-Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person, color: Colors.white70, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.inviteFromUser(inviter?['username'] ?? l10n.worldJoinUnknownWorld),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 📋 INVITE DETAILS EXPANSION
          _buildInviteDetails(context, l10n, invite),

          const SizedBox(height: 16),

          // 📋 STATUS DEBUG (temporär für Diagnose)
          if (userStatusRaw != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Raw Status:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$userStatusRaw',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (userStatus != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          'Extracted: $userStatus',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

          // 🎯 Actions
          _buildActions(context, l10n, userStatus),
          
          const SizedBox(height: 32),
          
          // 🌍 MARKETING SECTION - Weitere Welten
          _buildMarketingSection(context, l10n),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  // 🖼️ HERO IMAGE SECTION (optional)
  Widget _buildHeroImage(BuildContext context, Map<String, dynamic>? world) {
    final imageUrl = world?['bannerUrl'] ?? world?['imageUrl'];
    
    if (imageUrl != null && imageUrl.toString().isNotEmpty) {
      return Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              height: 160,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(context),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }
    
    // Fallback: Placeholder image für visuelle Aufwertung
    return Column(
      children: [
        _buildPlaceholderImage(context),
        const SizedBox(height: 16),
      ],
    );
  }

  // 🎨 PLACEHOLDER IMAGE
  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.3),
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.landscape,
              size: 48,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 8),
            Text(
              'Welt-Banner',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📋 INVITE DETAILS EXPANSION
  Widget _buildInviteDetails(BuildContext context, AppLocalizations l10n, Map<String, dynamic>? invite) {
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.info_outline),
        title: Text(
          l10n.inviteDetailsTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildDetailRow(
                  context, 
                  l10n.inviteDetailsEmail, 
                  invite?['email'] ?? '-',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  context, 
                  l10n.inviteDetailsCreated,
                  _formatDate(invite?['createdAt']),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  context, 
                  l10n.inviteDetailsExpires, 
                  _formatDate(invite?['expiresAt']),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🕒 DATE FORMATTER HELPER
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString; // Fallback to original string
    }
  }

  Widget _buildActions(BuildContext context, AppLocalizations l10n, String? userStatus) {
    switch (userStatus) {
      case 'not_registered':
      case 'not_logged_in': // 🔧 FIX: Für unbekannte User die sich registrieren müssen
        return _buildRegisterActions(context, l10n);
      case 'needs_login':
      case 'user_exists_not_logged_in': // 🔧 FIX: Status von Backend-Objekt
      case 'logged_out': // 🔧 Zusätzlicher möglicher Status
        return _buildLoginActions(context, l10n);
      case 'correct_email':
      case 'can_accept': // 🔧 Zusätzlicher möglicher Status
        return _buildAcceptActions(context, l10n);
      case 'wrong_email':
      case 'email_mismatch': // 🔧 Zusätzlicher möglicher Status
        return _buildWrongEmailActions(context, l10n);
      case 'already_accepted':
      case 'invite_used':
        return _buildAlreadyAcceptedActions(context, l10n);
      case null:
      case '':
        return _buildLoadingActions(context, l10n);
      default:
        // 🚨 ERWEITERTE DEBUG-INFO für unbekannte Status
        return Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.inviteActionUnknownStatus,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Status: "$userStatus"',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer.withValues(alpha: 0.8),
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildRegisterActions(BuildContext context, AppLocalizations l10n) {
    final inviteEmail = _inviteData?['invite']?['email'];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              l10n.inviteActionRegisterHint,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // 🎯 CLEAN NAVIGATION: Direkt zur Register-Seite mit invite_token im State
                context.goNamed('register', extra: {
                  'invite_token': widget.token,
                  'email': inviteEmail,
                  'auto_accept_invite': true,  // Flag für Auto-Accept nach Registrierung
                  'redirect_to_invite': '/go/invite/${widget.token}',
                });
              },
              icon: const Icon(Icons.person_add),
              label: Text(l10n.inviteActionRegisterAndJoin),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // 🎯 CLEAN NAVIGATION: Direkt zur Login-Seite mit invite_token im State
                context.goNamed('login', extra: {
                  'invite_token': widget.token,
                  'redirect_to_invite': '/go/invite/${widget.token}',
                });
              },
              child: Text(l10n.inviteActionAlreadyHaveAccount),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginActions(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
          // 🔑 Login Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.login,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.inviteActionLoginHint.split('.').first, // Erster Satz für Header
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.inviteActionLoginHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          
          // 🔐 Login Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                // 🎯 CLEAN NAVIGATION: Direkt zur Login-Seite mit invite_token im State
                context.goNamed('login', extra: {
                  'invite_token': widget.token,
                  'auto_accept_invite': true,  // Flag für Auto-Accept nach Login
                  'redirect_to_invite': '/go/invite/${widget.token}',
                });
              },
              icon: const Icon(Icons.key, size: 24),
              label: Text(
                l10n.inviteActionLogin,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptActions(BuildContext context, AppLocalizations l10n) {
    final authService = ServiceLocator.get<AuthService>();
    final currentUser = authService.currentUser;
    
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
          // 👤 User Info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_circle,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.inviteActionAcceptHint(currentUser?.username ?? l10n.worldJoinUnknownWorld),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 🎯 Action Buttons - Moderne Version
          Row(
            children: [
              // ✅ ACCEPT Button
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                    ),
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // ❌ DECLINE Button  
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _declineInvite,
                    icon: const Icon(Icons.cancel_outlined, size: 24),
                    label: Text(
                      l10n.inviteActionDecline,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade300, width: 2),
                      foregroundColor: Colors.red.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

  Widget _buildWrongEmailActions(BuildContext context, AppLocalizations l10n) {
    final authService = ServiceLocator.get<AuthService>();
    final currentEmail = authService.currentUser?.email ?? 'N/A';
    final inviteEmail = _inviteData?['invite']?['email'];
    
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // ⚠️ Warning Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber,
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.inviteActionWrongEmailHint(currentEmail, inviteEmail ?? 'N/A'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 🔧 Logout + Register Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  await authService.logout();
                  if (mounted) {
                    context.goNamed('register', queryParameters: {
                      'redirect': '/go/invite/${widget.token}',
                      if (inviteEmail != null) 'email': inviteEmail,
                    });
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logout error: $e')),
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

  // 🎮 APP BRANDING SECTION
  Widget _buildAppBranding(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 🎮 Game Logo/Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.explore,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          
          // 🎯 App Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).appTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context).landingSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔄 LOADING ACTIONS (wenn Status noch nicht geladen)
  Widget _buildLoadingActions(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Status wird geladen...', // TODO: Add to l10n if needed
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ ALREADY ACCEPTED ACTIONS (Einladung bereits angenommen)
  Widget _buildAlreadyAcceptedActions(BuildContext context, AppLocalizations l10n) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Einladung bereits angenommen!', // TODO: Add to l10n if needed
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Du hast diese Einladung bereits angenommen. Du kannst jetzt zur Welt gehen.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.goNamed('world-list');
                },
                icon: const Icon(Icons.explore),
                label: const Text('Zu den Welten'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🌍 MARKETING SECTION
  Widget _buildMarketingSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 📢 Marketing Header
        Row(
          children: [
            Icon(
              Icons.explore_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).marketingDiscoverMoreWorlds,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 🎯 Marketing Cards
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // 🚀 Call to Action
              Row(
                children: [
                  Icon(
                    Icons.public,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).marketingCallToAction,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 📊 Features
              Row(
                children: [
                  Expanded(
                    child: _buildFeatureItem(
                      context,
                      Icons.groups,
                      AppLocalizations.of(context).marketingFeatureCommunityTitle,
                      AppLocalizations.of(context).marketingFeatureCommunityDesc,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFeatureItem(
                      context,
                      Icons.create,
                      AppLocalizations.of(context).marketingFeatureCreateTitle,
                      AppLocalizations.of(context).marketingFeatureCreateDesc,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFeatureItem(
                      context,
                      Icons.explore,
                      AppLocalizations.of(context).marketingFeatureExploreTitle,
                      AppLocalizations.of(context).marketingFeatureExploreDesc,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // 🔗 Browse Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.goNamed('world-list');
                  },
                  icon: const Icon(Icons.explore_outlined),
                  label: Text(AppLocalizations.of(context).marketingBrowseAllWorlds),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🎯 Feature Item Helper
  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
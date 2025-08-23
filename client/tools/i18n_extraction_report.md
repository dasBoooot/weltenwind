# 🌍 Weltenwind i18n String Extraction Report

**Gesamt gefunden:** 37 Strings
**Neue Strings:** 37 (noch nicht in .arb)
**Bereits vorhanden:** 0

## 📊 Kategorien

- **world**: 37 Strings

## 🔍 Neue Strings (Priorität: Hoch → Niedrig)

### 🏷️ WORLD

**worldActiontypetextvaliditytextJeNach** (Confidence: 0.9)
- 📁 `lib\features\world\world_join_page.dart:281:87`
- 📝 Original: `" $actionTypeText.$validityText';
    
    // Je nach Status unterschiedliche Logik
    switch (status) {
      case 'not_logged_in':
        if (requiresAction == 'register') {
          // Mail ist unbekannt -> nur Register
          actionText = 'Du musst dich mit der E-Mail-Adresse $inviteEmail registrieren.';
          infoText = '$baseInfoText\n\n$actionText';
          showRegisterButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'user_exists_not_logged_in':
        if (requiresAction == 'login') {
          // Mail ist bekannt, User nicht angemeldet -> nur Login
          actionText = 'Dein Account mit $inviteEmail ist bereits registriert. Bitte melde dich an.';
          infoText = '$baseInfoText\n\n$actionText';
          showLoginButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'wrong_email':
        if (requiresAction == 'logout_and_register') {
          final currentUserEmail = userStatusData['currentUser']?['email'];
          // User mit falscher Mail angemeldet -> Logout + Register
          actionText = 'Diese Einladung ist für $inviteEmail bestimmt, aber du bist als $currentUserEmail angemeldet.';
          infoText = '$baseInfoText\n\n$actionText\n\nBitte melde dich ab und registriere dich mit der richtigen E-Mail-Adresse.';
          showLogoutButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'correct_email':
        if (requiresAction == 'join_world') {
          // User richtig angemeldet -> nur Accept Button (KEIN Auto-Accept!)
          actionText = 'Du bist mit der richtigen E-Mail-Adresse angemeldet und kannst die Einladung jetzt annehmen.';
          infoText = '$baseInfoText\n\n$actionText';
          showAcceptButton = isInviteValid; // Nur bei gültigen Invites
          
          // Auto-Accept entfernt: User soll bewusst entscheiden!
        }
        break;
        
      default:
        AppLogger.app.w('❌ Unbekannter User-Status: $status');
        actionText = 'Unbekannter Status: $status';
        infoText = '$baseInfoText\n\n$actionText';
    }
    
    // Bei ungültigen Invites zusätzliche Info
    if (!isInviteValid) {
      infoText += '\n\n⚠️ Diese Einladung kann nicht mehr verwendet werden.';
    }
    
    setState(() {
      _infoMessage = infoText;
      _inviteEmail = inviteEmail;
      
      // Button-Flags setzen
      _showLoginButton = showLoginButton;
      _showRegistrationButton = showRegisterButton; 
      _showLogoutButton = showLogoutButton;
      _showAcceptInviteButton = showAcceptButton;
      
      // WICHTIG: Alte Fehlermeldung zurücksetzen!
      _errorMessage = null;
      
      _isLoading = false;
    });
  }

  // Neue Methode: World-Status für normale Navigation prüfen
  Future<void> _checkWorldStatus() async {
    if (_world == null) return;
    
    try {
      // Prüfe ob User bereits Mitglied ist
      _isJoined = await _worldService.isPlayerInWorld(_world!.id);
      
      // Prüfe Vorregistrierung
      final preRegStatus = await _worldService.getPreRegistrationStatus(_world!.id);
      _isPreRegistered = preRegStatus.isPreRegistered;
      
      AppLogger.app.d('✅ World-Status geprüft', error: {
        'worldName': _world!.name,
        'isJoined': _isJoined,
        'isPreRegistered': _isPreRegistered
      });
    } catch (e) {
      AppLogger.logError('Fehler beim Prüfen des World-Status', e);
    }
  }

  // Neue Methode: Automatische Invite-Akzeptierung
  Future<void> _autoAcceptInvite() async {
    if (widget.inviteToken == null) return;
    
    try {
      final result = await _worldService.acceptInvite(widget.inviteToken!);
      
      if (result != null) {
        setState(() {
          _isJoined = true;
          _infoMessage = 'Willkommen in der Welt "`
- 🔧 Context:
```dart
}
    
    final baseInfoText = 'Du wurdest von $inviterText eingeladen, der Welt "$worldName" $actionTypeText.$validityText';
    
    // Je nach Status unterschiedliche Logik
```

**worldDasInviteWurde** (Confidence: 0.9)
- 📁 `lib\features\world\world_join_page.dart:384:66`
- 📝 Original: `"! Das Invite wurde automatisch akzeptiert.';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erfolgreich der Welt "`
- 🔧 Context:
```dart
setState(() {
          _isJoined = true;
          _infoMessage = 'Willkommen in der Welt "${_world?.name}"! Das Invite wurde automatisch akzeptiert.';
        });
```

**worldBeigetretenBackgroundcolorColorsgreen** (Confidence: 0.9)
- 📁 `lib\features\world\world_join_page.dart:390:67`
- 📝 Original: `" beigetreten!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // SPEZIALBEHANDLUNG: "`
- 🔧 Context:
```dart
ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erfolgreich der Welt "${_world!.name}" beigetreten!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
```

**worldIstKeinFehler** (Confidence: 0.9)
- 📁 `lib\features\world\world_join_page.dart:398:55`
- 📝 Original: `" ist KEIN Fehler!
      if (e.toString().contains('Invite bereits akzeptiert')) {
        setState(() {
          _isJoined = true;
          _infoMessage = 'Du bist bereits Mitglied dieser Welt "`
- 🔧 Context:
```dart
}
    } catch (e) {
      // SPEZIALBEHANDLUNG: "Invite bereits akzeptiert" ist KEIN Fehler!
      if (e.toString().contains('Invite bereits akzeptiert')) {
        setState(() {
```

**worldIfMountedScaffoldmessengerofcontextshowsnackbar** (Confidence: 0.9)
- 📁 `lib\features\world\world_join_page.dart:402:80`
- 📝 Original: `"!';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Du bist bereits Mitglied der Welt "`
- 🔧 Context:
```dart
setState(() {
          _isJoined = true;
          _infoMessage = 'Du bist bereits Mitglied dieser Welt "${_world?.name}"!';
        });
```

**worldBackgroundcolorColorsorangeDuration** (Confidence: 0.9)
- 📁 `lib\features\world\world_join_page.dart:408:80`
- 📝 Original: `"!'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return; // Erfolgreicher Exit
      }
      
      // Andere Fehler normal behandeln
      AppLogger.logError('Automatische Invite-Akzeptierung fehlgeschlagen', e);
      // Fehler nicht als kritisch behandeln - User kann manuell beitreten
      setState(() {
        _infoMessage = 'Du kannst nun der Welt beitreten.';
      });
    }
  }

  Future<void> _joinWorld() async {
    if (_world == null) return;

    setState(() {
      _isJoining = true;
      _joinError = null;
    });

    try {
      bool success = false;
      
      // **INVITE-TOKEN FLOW: Invite akzeptieren**
      if (widget.inviteToken != null) {
        AppLogger.app.i('🎫 Versuche Invite-Akzeptierung für World-Join');
        final inviteResult = await _worldService.acceptInvite(widget.inviteToken!);
        
        if (inviteResult != null) {
          success = true;
          AppLogger.app.i('✅ Invite erfolgreich akzeptiert', error: {
            'worldId': _world!.id,
            'worldName': _world!.name
          });
        }
      } else {
        // **NORMALE NAVIGATION: Standard World-Join**
        AppLogger.app.i('🌍 Versuche normalen World-Join');
        success = await _worldService.joinWorld(_world!.id);
      }
      
      if (success) {
        setState(() {
          _isJoined = true;
        });
        
        if (mounted) {
          final message = widget.inviteToken != null 
            ? 'Einladung akzeptiert! Willkommen in der Welt "`
- 🔧 Context:
```dart
ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Du bist bereits Mitglied der Welt "${_world?.name}"!'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
```

**worldErfolgreichDerWelt** (Confidence: 0.9)
- 📁 `lib\features\world\world_join_page.dart:462:77`
- 📝 Original: `"!'
            : 'Erfolgreich der Welt "`
- 🔧 Context:
```dart
if (mounted) {
          final message = widget.inviteToken != null 
            ? 'Einladung akzeptiert! Willkommen in der Welt "${_world!.name}"!'
            : 'Erfolgreich der Welt "${_world!.name}" beigetreten!';
```

**worldBeigetretenScaffoldmessengerofcontextshowsnackbarSnackbar** (Confidence: 0.9)
- 📁 `lib\features\world\world_join_page.dart:463:53`
- 📝 Original: `" beigetreten!';
            
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() {
          _joinError = 'Beitritt fehlgeschlagen. Versuche es erneut.';
        });
      }
    } catch (e) {
      AppLogger.logError('World Join fehlgeschlagen', e, context: {
        'worldId': _world?.id,
        'worldName': _world?.name,
        'hasInviteToken': widget.inviteToken != null,
        'inviteToken': widget.inviteToken?.substring(0, 8)
      });
      
      setState(() {
        // Bessere Fehlermeldungen für verschiedene Szenarien
        if (e.toString().contains('bereits akzeptiert')) {
          _joinError = 'Diese Einladung wurde bereits akzeptiert.';
          _isJoined = true; // User ist bereits Mitglied
        } else if (e.toString().contains('nicht für deine E-Mail-Adresse')) {
          _joinError = 'Diese Einladung ist nicht für deine E-Mail-Adresse bestimmt.';
        } else if (e.toString().contains('abgelaufen')) {
          _joinError = 'Diese Einladung ist abgelaufen.';
        } else {
          _joinError = 'Ein Fehler ist aufgetreten: ${e.toString().replaceAll('Exception: ', '')}';
        }
      });
    } finally {
      setState(() {
        _isJoining = false;
      });
    }
  }
  
  Future<void> _preRegisterWorld() async {
    final world = _world;
    if (world == null) return;

    setState(() {
      _isPreRegistering = true;
      _joinError = null;
    });

    try {
      final success = await _worldService.preRegisterWorldAuthenticated(world.id);
      
      if (success) {
        setState(() {
          _isPreRegistered = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erfolgreich für ${world.name} vorregistriert!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _joinError = 'Fehler bei der Vorregistrierung';
        });
      }
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPreRegistering = false;
        });
      }
    }
  }
  
  Future<void> _cancelPreRegistration() async {
    final world = _world;
    if (world == null) return;

    setState(() {
      _isPreRegistering = true;
      _joinError = null;
    });

    try {
      final success = await _worldService.cancelPreRegistrationAuthenticated(world.id);
      if (success) {
        setState(() {
          _isPreRegistered = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vorregistrierung für ${world.name} zurückgezogen.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        setState(() {
          _joinError = 'Fehler beim Zurückziehen der Vorregistrierung';
        });
      }
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPreRegistering = false;
        });
      }
    }
  }
  
  Future<void> _leaveWorld() async {
    final world = _world;
    if (world == null) return;
    
    // Bestätigungsdialog anzeigen
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Welt verlassen?'),
        content: Text('Möchtest du die Welt "`
- 🔧 Context:
```dart
final message = widget.inviteToken != null 
            ? 'Einladung akzeptiert! Willkommen in der Welt "${_world!.name}"!'
            : 'Erfolgreich der Welt "${_world!.name}" beigetreten!';
            
          ScaffoldMessenger.of(context).showSnackBar(
```

**worldWirklichVerlassenActions** (Confidence: 0.9)
- 📁 `lib\features\world\world_join_page.dart:600:59`
- 📝 Original: `" wirklich verlassen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Verlassen'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;

    setState(() {
      _isJoining = true;
      _joinError = null;
    });

    try {
      await _worldService.leaveWorld(world.id);
      setState(() {
        _isJoined = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Du hast ${world.name} verlassen.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }
  
  void _playWorld() {
    final world = _world;
    if (world == null) return;
    // Navigate directly to world dashboard for playing
    context.goNamed('world-dashboard', pathParameters: {'id': world.id.toString()});
  }

  // Welt-Status bestimmen
  String _getWorldStatusText() {
    final world = _world;
    if (world == null) return 'Unbekannt';
    return world.statusText;
  }

  // Welt-Status-Farbe
  Color _getWorldStatusColor() {
    final world = _world;
    if (world == null) return Colors.grey;
    
    switch (world.status) {
      case WorldStatus.upcoming:
        return Colors.orange;
      case WorldStatus.open:
        return Colors.green;
      case WorldStatus.running:
        return Colors.blue;
      case WorldStatus.closed:
        return Colors.red;
      case WorldStatus.archived:
        return Colors.grey;
    }
  }

  // Kann der Benutzer beitreten?
  // Retry-Funktion
  Future<void> _retry() async {
    await _loadWorldData();
  }

  // Navigation zu Registration mit vorausgefüllter E-Mail
  void _navigateToRegistration(String email) {
    AppLogger.app.i('🎫 Navigation zur Registration mit Invite-E-Mail', error: {'email': email});
    
    // FIXED: Invite-Token für Post-Auth-Redirect setzen
    if (widget.inviteToken != null) {
      _authService.setPendingInviteRedirect(widget.inviteToken!);
    }
    
    context.goNamed('register', queryParameters: {'email': email, 'invite_token': widget.inviteToken});
  }

  // Navigation zu Login 
  void _navigateToLogin(String email) {
    AppLogger.app.i('🎫 Navigation zum Login für Invite', error: {'email': email});
    
    // FIXED: Invite-Token für Post-Auth-Redirect setzen
    if (widget.inviteToken != null) {
      _authService.setPendingInviteRedirect(widget.inviteToken!);
    }
    
    context.goNamed('login', queryParameters: {'invite_token': widget.inviteToken});
  }

  // User abmelden und zur Registration weiterleiten
  Future<void> _logout() async {
    try {
      AppLogger.app.i('🎫 User logout für Invite-Umleitung', error: {'inviteEmail': _inviteEmail});
      
      // FIXED: Invite-Token für Post-Auth-Redirect setzen BEVOR logout
      if (widget.inviteToken != null) {
        _authService.setPendingInviteRedirect(widget.inviteToken!);
      }
      
      await _authService.logout();
      
      if (mounted && _inviteEmail != null) {
        // Nach Logout zur Registration mit korrekter E-Mail
        context.goNamed('register', queryParameters: {
          'email': _inviteEmail!,
          'invite_token': widget.inviteToken ?? ''
        });
      }
    } catch (e) {
      AppLogger.logError('Logout für Invite fehlgeschlagen', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler beim Abmelden'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: BackgroundWidget(
        child: Stack(
          children: [
            // Main content
            SafeArea(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    )
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _infoMessage != null
                          ? _buildInfoState()
                          : _world == null
                              ? _buildNotFoundState()
                              : _buildWorldContent(),
            ),
            
            // User info widget (only show when authenticated)
            if (_isAuthenticated)
              const UserInfoWidget(),
            
            // Navigation widget (only show when authenticated)
            if (_isAuthenticated)
              NavigationWidget(
                currentRoute: 'world-join',
                routeParams: {'id': widget.worldId},
                isJoinedWorld: _isJoined,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 12,
              color: const Color(0xFF1A1A1A), // Dunkle Karte
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF2A2A2A),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Fehler beim Laden',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage ?? 'Unbekannter Fehler',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Verschiedene Action-Buttons je nach Szenario
                      if (_showRegistrationButton && _inviteEmail != null) ...[
                        // Registration Button für neuen User
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => _navigateToRegistration(_inviteEmail!),
                            icon: const Icon(Icons.person_add),
                            label: const Text('Jetzt registrieren'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Login Button als Alternative
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => _navigateToLogin(_inviteEmail!),
                            icon: const Icon(Icons.login),
                            label: const Text('Bereits registriert? Anmelden'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: BorderSide(color: AppTheme.primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ] else if (_showLogoutButton && _inviteEmail != null) ...[
                        // Logout Button für falschen User
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout),
                            label: const Text('Abmelden & neu registrieren'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Abbrechen Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => context.goNamed('landing'),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Zurück zur Startseite'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey,
                              side: BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Standard Retry Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _retry,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Erneut versuchen'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.goNamed('world-list'),
                        child: const Text(
                          'Zurück zu den Welten',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 12,
              color: const Color(0xFF1A1A1A), // Dunkle Karte
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF2A2A2A),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 80,
                        color: Colors.blue[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Information',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _infoMessage ?? 'Keine Information verfügbar',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // **NEUE INTELLIGENTE BUTTONS**
                      _buildActionButtons(),
                      
                      // **INVITE-FLOWS: Kein "`
- 🔧 Context:
```dart
builder: (context) => AlertDialog(
        title: const Text('Welt verlassen?'),
        content: Text('Möchtest du die Welt "${world.name}" wirklich verlassen?'),
        actions: [
          TextButton(
```

**worldActiontypetextvaliditytextJeNach** (Confidence: 0.9)
- 📁 `lib\features\world\world_join_page.dart:281:87`
- 📝 Original: `" $actionTypeText.$validityText';
    
    // Je nach Status unterschiedliche Logik
    switch (status) {
      case 'not_logged_in':
        if (requiresAction == 'register') {
          // Mail ist unbekannt -> nur Register
          actionText = 'Du musst dich mit der E-Mail-Adresse $inviteEmail registrieren.';
          infoText = '$baseInfoText\n\n$actionText';
          showRegisterButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'user_exists_not_logged_in':
        if (requiresAction == 'login') {
          // Mail ist bekannt, User nicht angemeldet -> nur Login
          actionText = 'Dein Account mit $inviteEmail ist bereits registriert. Bitte melde dich an.';
          infoText = '$baseInfoText\n\n$actionText';
          showLoginButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'wrong_email':
        if (requiresAction == 'logout_and_register') {
          final currentUserEmail = userStatusData['currentUser']?['email'];
          // User mit falscher Mail angemeldet -> Logout + Register
          actionText = 'Diese Einladung ist für $inviteEmail bestimmt, aber du bist als $currentUserEmail angemeldet.';
          infoText = '$baseInfoText\n\n$actionText\n\nBitte melde dich ab und registriere dich mit der richtigen E-Mail-Adresse.';
          showLogoutButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'correct_email':
        if (requiresAction == 'join_world') {
          // User richtig angemeldet -> nur Accept Button (KEIN Auto-Accept!)
          actionText = 'Du bist mit der richtigen E-Mail-Adresse angemeldet und kannst die Einladung jetzt annehmen.';
          infoText = '$baseInfoText\n\n$actionText';
          showAcceptButton = isInviteValid; // Nur bei gültigen Invites
          
          // Auto-Accept entfernt: User soll bewusst entscheiden!
        }
        break;
        
      default:
        AppLogger.app.w('❌ Unbekannter User-Status: $status');
        actionText = 'Unbekannter Status: $status';
        infoText = '$baseInfoText\n\n$actionText';
    }
    
    // Bei ungültigen Invites zusätzliche Info
    if (!isInviteValid) {
      infoText += '\n\n⚠️ Diese Einladung kann nicht mehr verwendet werden.';
    }
    
    setState(() {
      _infoMessage = infoText;
      _inviteEmail = inviteEmail;
      
      // Button-Flags setzen
      _showLoginButton = showLoginButton;
      _showRegistrationButton = showRegisterButton; 
      _showLogoutButton = showLogoutButton;
      _showAcceptInviteButton = showAcceptButton;
      
      // WICHTIG: Alte Fehlermeldung zurücksetzen!
      _errorMessage = null;
      
      _isLoading = false;
    });
  }

  // Neue Methode: World-Status für normale Navigation prüfen
  Future<void> _checkWorldStatus() async {
    if (_world == null) return;
    
    try {
      // Prüfe ob User bereits Mitglied ist
      _isJoined = await _worldService.isPlayerInWorld(_world!.id);
      
      // Prüfe Vorregistrierung
      final preRegStatus = await _worldService.getPreRegistrationStatus(_world!.id);
      _isPreRegistered = preRegStatus.isPreRegistered;
      
      AppLogger.app.d('✅ World-Status geprüft', error: {
        'worldName': _world!.name,
        'isJoined': _isJoined,
        'isPreRegistered': _isPreRegistered
      });
    } catch (e) {
      AppLogger.logError('Fehler beim Prüfen des World-Status', e);
    }
  }

  // Neue Methode: Automatische Invite-Akzeptierung
  Future<void> _autoAcceptInvite() async {
    if (widget.inviteToken == null) return;
    
    try {
      final result = await _worldService.acceptInvite(widget.inviteToken!);
      
      if (result != null) {
        setState(() {
          _isJoined = true;
          _infoMessage = 'Willkommen in der Welt "`
- 🔧 Context:
```dart
}
    
    final baseInfoText = 'Du wurdest von $inviterText eingeladen, der Welt "$worldName" $actionTypeText.$validityText';
    
    // Je nach Status unterschiedliche Logik
```

**worldDasInviteWurde** (Confidence: 0.9)
- 📁 `lib\features\world\world_join_page.dart:384:66`
- 📝 Original: `"! Das Invite wurde automatisch akzeptiert.';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erfolgreich der Welt "`
- 🔧 Context:
```dart
setState(() {
          _isJoined = true;
          _infoMessage = 'Willkommen in der Welt "${_world?.name}"! Das Invite wurde automatisch akzeptiert.';
        });
```

**worldIstKeinFehler** (Confidence: 0.9)
- 📁 `lib\features\world\world_join_page.dart:398:55`
- 📝 Original: `" ist KEIN Fehler!
      if (e.toString().contains('Invite bereits akzeptiert')) {
        setState(() {
          _isJoined = true;
          _infoMessage = 'Du bist bereits Mitglied dieser Welt "`
- 🔧 Context:
```dart
}
    } catch (e) {
      // SPEZIALBEHANDLUNG: "Invite bereits akzeptiert" ist KEIN Fehler!
      if (e.toString().contains('Invite bereits akzeptiert')) {
        setState(() {
```

**worldIfMountedScaffoldmessengerofcontextshowsnackbar** (Confidence: 0.9)
- 📁 `lib\features\world\world_join_page.dart:402:80`
- 📝 Original: `"!';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Du bist bereits Mitglied der Welt "`
- 🔧 Context:
```dart
setState(() {
          _isJoined = true;
          _infoMessage = 'Du bist bereits Mitglied dieser Welt "${_world?.name}"!';
        });
```

**worldBackgroundcolorColorsorangeDuration** (Confidence: 0.9)
- 📁 `lib\features\world\world_join_page.dart:408:80`
- 📝 Original: `"!'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return; // Erfolgreicher Exit
      }
      
      // Andere Fehler normal behandeln
      AppLogger.logError('Automatische Invite-Akzeptierung fehlgeschlagen', e);
      // Fehler nicht als kritisch behandeln - User kann manuell beitreten
      setState(() {
        _infoMessage = 'Du kannst nun der Welt beitreten.';
      });
    }
  }

  Future<void> _joinWorld() async {
    if (_world == null) return;

    setState(() {
      _isJoining = true;
      _joinError = null;
    });

    try {
      bool success = false;
      
      // **INVITE-TOKEN FLOW: Invite akzeptieren**
      if (widget.inviteToken != null) {
        AppLogger.app.i('🎫 Versuche Invite-Akzeptierung für World-Join');
        final inviteResult = await _worldService.acceptInvite(widget.inviteToken!);
        
        if (inviteResult != null) {
          success = true;
          AppLogger.app.i('✅ Invite erfolgreich akzeptiert', error: {
            'worldId': _world!.id,
            'worldName': _world!.name
          });
        }
      } else {
        // **NORMALE NAVIGATION: Standard World-Join**
        AppLogger.app.i('🌍 Versuche normalen World-Join');
        success = await _worldService.joinWorld(_world!.id);
      }
      
      if (success) {
        setState(() {
          _isJoined = true;
        });
        
        if (mounted) {
          final message = widget.inviteToken != null 
            ? 'Einladung akzeptiert! Willkommen in der Welt "`
- 🔧 Context:
```dart
ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Du bist bereits Mitglied der Welt "${_world?.name}"!'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
```

**worldErfolgreichDerWelt** (Confidence: 0.9)
- 📁 `lib\features\world\world_join_page.dart:462:77`
- 📝 Original: `"!'
            : 'Erfolgreich der Welt "`
- 🔧 Context:
```dart
if (mounted) {
          final message = widget.inviteToken != null 
            ? 'Einladung akzeptiert! Willkommen in der Welt "${_world!.name}"!'
            : 'Erfolgreich der Welt "${_world!.name}" beigetreten!';
```

**worldBeigetretenScaffoldmessengerofcontextshowsnackbarSnackbar** (Confidence: 0.9)
- 📁 `lib\features\world\world_join_page.dart:463:53`
- 📝 Original: `" beigetreten!';
            
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() {
          _joinError = 'Beitritt fehlgeschlagen. Versuche es erneut.';
        });
      }
    } catch (e) {
      AppLogger.logError('World Join fehlgeschlagen', e, context: {
        'worldId': _world?.id,
        'worldName': _world?.name,
        'hasInviteToken': widget.inviteToken != null,
        'inviteToken': widget.inviteToken?.substring(0, 8)
      });
      
      setState(() {
        // Bessere Fehlermeldungen für verschiedene Szenarien
        if (e.toString().contains('bereits akzeptiert')) {
          _joinError = 'Diese Einladung wurde bereits akzeptiert.';
          _isJoined = true; // User ist bereits Mitglied
        } else if (e.toString().contains('nicht für deine E-Mail-Adresse')) {
          _joinError = 'Diese Einladung ist nicht für deine E-Mail-Adresse bestimmt.';
        } else if (e.toString().contains('abgelaufen')) {
          _joinError = 'Diese Einladung ist abgelaufen.';
        } else {
          _joinError = 'Ein Fehler ist aufgetreten: ${e.toString().replaceAll('Exception: ', '')}';
        }
      });
    } finally {
      setState(() {
        _isJoining = false;
      });
    }
  }
  
  Future<void> _preRegisterWorld() async {
    final world = _world;
    if (world == null) return;

    setState(() {
      _isPreRegistering = true;
      _joinError = null;
    });

    try {
      final success = await _worldService.preRegisterWorldAuthenticated(world.id);
      
      if (success) {
        setState(() {
          _isPreRegistered = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erfolgreich für ${world.name} vorregistriert!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _joinError = 'Fehler bei der Vorregistrierung';
        });
      }
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPreRegistering = false;
        });
      }
    }
  }
  
  Future<void> _cancelPreRegistration() async {
    final world = _world;
    if (world == null) return;

    setState(() {
      _isPreRegistering = true;
      _joinError = null;
    });

    try {
      final success = await _worldService.cancelPreRegistrationAuthenticated(world.id);
      if (success) {
        setState(() {
          _isPreRegistered = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vorregistrierung für ${world.name} zurückgezogen.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        setState(() {
          _joinError = 'Fehler beim Zurückziehen der Vorregistrierung';
        });
      }
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPreRegistering = false;
        });
      }
    }
  }
  
  Future<void> _leaveWorld() async {
    final world = _world;
    if (world == null) return;
    
    // Bestätigungsdialog anzeigen
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Welt verlassen?'),
        content: Text('Möchtest du die Welt "`
- 🔧 Context:
```dart
final message = widget.inviteToken != null 
            ? 'Einladung akzeptiert! Willkommen in der Welt "${_world!.name}"!'
            : 'Erfolgreich der Welt "${_world!.name}" beigetreten!';
            
          ScaffoldMessenger.of(context).showSnackBar(
```

**worldWirklichVerlassenActions** (Confidence: 0.9)
- 📁 `lib\features\world\world_join_page.dart:600:59`
- 📝 Original: `" wirklich verlassen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Verlassen'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;

    setState(() {
      _isJoining = true;
      _joinError = null;
    });

    try {
      await _worldService.leaveWorld(world.id);
      setState(() {
        _isJoined = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Du hast ${world.name} verlassen.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }
  
  void _playWorld() {
    final world = _world;
    if (world == null) return;
    // Navigate directly to world dashboard for playing
    context.goNamed('world-dashboard', pathParameters: {'id': world.id.toString()});
  }

  // Welt-Status bestimmen
  String _getWorldStatusText() {
    final world = _world;
    if (world == null) return 'Unbekannt';
    return world.statusText;
  }

  // Welt-Status-Farbe
  Color _getWorldStatusColor() {
    final world = _world;
    if (world == null) return Colors.grey;
    
    switch (world.status) {
      case WorldStatus.upcoming:
        return Colors.orange;
      case WorldStatus.open:
        return Colors.green;
      case WorldStatus.running:
        return Colors.blue;
      case WorldStatus.closed:
        return Colors.red;
      case WorldStatus.archived:
        return Colors.grey;
    }
  }

  // Kann der Benutzer beitreten?
  // Retry-Funktion
  Future<void> _retry() async {
    await _loadWorldData();
  }

  // Navigation zu Registration mit vorausgefüllter E-Mail
  void _navigateToRegistration(String email) {
    AppLogger.app.i('🎫 Navigation zur Registration mit Invite-E-Mail', error: {'email': email});
    
    // FIXED: Invite-Token für Post-Auth-Redirect setzen
    if (widget.inviteToken != null) {
      _authService.setPendingInviteRedirect(widget.inviteToken!);
    }
    
    context.goNamed('register', queryParameters: {'email': email, 'invite_token': widget.inviteToken});
  }

  // Navigation zu Login 
  void _navigateToLogin(String email) {
    AppLogger.app.i('🎫 Navigation zum Login für Invite', error: {'email': email});
    
    // FIXED: Invite-Token für Post-Auth-Redirect setzen
    if (widget.inviteToken != null) {
      _authService.setPendingInviteRedirect(widget.inviteToken!);
    }
    
    context.goNamed('login', queryParameters: {'invite_token': widget.inviteToken});
  }

  // User abmelden und zur Registration weiterleiten
  Future<void> _logout() async {
    try {
      AppLogger.app.i('🎫 User logout für Invite-Umleitung', error: {'inviteEmail': _inviteEmail});
      
      // FIXED: Invite-Token für Post-Auth-Redirect setzen BEVOR logout
      if (widget.inviteToken != null) {
        _authService.setPendingInviteRedirect(widget.inviteToken!);
      }
      
      await _authService.logout();
      
      if (mounted && _inviteEmail != null) {
        // Nach Logout zur Registration mit korrekter E-Mail
        context.goNamed('register', queryParameters: {
          'email': _inviteEmail!,
          'invite_token': widget.inviteToken ?? ''
        });
      }
    } catch (e) {
      AppLogger.logError('Logout für Invite fehlgeschlagen', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler beim Abmelden'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: BackgroundWidget(
        child: Stack(
          children: [
            // Main content
            SafeArea(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    )
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _infoMessage != null
                          ? _buildInfoState()
                          : _world == null
                              ? _buildNotFoundState()
                              : _buildWorldContent(),
            ),
            
            // User info widget (only show when authenticated)
            if (_isAuthenticated)
              const UserInfoWidget(),
            
            // Navigation widget (only show when authenticated)
            if (_isAuthenticated)
              NavigationWidget(
                currentRoute: 'world-join',
                routeParams: {'id': widget.worldId},
                isJoinedWorld: _isJoined,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 12,
              color: const Color(0xFF1A1A1A), // Dunkle Karte
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF2A2A2A),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Fehler beim Laden',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage ?? 'Unbekannter Fehler',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Verschiedene Action-Buttons je nach Szenario
                      if (_showRegistrationButton && _inviteEmail != null) ...[
                        // Registration Button für neuen User
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => _navigateToRegistration(_inviteEmail!),
                            icon: const Icon(Icons.person_add),
                            label: const Text('Jetzt registrieren'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Login Button als Alternative
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => _navigateToLogin(_inviteEmail!),
                            icon: const Icon(Icons.login),
                            label: const Text('Bereits registriert? Anmelden'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: BorderSide(color: AppTheme.primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ] else if (_showLogoutButton && _inviteEmail != null) ...[
                        // Logout Button für falschen User
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout),
                            label: const Text('Abmelden & neu registrieren'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Abbrechen Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => context.goNamed('landing'),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Zurück zur Startseite'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey,
                              side: BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Standard Retry Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _retry,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Erneut versuchen'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.goNamed('world-list'),
                        child: const Text(
                          'Zurück zu den Welten',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 12,
              color: const Color(0xFF1A1A1A), // Dunkle Karte
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF2A2A2A),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 80,
                        color: Colors.blue[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Information',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _infoMessage ?? 'Keine Information verfügbar',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // **NEUE INTELLIGENTE BUTTONS**
                      _buildActionButtons(),
                      
                      // **INVITE-FLOWS: Kein "`
- 🔧 Context:
```dart
builder: (context) => AlertDialog(
        title: const Text('Welt verlassen?'),
        content: Text('Möchtest du die Welt "${world.name}" wirklich verlassen?'),
        actions: [
          TextButton(
```

**worldActiontypetextvaliditytextJeNach** (Confidence: 0.8)
- 📁 `lib\features\world\world_join_page.dart:281:87`
- 📝 Original: `" $actionTypeText.$validityText';
    
    // Je nach Status unterschiedliche Logik
    switch (status) {
      case 'not_logged_in':
        if (requiresAction == 'register') {
          // Mail ist unbekannt -> nur Register
          actionText = 'Du musst dich mit der E-Mail-Adresse $inviteEmail registrieren.';
          infoText = '$baseInfoText\n\n$actionText';
          showRegisterButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'user_exists_not_logged_in':
        if (requiresAction == 'login') {
          // Mail ist bekannt, User nicht angemeldet -> nur Login
          actionText = 'Dein Account mit $inviteEmail ist bereits registriert. Bitte melde dich an.';
          infoText = '$baseInfoText\n\n$actionText';
          showLoginButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'wrong_email':
        if (requiresAction == 'logout_and_register') {
          final currentUserEmail = userStatusData['currentUser']?['email'];
          // User mit falscher Mail angemeldet -> Logout + Register
          actionText = 'Diese Einladung ist für $inviteEmail bestimmt, aber du bist als $currentUserEmail angemeldet.';
          infoText = '$baseInfoText\n\n$actionText\n\nBitte melde dich ab und registriere dich mit der richtigen E-Mail-Adresse.';
          showLogoutButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'correct_email':
        if (requiresAction == 'join_world') {
          // User richtig angemeldet -> nur Accept Button (KEIN Auto-Accept!)
          actionText = 'Du bist mit der richtigen E-Mail-Adresse angemeldet und kannst die Einladung jetzt annehmen.';
          infoText = '$baseInfoText\n\n$actionText';
          showAcceptButton = isInviteValid; // Nur bei gültigen Invites
          
          // Auto-Accept entfernt: User soll bewusst entscheiden!
        }
        break;
        
      default:
        AppLogger.app.w('❌ Unbekannter User-Status: $status');
        actionText = 'Unbekannter Status: $status';
        infoText = '$baseInfoText\n\n$actionText';
    }
    
    // Bei ungültigen Invites zusätzliche Info
    if (!isInviteValid) {
      infoText += '\n\n⚠️ Diese Einladung kann nicht mehr verwendet werden.';
    }
    
    setState(() {
      _infoMessage = infoText;
      _inviteEmail = inviteEmail;
      
      // Button-Flags setzen
      _showLoginButton = showLoginButton;
      _showRegistrationButton = showRegisterButton; 
      _showLogoutButton = showLogoutButton;
      _showAcceptInviteButton = showAcceptButton;
      
      // WICHTIG: Alte Fehlermeldung zurücksetzen!
      _errorMessage = null;
      
      _isLoading = false;
    });
  }

  // Neue Methode: World-Status für normale Navigation prüfen
  Future<void> _checkWorldStatus() async {
    if (_world == null) return;
    
    try {
      // Prüfe ob User bereits Mitglied ist
      _isJoined = await _worldService.isPlayerInWorld(_world!.id);
      
      // Prüfe Vorregistrierung
      final preRegStatus = await _worldService.getPreRegistrationStatus(_world!.id);
      _isPreRegistered = preRegStatus.isPreRegistered;
      
      AppLogger.app.d('✅ World-Status geprüft', error: {
        'worldName': _world!.name,
        'isJoined': _isJoined,
        'isPreRegistered': _isPreRegistered
      });
    } catch (e) {
      AppLogger.logError('Fehler beim Prüfen des World-Status', e);
    }
  }

  // Neue Methode: Automatische Invite-Akzeptierung
  Future<void> _autoAcceptInvite() async {
    if (widget.inviteToken == null) return;
    
    try {
      final result = await _worldService.acceptInvite(widget.inviteToken!);
      
      if (result != null) {
        setState(() {
          _isJoined = true;
          _infoMessage = 'Willkommen in der Welt "`
- 🔧 Context:
```dart
}
    
    final baseInfoText = 'Du wurdest von $inviterText eingeladen, der Welt "$worldName" $actionTypeText.$validityText';
    
    // Je nach Status unterschiedliche Logik
```

**worldDasInviteWurde** (Confidence: 0.8)
- 📁 `lib\features\world\world_join_page.dart:384:66`
- 📝 Original: `"! Das Invite wurde automatisch akzeptiert.';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erfolgreich der Welt "`
- 🔧 Context:
```dart
setState(() {
          _isJoined = true;
          _infoMessage = 'Willkommen in der Welt "${_world?.name}"! Das Invite wurde automatisch akzeptiert.';
        });
```

**worldIstKeinFehler** (Confidence: 0.8)
- 📁 `lib\features\world\world_join_page.dart:398:55`
- 📝 Original: `" ist KEIN Fehler!
      if (e.toString().contains('Invite bereits akzeptiert')) {
        setState(() {
          _isJoined = true;
          _infoMessage = 'Du bist bereits Mitglied dieser Welt "`
- 🔧 Context:
```dart
}
    } catch (e) {
      // SPEZIALBEHANDLUNG: "Invite bereits akzeptiert" ist KEIN Fehler!
      if (e.toString().contains('Invite bereits akzeptiert')) {
        setState(() {
```

**worldBackgroundcolorColorsorangeDuration** (Confidence: 0.8)
- 📁 `lib\features\world\world_join_page.dart:408:80`
- 📝 Original: `"!'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return; // Erfolgreicher Exit
      }
      
      // Andere Fehler normal behandeln
      AppLogger.logError('Automatische Invite-Akzeptierung fehlgeschlagen', e);
      // Fehler nicht als kritisch behandeln - User kann manuell beitreten
      setState(() {
        _infoMessage = 'Du kannst nun der Welt beitreten.';
      });
    }
  }

  Future<void> _joinWorld() async {
    if (_world == null) return;

    setState(() {
      _isJoining = true;
      _joinError = null;
    });

    try {
      bool success = false;
      
      // **INVITE-TOKEN FLOW: Invite akzeptieren**
      if (widget.inviteToken != null) {
        AppLogger.app.i('🎫 Versuche Invite-Akzeptierung für World-Join');
        final inviteResult = await _worldService.acceptInvite(widget.inviteToken!);
        
        if (inviteResult != null) {
          success = true;
          AppLogger.app.i('✅ Invite erfolgreich akzeptiert', error: {
            'worldId': _world!.id,
            'worldName': _world!.name
          });
        }
      } else {
        // **NORMALE NAVIGATION: Standard World-Join**
        AppLogger.app.i('🌍 Versuche normalen World-Join');
        success = await _worldService.joinWorld(_world!.id);
      }
      
      if (success) {
        setState(() {
          _isJoined = true;
        });
        
        if (mounted) {
          final message = widget.inviteToken != null 
            ? 'Einladung akzeptiert! Willkommen in der Welt "`
- 🔧 Context:
```dart
ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Du bist bereits Mitglied der Welt "${_world?.name}"!'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
```

**worldErfolgreichDerWelt** (Confidence: 0.8)
- 📁 `lib\features\world\world_join_page.dart:462:77`
- 📝 Original: `"!'
            : 'Erfolgreich der Welt "`
- 🔧 Context:
```dart
if (mounted) {
          final message = widget.inviteToken != null 
            ? 'Einladung akzeptiert! Willkommen in der Welt "${_world!.name}"!'
            : 'Erfolgreich der Welt "${_world!.name}" beigetreten!';
```

**worldBeigetretenScaffoldmessengerofcontextshowsnackbarSnackbar** (Confidence: 0.8)
- 📁 `lib\features\world\world_join_page.dart:463:53`
- 📝 Original: `" beigetreten!';
            
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() {
          _joinError = 'Beitritt fehlgeschlagen. Versuche es erneut.';
        });
      }
    } catch (e) {
      AppLogger.logError('World Join fehlgeschlagen', e, context: {
        'worldId': _world?.id,
        'worldName': _world?.name,
        'hasInviteToken': widget.inviteToken != null,
        'inviteToken': widget.inviteToken?.substring(0, 8)
      });
      
      setState(() {
        // Bessere Fehlermeldungen für verschiedene Szenarien
        if (e.toString().contains('bereits akzeptiert')) {
          _joinError = 'Diese Einladung wurde bereits akzeptiert.';
          _isJoined = true; // User ist bereits Mitglied
        } else if (e.toString().contains('nicht für deine E-Mail-Adresse')) {
          _joinError = 'Diese Einladung ist nicht für deine E-Mail-Adresse bestimmt.';
        } else if (e.toString().contains('abgelaufen')) {
          _joinError = 'Diese Einladung ist abgelaufen.';
        } else {
          _joinError = 'Ein Fehler ist aufgetreten: ${e.toString().replaceAll('Exception: ', '')}';
        }
      });
    } finally {
      setState(() {
        _isJoining = false;
      });
    }
  }
  
  Future<void> _preRegisterWorld() async {
    final world = _world;
    if (world == null) return;

    setState(() {
      _isPreRegistering = true;
      _joinError = null;
    });

    try {
      final success = await _worldService.preRegisterWorldAuthenticated(world.id);
      
      if (success) {
        setState(() {
          _isPreRegistered = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erfolgreich für ${world.name} vorregistriert!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _joinError = 'Fehler bei der Vorregistrierung';
        });
      }
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPreRegistering = false;
        });
      }
    }
  }
  
  Future<void> _cancelPreRegistration() async {
    final world = _world;
    if (world == null) return;

    setState(() {
      _isPreRegistering = true;
      _joinError = null;
    });

    try {
      final success = await _worldService.cancelPreRegistrationAuthenticated(world.id);
      if (success) {
        setState(() {
          _isPreRegistered = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vorregistrierung für ${world.name} zurückgezogen.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        setState(() {
          _joinError = 'Fehler beim Zurückziehen der Vorregistrierung';
        });
      }
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPreRegistering = false;
        });
      }
    }
  }
  
  Future<void> _leaveWorld() async {
    final world = _world;
    if (world == null) return;
    
    // Bestätigungsdialog anzeigen
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Welt verlassen?'),
        content: Text('Möchtest du die Welt "`
- 🔧 Context:
```dart
final message = widget.inviteToken != null 
            ? 'Einladung akzeptiert! Willkommen in der Welt "${_world!.name}"!'
            : 'Erfolgreich der Welt "${_world!.name}" beigetreten!';
            
          ScaffoldMessenger.of(context).showSnackBar(
```

**worldWirklichVerlassenActions** (Confidence: 0.8)
- 📁 `lib\features\world\world_join_page.dart:600:59`
- 📝 Original: `" wirklich verlassen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Verlassen'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;

    setState(() {
      _isJoining = true;
      _joinError = null;
    });

    try {
      await _worldService.leaveWorld(world.id);
      setState(() {
        _isJoined = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Du hast ${world.name} verlassen.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }
  
  void _playWorld() {
    final world = _world;
    if (world == null) return;
    // Navigate directly to world dashboard for playing
    context.goNamed('world-dashboard', pathParameters: {'id': world.id.toString()});
  }

  // Welt-Status bestimmen
  String _getWorldStatusText() {
    final world = _world;
    if (world == null) return 'Unbekannt';
    return world.statusText;
  }

  // Welt-Status-Farbe
  Color _getWorldStatusColor() {
    final world = _world;
    if (world == null) return Colors.grey;
    
    switch (world.status) {
      case WorldStatus.upcoming:
        return Colors.orange;
      case WorldStatus.open:
        return Colors.green;
      case WorldStatus.running:
        return Colors.blue;
      case WorldStatus.closed:
        return Colors.red;
      case WorldStatus.archived:
        return Colors.grey;
    }
  }

  // Kann der Benutzer beitreten?
  // Retry-Funktion
  Future<void> _retry() async {
    await _loadWorldData();
  }

  // Navigation zu Registration mit vorausgefüllter E-Mail
  void _navigateToRegistration(String email) {
    AppLogger.app.i('🎫 Navigation zur Registration mit Invite-E-Mail', error: {'email': email});
    
    // FIXED: Invite-Token für Post-Auth-Redirect setzen
    if (widget.inviteToken != null) {
      _authService.setPendingInviteRedirect(widget.inviteToken!);
    }
    
    context.goNamed('register', queryParameters: {'email': email, 'invite_token': widget.inviteToken});
  }

  // Navigation zu Login 
  void _navigateToLogin(String email) {
    AppLogger.app.i('🎫 Navigation zum Login für Invite', error: {'email': email});
    
    // FIXED: Invite-Token für Post-Auth-Redirect setzen
    if (widget.inviteToken != null) {
      _authService.setPendingInviteRedirect(widget.inviteToken!);
    }
    
    context.goNamed('login', queryParameters: {'invite_token': widget.inviteToken});
  }

  // User abmelden und zur Registration weiterleiten
  Future<void> _logout() async {
    try {
      AppLogger.app.i('🎫 User logout für Invite-Umleitung', error: {'inviteEmail': _inviteEmail});
      
      // FIXED: Invite-Token für Post-Auth-Redirect setzen BEVOR logout
      if (widget.inviteToken != null) {
        _authService.setPendingInviteRedirect(widget.inviteToken!);
      }
      
      await _authService.logout();
      
      if (mounted && _inviteEmail != null) {
        // Nach Logout zur Registration mit korrekter E-Mail
        context.goNamed('register', queryParameters: {
          'email': _inviteEmail!,
          'invite_token': widget.inviteToken ?? ''
        });
      }
    } catch (e) {
      AppLogger.logError('Logout für Invite fehlgeschlagen', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler beim Abmelden'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: BackgroundWidget(
        child: Stack(
          children: [
            // Main content
            SafeArea(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    )
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _infoMessage != null
                          ? _buildInfoState()
                          : _world == null
                              ? _buildNotFoundState()
                              : _buildWorldContent(),
            ),
            
            // User info widget (only show when authenticated)
            if (_isAuthenticated)
              const UserInfoWidget(),
            
            // Navigation widget (only show when authenticated)
            if (_isAuthenticated)
              NavigationWidget(
                currentRoute: 'world-join',
                routeParams: {'id': widget.worldId},
                isJoinedWorld: _isJoined,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 12,
              color: const Color(0xFF1A1A1A), // Dunkle Karte
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF2A2A2A),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Fehler beim Laden',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage ?? 'Unbekannter Fehler',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Verschiedene Action-Buttons je nach Szenario
                      if (_showRegistrationButton && _inviteEmail != null) ...[
                        // Registration Button für neuen User
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => _navigateToRegistration(_inviteEmail!),
                            icon: const Icon(Icons.person_add),
                            label: const Text('Jetzt registrieren'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Login Button als Alternative
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => _navigateToLogin(_inviteEmail!),
                            icon: const Icon(Icons.login),
                            label: const Text('Bereits registriert? Anmelden'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: BorderSide(color: AppTheme.primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ] else if (_showLogoutButton && _inviteEmail != null) ...[
                        // Logout Button für falschen User
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout),
                            label: const Text('Abmelden & neu registrieren'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Abbrechen Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => context.goNamed('landing'),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Zurück zur Startseite'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey,
                              side: BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Standard Retry Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _retry,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Erneut versuchen'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.goNamed('world-list'),
                        child: const Text(
                          'Zurück zu den Welten',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 12,
              color: const Color(0xFF1A1A1A), // Dunkle Karte
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF2A2A2A),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 80,
                        color: Colors.blue[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Information',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _infoMessage ?? 'Keine Information verfügbar',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // **NEUE INTELLIGENTE BUTTONS**
                      _buildActionButtons(),
                      
                      // **INVITE-FLOWS: Kein "`
- 🔧 Context:
```dart
builder: (context) => AlertDialog(
        title: const Text('Welt verlassen?'),
        content: Text('Möchtest du die Welt "${world.name}" wirklich verlassen?'),
        actions: [
          TextButton(
```

**worldActiontypetextvaliditytextJeNach** (Confidence: 0.8)
- 📁 `lib\features\world\world_join_page.dart:281:87`
- 📝 Original: `" $actionTypeText.$validityText';
    
    // Je nach Status unterschiedliche Logik
    switch (status) {
      case 'not_logged_in':
        if (requiresAction == 'register') {
          // Mail ist unbekannt -> nur Register
          actionText = 'Du musst dich mit der E-Mail-Adresse $inviteEmail registrieren.';
          infoText = '$baseInfoText\n\n$actionText';
          showRegisterButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'user_exists_not_logged_in':
        if (requiresAction == 'login') {
          // Mail ist bekannt, User nicht angemeldet -> nur Login
          actionText = 'Dein Account mit $inviteEmail ist bereits registriert. Bitte melde dich an.';
          infoText = '$baseInfoText\n\n$actionText';
          showLoginButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'wrong_email':
        if (requiresAction == 'logout_and_register') {
          final currentUserEmail = userStatusData['currentUser']?['email'];
          // User mit falscher Mail angemeldet -> Logout + Register
          actionText = 'Diese Einladung ist für $inviteEmail bestimmt, aber du bist als $currentUserEmail angemeldet.';
          infoText = '$baseInfoText\n\n$actionText\n\nBitte melde dich ab und registriere dich mit der richtigen E-Mail-Adresse.';
          showLogoutButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'correct_email':
        if (requiresAction == 'join_world') {
          // User richtig angemeldet -> nur Accept Button (KEIN Auto-Accept!)
          actionText = 'Du bist mit der richtigen E-Mail-Adresse angemeldet und kannst die Einladung jetzt annehmen.';
          infoText = '$baseInfoText\n\n$actionText';
          showAcceptButton = isInviteValid; // Nur bei gültigen Invites
          
          // Auto-Accept entfernt: User soll bewusst entscheiden!
        }
        break;
        
      default:
        AppLogger.app.w('❌ Unbekannter User-Status: $status');
        actionText = 'Unbekannter Status: $status';
        infoText = '$baseInfoText\n\n$actionText';
    }
    
    // Bei ungültigen Invites zusätzliche Info
    if (!isInviteValid) {
      infoText += '\n\n⚠️ Diese Einladung kann nicht mehr verwendet werden.';
    }
    
    setState(() {
      _infoMessage = infoText;
      _inviteEmail = inviteEmail;
      
      // Button-Flags setzen
      _showLoginButton = showLoginButton;
      _showRegistrationButton = showRegisterButton; 
      _showLogoutButton = showLogoutButton;
      _showAcceptInviteButton = showAcceptButton;
      
      // WICHTIG: Alte Fehlermeldung zurücksetzen!
      _errorMessage = null;
      
      _isLoading = false;
    });
  }

  // Neue Methode: World-Status für normale Navigation prüfen
  Future<void> _checkWorldStatus() async {
    if (_world == null) return;
    
    try {
      // Prüfe ob User bereits Mitglied ist
      _isJoined = await _worldService.isPlayerInWorld(_world!.id);
      
      // Prüfe Vorregistrierung
      final preRegStatus = await _worldService.getPreRegistrationStatus(_world!.id);
      _isPreRegistered = preRegStatus.isPreRegistered;
      
      AppLogger.app.d('✅ World-Status geprüft', error: {
        'worldName': _world!.name,
        'isJoined': _isJoined,
        'isPreRegistered': _isPreRegistered
      });
    } catch (e) {
      AppLogger.logError('Fehler beim Prüfen des World-Status', e);
    }
  }

  // Neue Methode: Automatische Invite-Akzeptierung
  Future<void> _autoAcceptInvite() async {
    if (widget.inviteToken == null) return;
    
    try {
      final result = await _worldService.acceptInvite(widget.inviteToken!);
      
      if (result != null) {
        setState(() {
          _isJoined = true;
          _infoMessage = 'Willkommen in der Welt "`
- 🔧 Context:
```dart
}
    
    final baseInfoText = 'Du wurdest von $inviterText eingeladen, der Welt "$worldName" $actionTypeText.$validityText';
    
    // Je nach Status unterschiedliche Logik
```

**worldBackgroundcolorColorsorangeDuration** (Confidence: 0.8)
- 📁 `lib\features\world\world_join_page.dart:408:80`
- 📝 Original: `"!'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return; // Erfolgreicher Exit
      }
      
      // Andere Fehler normal behandeln
      AppLogger.logError('Automatische Invite-Akzeptierung fehlgeschlagen', e);
      // Fehler nicht als kritisch behandeln - User kann manuell beitreten
      setState(() {
        _infoMessage = 'Du kannst nun der Welt beitreten.';
      });
    }
  }

  Future<void> _joinWorld() async {
    if (_world == null) return;

    setState(() {
      _isJoining = true;
      _joinError = null;
    });

    try {
      bool success = false;
      
      // **INVITE-TOKEN FLOW: Invite akzeptieren**
      if (widget.inviteToken != null) {
        AppLogger.app.i('🎫 Versuche Invite-Akzeptierung für World-Join');
        final inviteResult = await _worldService.acceptInvite(widget.inviteToken!);
        
        if (inviteResult != null) {
          success = true;
          AppLogger.app.i('✅ Invite erfolgreich akzeptiert', error: {
            'worldId': _world!.id,
            'worldName': _world!.name
          });
        }
      } else {
        // **NORMALE NAVIGATION: Standard World-Join**
        AppLogger.app.i('🌍 Versuche normalen World-Join');
        success = await _worldService.joinWorld(_world!.id);
      }
      
      if (success) {
        setState(() {
          _isJoined = true;
        });
        
        if (mounted) {
          final message = widget.inviteToken != null 
            ? 'Einladung akzeptiert! Willkommen in der Welt "`
- 🔧 Context:
```dart
ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Du bist bereits Mitglied der Welt "${_world?.name}"!'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
```

**worldBeigetretenScaffoldmessengerofcontextshowsnackbarSnackbar** (Confidence: 0.8)
- 📁 `lib\features\world\world_join_page.dart:463:53`
- 📝 Original: `" beigetreten!';
            
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() {
          _joinError = 'Beitritt fehlgeschlagen. Versuche es erneut.';
        });
      }
    } catch (e) {
      AppLogger.logError('World Join fehlgeschlagen', e, context: {
        'worldId': _world?.id,
        'worldName': _world?.name,
        'hasInviteToken': widget.inviteToken != null,
        'inviteToken': widget.inviteToken?.substring(0, 8)
      });
      
      setState(() {
        // Bessere Fehlermeldungen für verschiedene Szenarien
        if (e.toString().contains('bereits akzeptiert')) {
          _joinError = 'Diese Einladung wurde bereits akzeptiert.';
          _isJoined = true; // User ist bereits Mitglied
        } else if (e.toString().contains('nicht für deine E-Mail-Adresse')) {
          _joinError = 'Diese Einladung ist nicht für deine E-Mail-Adresse bestimmt.';
        } else if (e.toString().contains('abgelaufen')) {
          _joinError = 'Diese Einladung ist abgelaufen.';
        } else {
          _joinError = 'Ein Fehler ist aufgetreten: ${e.toString().replaceAll('Exception: ', '')}';
        }
      });
    } finally {
      setState(() {
        _isJoining = false;
      });
    }
  }
  
  Future<void> _preRegisterWorld() async {
    final world = _world;
    if (world == null) return;

    setState(() {
      _isPreRegistering = true;
      _joinError = null;
    });

    try {
      final success = await _worldService.preRegisterWorldAuthenticated(world.id);
      
      if (success) {
        setState(() {
          _isPreRegistered = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erfolgreich für ${world.name} vorregistriert!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _joinError = 'Fehler bei der Vorregistrierung';
        });
      }
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPreRegistering = false;
        });
      }
    }
  }
  
  Future<void> _cancelPreRegistration() async {
    final world = _world;
    if (world == null) return;

    setState(() {
      _isPreRegistering = true;
      _joinError = null;
    });

    try {
      final success = await _worldService.cancelPreRegistrationAuthenticated(world.id);
      if (success) {
        setState(() {
          _isPreRegistered = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vorregistrierung für ${world.name} zurückgezogen.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        setState(() {
          _joinError = 'Fehler beim Zurückziehen der Vorregistrierung';
        });
      }
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPreRegistering = false;
        });
      }
    }
  }
  
  Future<void> _leaveWorld() async {
    final world = _world;
    if (world == null) return;
    
    // Bestätigungsdialog anzeigen
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Welt verlassen?'),
        content: Text('Möchtest du die Welt "`
- 🔧 Context:
```dart
final message = widget.inviteToken != null 
            ? 'Einladung akzeptiert! Willkommen in der Welt "${_world!.name}"!'
            : 'Erfolgreich der Welt "${_world!.name}" beigetreten!';
            
          ScaffoldMessenger.of(context).showSnackBar(
```

**worldWirklichVerlassenActions** (Confidence: 0.8)
- 📁 `lib\features\world\world_join_page.dart:600:59`
- 📝 Original: `" wirklich verlassen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Verlassen'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;

    setState(() {
      _isJoining = true;
      _joinError = null;
    });

    try {
      await _worldService.leaveWorld(world.id);
      setState(() {
        _isJoined = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Du hast ${world.name} verlassen.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }
  
  void _playWorld() {
    final world = _world;
    if (world == null) return;
    // Navigate directly to world dashboard for playing
    context.goNamed('world-dashboard', pathParameters: {'id': world.id.toString()});
  }

  // Welt-Status bestimmen
  String _getWorldStatusText() {
    final world = _world;
    if (world == null) return 'Unbekannt';
    return world.statusText;
  }

  // Welt-Status-Farbe
  Color _getWorldStatusColor() {
    final world = _world;
    if (world == null) return Colors.grey;
    
    switch (world.status) {
      case WorldStatus.upcoming:
        return Colors.orange;
      case WorldStatus.open:
        return Colors.green;
      case WorldStatus.running:
        return Colors.blue;
      case WorldStatus.closed:
        return Colors.red;
      case WorldStatus.archived:
        return Colors.grey;
    }
  }

  // Kann der Benutzer beitreten?
  // Retry-Funktion
  Future<void> _retry() async {
    await _loadWorldData();
  }

  // Navigation zu Registration mit vorausgefüllter E-Mail
  void _navigateToRegistration(String email) {
    AppLogger.app.i('🎫 Navigation zur Registration mit Invite-E-Mail', error: {'email': email});
    
    // FIXED: Invite-Token für Post-Auth-Redirect setzen
    if (widget.inviteToken != null) {
      _authService.setPendingInviteRedirect(widget.inviteToken!);
    }
    
    context.goNamed('register', queryParameters: {'email': email, 'invite_token': widget.inviteToken});
  }

  // Navigation zu Login 
  void _navigateToLogin(String email) {
    AppLogger.app.i('🎫 Navigation zum Login für Invite', error: {'email': email});
    
    // FIXED: Invite-Token für Post-Auth-Redirect setzen
    if (widget.inviteToken != null) {
      _authService.setPendingInviteRedirect(widget.inviteToken!);
    }
    
    context.goNamed('login', queryParameters: {'invite_token': widget.inviteToken});
  }

  // User abmelden und zur Registration weiterleiten
  Future<void> _logout() async {
    try {
      AppLogger.app.i('🎫 User logout für Invite-Umleitung', error: {'inviteEmail': _inviteEmail});
      
      // FIXED: Invite-Token für Post-Auth-Redirect setzen BEVOR logout
      if (widget.inviteToken != null) {
        _authService.setPendingInviteRedirect(widget.inviteToken!);
      }
      
      await _authService.logout();
      
      if (mounted && _inviteEmail != null) {
        // Nach Logout zur Registration mit korrekter E-Mail
        context.goNamed('register', queryParameters: {
          'email': _inviteEmail!,
          'invite_token': widget.inviteToken ?? ''
        });
      }
    } catch (e) {
      AppLogger.logError('Logout für Invite fehlgeschlagen', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler beim Abmelden'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: BackgroundWidget(
        child: Stack(
          children: [
            // Main content
            SafeArea(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    )
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _infoMessage != null
                          ? _buildInfoState()
                          : _world == null
                              ? _buildNotFoundState()
                              : _buildWorldContent(),
            ),
            
            // User info widget (only show when authenticated)
            if (_isAuthenticated)
              const UserInfoWidget(),
            
            // Navigation widget (only show when authenticated)
            if (_isAuthenticated)
              NavigationWidget(
                currentRoute: 'world-join',
                routeParams: {'id': widget.worldId},
                isJoinedWorld: _isJoined,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 12,
              color: const Color(0xFF1A1A1A), // Dunkle Karte
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF2A2A2A),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Fehler beim Laden',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage ?? 'Unbekannter Fehler',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Verschiedene Action-Buttons je nach Szenario
                      if (_showRegistrationButton && _inviteEmail != null) ...[
                        // Registration Button für neuen User
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => _navigateToRegistration(_inviteEmail!),
                            icon: const Icon(Icons.person_add),
                            label: const Text('Jetzt registrieren'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Login Button als Alternative
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => _navigateToLogin(_inviteEmail!),
                            icon: const Icon(Icons.login),
                            label: const Text('Bereits registriert? Anmelden'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: BorderSide(color: AppTheme.primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ] else if (_showLogoutButton && _inviteEmail != null) ...[
                        // Logout Button für falschen User
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout),
                            label: const Text('Abmelden & neu registrieren'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Abbrechen Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => context.goNamed('landing'),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Zurück zur Startseite'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey,
                              side: BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Standard Retry Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _retry,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Erneut versuchen'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.goNamed('world-list'),
                        child: const Text(
                          'Zurück zu den Welten',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 12,
              color: const Color(0xFF1A1A1A), // Dunkle Karte
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF2A2A2A),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 80,
                        color: Colors.blue[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Information',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _infoMessage ?? 'Keine Information verfügbar',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // **NEUE INTELLIGENTE BUTTONS**
                      _buildActionButtons(),
                      
                      // **INVITE-FLOWS: Kein "`
- 🔧 Context:
```dart
builder: (context) => AlertDialog(
        title: const Text('Welt verlassen?'),
        content: Text('Möchtest du die Welt "${world.name}" wirklich verlassen?'),
        actions: [
          TextButton(
```

**worldActiontypetextvaliditytextJeNach** (Confidence: 0.6)
- 📁 `lib\features\world\world_join_page.dart:281:87`
- 📝 Original: `" $actionTypeText.$validityText';
    
    // Je nach Status unterschiedliche Logik
    switch (status) {
      case 'not_logged_in':
        if (requiresAction == 'register') {
          // Mail ist unbekannt -> nur Register
          actionText = 'Du musst dich mit der E-Mail-Adresse $inviteEmail registrieren.';
          infoText = '$baseInfoText\n\n$actionText';
          showRegisterButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'user_exists_not_logged_in':
        if (requiresAction == 'login') {
          // Mail ist bekannt, User nicht angemeldet -> nur Login
          actionText = 'Dein Account mit $inviteEmail ist bereits registriert. Bitte melde dich an.';
          infoText = '$baseInfoText\n\n$actionText';
          showLoginButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'wrong_email':
        if (requiresAction == 'logout_and_register') {
          final currentUserEmail = userStatusData['currentUser']?['email'];
          // User mit falscher Mail angemeldet -> Logout + Register
          actionText = 'Diese Einladung ist für $inviteEmail bestimmt, aber du bist als $currentUserEmail angemeldet.';
          infoText = '$baseInfoText\n\n$actionText\n\nBitte melde dich ab und registriere dich mit der richtigen E-Mail-Adresse.';
          showLogoutButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'correct_email':
        if (requiresAction == 'join_world') {
          // User richtig angemeldet -> nur Accept Button (KEIN Auto-Accept!)
          actionText = 'Du bist mit der richtigen E-Mail-Adresse angemeldet und kannst die Einladung jetzt annehmen.';
          infoText = '$baseInfoText\n\n$actionText';
          showAcceptButton = isInviteValid; // Nur bei gültigen Invites
          
          // Auto-Accept entfernt: User soll bewusst entscheiden!
        }
        break;
        
      default:
        AppLogger.app.w('❌ Unbekannter User-Status: $status');
        actionText = 'Unbekannter Status: $status';
        infoText = '$baseInfoText\n\n$actionText';
    }
    
    // Bei ungültigen Invites zusätzliche Info
    if (!isInviteValid) {
      infoText += '\n\n⚠️ Diese Einladung kann nicht mehr verwendet werden.';
    }
    
    setState(() {
      _infoMessage = infoText;
      _inviteEmail = inviteEmail;
      
      // Button-Flags setzen
      _showLoginButton = showLoginButton;
      _showRegistrationButton = showRegisterButton; 
      _showLogoutButton = showLogoutButton;
      _showAcceptInviteButton = showAcceptButton;
      
      // WICHTIG: Alte Fehlermeldung zurücksetzen!
      _errorMessage = null;
      
      _isLoading = false;
    });
  }

  // Neue Methode: World-Status für normale Navigation prüfen
  Future<void> _checkWorldStatus() async {
    if (_world == null) return;
    
    try {
      // Prüfe ob User bereits Mitglied ist
      _isJoined = await _worldService.isPlayerInWorld(_world!.id);
      
      // Prüfe Vorregistrierung
      final preRegStatus = await _worldService.getPreRegistrationStatus(_world!.id);
      _isPreRegistered = preRegStatus.isPreRegistered;
      
      AppLogger.app.d('✅ World-Status geprüft', error: {
        'worldName': _world!.name,
        'isJoined': _isJoined,
        'isPreRegistered': _isPreRegistered
      });
    } catch (e) {
      AppLogger.logError('Fehler beim Prüfen des World-Status', e);
    }
  }

  // Neue Methode: Automatische Invite-Akzeptierung
  Future<void> _autoAcceptInvite() async {
    if (widget.inviteToken == null) return;
    
    try {
      final result = await _worldService.acceptInvite(widget.inviteToken!);
      
      if (result != null) {
        setState(() {
          _isJoined = true;
          _infoMessage = 'Willkommen in der Welt "`
- 🔧 Context:
```dart
}
    
    final baseInfoText = 'Du wurdest von $inviterText eingeladen, der Welt "$worldName" $actionTypeText.$validityText';
    
    // Je nach Status unterschiedliche Logik
```

**worldDasInviteWurde** (Confidence: 0.6)
- 📁 `lib\features\world\world_join_page.dart:384:66`
- 📝 Original: `"! Das Invite wurde automatisch akzeptiert.';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erfolgreich der Welt "`
- 🔧 Context:
```dart
setState(() {
          _isJoined = true;
          _infoMessage = 'Willkommen in der Welt "${_world?.name}"! Das Invite wurde automatisch akzeptiert.';
        });
```

**worldBeigetretenBackgroundcolorColorsgreen** (Confidence: 0.6)
- 📁 `lib\features\world\world_join_page.dart:390:67`
- 📝 Original: `" beigetreten!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // SPEZIALBEHANDLUNG: "`
- 🔧 Context:
```dart
ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erfolgreich der Welt "${_world!.name}" beigetreten!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
```

**worldIstKeinFehler** (Confidence: 0.6)
- 📁 `lib\features\world\world_join_page.dart:398:55`
- 📝 Original: `" ist KEIN Fehler!
      if (e.toString().contains('Invite bereits akzeptiert')) {
        setState(() {
          _isJoined = true;
          _infoMessage = 'Du bist bereits Mitglied dieser Welt "`
- 🔧 Context:
```dart
}
    } catch (e) {
      // SPEZIALBEHANDLUNG: "Invite bereits akzeptiert" ist KEIN Fehler!
      if (e.toString().contains('Invite bereits akzeptiert')) {
        setState(() {
```

**worldIfMountedScaffoldmessengerofcontextshowsnackbar** (Confidence: 0.6)
- 📁 `lib\features\world\world_join_page.dart:402:80`
- 📝 Original: `"!';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Du bist bereits Mitglied der Welt "`
- 🔧 Context:
```dart
setState(() {
          _isJoined = true;
          _infoMessage = 'Du bist bereits Mitglied dieser Welt "${_world?.name}"!';
        });
```

**worldBackgroundcolorColorsorangeDuration** (Confidence: 0.6)
- 📁 `lib\features\world\world_join_page.dart:408:80`
- 📝 Original: `"!'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return; // Erfolgreicher Exit
      }
      
      // Andere Fehler normal behandeln
      AppLogger.logError('Automatische Invite-Akzeptierung fehlgeschlagen', e);
      // Fehler nicht als kritisch behandeln - User kann manuell beitreten
      setState(() {
        _infoMessage = 'Du kannst nun der Welt beitreten.';
      });
    }
  }

  Future<void> _joinWorld() async {
    if (_world == null) return;

    setState(() {
      _isJoining = true;
      _joinError = null;
    });

    try {
      bool success = false;
      
      // **INVITE-TOKEN FLOW: Invite akzeptieren**
      if (widget.inviteToken != null) {
        AppLogger.app.i('🎫 Versuche Invite-Akzeptierung für World-Join');
        final inviteResult = await _worldService.acceptInvite(widget.inviteToken!);
        
        if (inviteResult != null) {
          success = true;
          AppLogger.app.i('✅ Invite erfolgreich akzeptiert', error: {
            'worldId': _world!.id,
            'worldName': _world!.name
          });
        }
      } else {
        // **NORMALE NAVIGATION: Standard World-Join**
        AppLogger.app.i('🌍 Versuche normalen World-Join');
        success = await _worldService.joinWorld(_world!.id);
      }
      
      if (success) {
        setState(() {
          _isJoined = true;
        });
        
        if (mounted) {
          final message = widget.inviteToken != null 
            ? 'Einladung akzeptiert! Willkommen in der Welt "`
- 🔧 Context:
```dart
ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Du bist bereits Mitglied der Welt "${_world?.name}"!'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
```

**worldErfolgreichDerWelt** (Confidence: 0.6)
- 📁 `lib\features\world\world_join_page.dart:462:77`
- 📝 Original: `"!'
            : 'Erfolgreich der Welt "`
- 🔧 Context:
```dart
if (mounted) {
          final message = widget.inviteToken != null 
            ? 'Einladung akzeptiert! Willkommen in der Welt "${_world!.name}"!'
            : 'Erfolgreich der Welt "${_world!.name}" beigetreten!';
```

**worldBeigetretenScaffoldmessengerofcontextshowsnackbarSnackbar** (Confidence: 0.6)
- 📁 `lib\features\world\world_join_page.dart:463:53`
- 📝 Original: `" beigetreten!';
            
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() {
          _joinError = 'Beitritt fehlgeschlagen. Versuche es erneut.';
        });
      }
    } catch (e) {
      AppLogger.logError('World Join fehlgeschlagen', e, context: {
        'worldId': _world?.id,
        'worldName': _world?.name,
        'hasInviteToken': widget.inviteToken != null,
        'inviteToken': widget.inviteToken?.substring(0, 8)
      });
      
      setState(() {
        // Bessere Fehlermeldungen für verschiedene Szenarien
        if (e.toString().contains('bereits akzeptiert')) {
          _joinError = 'Diese Einladung wurde bereits akzeptiert.';
          _isJoined = true; // User ist bereits Mitglied
        } else if (e.toString().contains('nicht für deine E-Mail-Adresse')) {
          _joinError = 'Diese Einladung ist nicht für deine E-Mail-Adresse bestimmt.';
        } else if (e.toString().contains('abgelaufen')) {
          _joinError = 'Diese Einladung ist abgelaufen.';
        } else {
          _joinError = 'Ein Fehler ist aufgetreten: ${e.toString().replaceAll('Exception: ', '')}';
        }
      });
    } finally {
      setState(() {
        _isJoining = false;
      });
    }
  }
  
  Future<void> _preRegisterWorld() async {
    final world = _world;
    if (world == null) return;

    setState(() {
      _isPreRegistering = true;
      _joinError = null;
    });

    try {
      final success = await _worldService.preRegisterWorldAuthenticated(world.id);
      
      if (success) {
        setState(() {
          _isPreRegistered = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erfolgreich für ${world.name} vorregistriert!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _joinError = 'Fehler bei der Vorregistrierung';
        });
      }
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPreRegistering = false;
        });
      }
    }
  }
  
  Future<void> _cancelPreRegistration() async {
    final world = _world;
    if (world == null) return;

    setState(() {
      _isPreRegistering = true;
      _joinError = null;
    });

    try {
      final success = await _worldService.cancelPreRegistrationAuthenticated(world.id);
      if (success) {
        setState(() {
          _isPreRegistered = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vorregistrierung für ${world.name} zurückgezogen.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        setState(() {
          _joinError = 'Fehler beim Zurückziehen der Vorregistrierung';
        });
      }
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPreRegistering = false;
        });
      }
    }
  }
  
  Future<void> _leaveWorld() async {
    final world = _world;
    if (world == null) return;
    
    // Bestätigungsdialog anzeigen
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Welt verlassen?'),
        content: Text('Möchtest du die Welt "`
- 🔧 Context:
```dart
final message = widget.inviteToken != null 
            ? 'Einladung akzeptiert! Willkommen in der Welt "${_world!.name}"!'
            : 'Erfolgreich der Welt "${_world!.name}" beigetreten!';
            
          ScaffoldMessenger.of(context).showSnackBar(
```

**worldWirklichVerlassenActions** (Confidence: 0.6)
- 📁 `lib\features\world\world_join_page.dart:600:59`
- 📝 Original: `" wirklich verlassen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Verlassen'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;

    setState(() {
      _isJoining = true;
      _joinError = null;
    });

    try {
      await _worldService.leaveWorld(world.id);
      setState(() {
        _isJoined = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Du hast ${world.name} verlassen.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }
  
  void _playWorld() {
    final world = _world;
    if (world == null) return;
    // Navigate directly to world dashboard for playing
    context.goNamed('world-dashboard', pathParameters: {'id': world.id.toString()});
  }

  // Welt-Status bestimmen
  String _getWorldStatusText() {
    final world = _world;
    if (world == null) return 'Unbekannt';
    return world.statusText;
  }

  // Welt-Status-Farbe
  Color _getWorldStatusColor() {
    final world = _world;
    if (world == null) return Colors.grey;
    
    switch (world.status) {
      case WorldStatus.upcoming:
        return Colors.orange;
      case WorldStatus.open:
        return Colors.green;
      case WorldStatus.running:
        return Colors.blue;
      case WorldStatus.closed:
        return Colors.red;
      case WorldStatus.archived:
        return Colors.grey;
    }
  }

  // Kann der Benutzer beitreten?
  // Retry-Funktion
  Future<void> _retry() async {
    await _loadWorldData();
  }

  // Navigation zu Registration mit vorausgefüllter E-Mail
  void _navigateToRegistration(String email) {
    AppLogger.app.i('🎫 Navigation zur Registration mit Invite-E-Mail', error: {'email': email});
    
    // FIXED: Invite-Token für Post-Auth-Redirect setzen
    if (widget.inviteToken != null) {
      _authService.setPendingInviteRedirect(widget.inviteToken!);
    }
    
    context.goNamed('register', queryParameters: {'email': email, 'invite_token': widget.inviteToken});
  }

  // Navigation zu Login 
  void _navigateToLogin(String email) {
    AppLogger.app.i('🎫 Navigation zum Login für Invite', error: {'email': email});
    
    // FIXED: Invite-Token für Post-Auth-Redirect setzen
    if (widget.inviteToken != null) {
      _authService.setPendingInviteRedirect(widget.inviteToken!);
    }
    
    context.goNamed('login', queryParameters: {'invite_token': widget.inviteToken});
  }

  // User abmelden und zur Registration weiterleiten
  Future<void> _logout() async {
    try {
      AppLogger.app.i('🎫 User logout für Invite-Umleitung', error: {'inviteEmail': _inviteEmail});
      
      // FIXED: Invite-Token für Post-Auth-Redirect setzen BEVOR logout
      if (widget.inviteToken != null) {
        _authService.setPendingInviteRedirect(widget.inviteToken!);
      }
      
      await _authService.logout();
      
      if (mounted && _inviteEmail != null) {
        // Nach Logout zur Registration mit korrekter E-Mail
        context.goNamed('register', queryParameters: {
          'email': _inviteEmail!,
          'invite_token': widget.inviteToken ?? ''
        });
      }
    } catch (e) {
      AppLogger.logError('Logout für Invite fehlgeschlagen', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler beim Abmelden'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: BackgroundWidget(
        child: Stack(
          children: [
            // Main content
            SafeArea(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    )
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _infoMessage != null
                          ? _buildInfoState()
                          : _world == null
                              ? _buildNotFoundState()
                              : _buildWorldContent(),
            ),
            
            // User info widget (only show when authenticated)
            if (_isAuthenticated)
              const UserInfoWidget(),
            
            // Navigation widget (only show when authenticated)
            if (_isAuthenticated)
              NavigationWidget(
                currentRoute: 'world-join',
                routeParams: {'id': widget.worldId},
                isJoinedWorld: _isJoined,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 12,
              color: const Color(0xFF1A1A1A), // Dunkle Karte
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF2A2A2A),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Fehler beim Laden',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage ?? 'Unbekannter Fehler',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Verschiedene Action-Buttons je nach Szenario
                      if (_showRegistrationButton && _inviteEmail != null) ...[
                        // Registration Button für neuen User
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => _navigateToRegistration(_inviteEmail!),
                            icon: const Icon(Icons.person_add),
                            label: const Text('Jetzt registrieren'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Login Button als Alternative
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => _navigateToLogin(_inviteEmail!),
                            icon: const Icon(Icons.login),
                            label: const Text('Bereits registriert? Anmelden'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: BorderSide(color: AppTheme.primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ] else if (_showLogoutButton && _inviteEmail != null) ...[
                        // Logout Button für falschen User
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout),
                            label: const Text('Abmelden & neu registrieren'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Abbrechen Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => context.goNamed('landing'),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Zurück zur Startseite'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey,
                              side: BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Standard Retry Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _retry,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Erneut versuchen'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.goNamed('world-list'),
                        child: const Text(
                          'Zurück zu den Welten',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 12,
              color: const Color(0xFF1A1A1A), // Dunkle Karte
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF2A2A2A),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 80,
                        color: Colors.blue[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Information',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _infoMessage ?? 'Keine Information verfügbar',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // **NEUE INTELLIGENTE BUTTONS**
                      _buildActionButtons(),
                      
                      // **INVITE-FLOWS: Kein "`
- 🔧 Context:
```dart
builder: (context) => AlertDialog(
        title: const Text('Welt verlassen?'),
        content: Text('Möchtest du die Welt "${world.name}" wirklich verlassen?'),
        actions: [
          TextButton(
```


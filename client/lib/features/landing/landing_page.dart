import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../config/logger.dart';
import '../../core/services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/background_widget.dart';
import '../../shared/widgets/navigation_widget.dart';
import '../../main.dart';
import 'dart:math' as math;

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _featureController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _featureAnimation;
  
  final ScrollController _scrollController = ScrollController();
  bool _showFeatures = false;

  @override
  void initState() {
    super.initState();
    AppLogger.app.d('📱 LandingPage initialisiert');
    
    // Main animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Logo pulse animation
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    // Feature animation
    _featureController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _featureAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _featureController,
      curve: Curves.easeOutBack,
    ));
    
    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
    
    // Show features after main animation
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _showFeatures = true;
        });
        _featureController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _featureController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.app.d('🏗️ LandingPage wird gebaut...');
    
    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Hero Section
                Container(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                  ),
                  child: Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 600),
                              child: Card(
                                elevation: 16,
                                color: const Color(0xFF1A1A1A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  side: BorderSide(
                                    color: AppTheme.primaryColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 48.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Animated Logo
                                        AnimatedBuilder(
                                          animation: _pulseAnimation,
                                          builder: (context, child) {
                                            return Transform.scale(
                                              scale: _pulseAnimation.value,
                                              child: Container(
                                                width: 140,
                                                height: 140,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primaryColor.withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(35),
                                                  border: Border.all(
                                                    color: AppTheme.primaryColor.withOpacity(0.4),
                                                    width: 2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppTheme.primaryColor.withOpacity(0.4),
                                                      blurRadius: 30,
                                                      spreadRadius: 10,
                                                    ),
                                                  ],
                                                ),
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.public,
                                                      size: 70,
                                                      color: AppTheme.primaryColor,
                                                    ),
                                                    // Orbit animation
                                                    ...List.generate(3, (index) {
                                                      return TweenAnimationBuilder<double>(
                                                        tween: Tween(begin: 0, end: 2 * math.pi),
                                                        duration: Duration(seconds: 10 + index * 2),
                                                        builder: (context, value, child) {
                                                          return Transform.translate(
                                                            offset: Offset(
                                                              math.cos(value + (index * 2 * math.pi / 3)) * 50,
                                                              math.sin(value + (index * 2 * math.pi / 3)) * 50,
                                                            ),
                                                            child: Container(
                                                              width: 8,
                                                              height: 8,
                                                              decoration: BoxDecoration(
                                                                color: AppTheme.primaryColor.withOpacity(0.8),
                                                                shape: BoxShape.circle,
                                                                boxShadow: const [
                                                                  BoxShadow(
                                                                    color: AppTheme.primaryColor,
                                                                    blurRadius: 4,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    }),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        
                                        const SizedBox(height: 40),
                                        
                                        // Title with enhanced gradient
                                        ShaderMask(
                                          shaderCallback: (bounds) => LinearGradient(
                                            colors: [
                                              AppTheme.primaryColor,
                                              AppTheme.primaryColor.withBlue(255),
                                              AppTheme.primaryColor,
                                            ],
                                            stops: const [0.0, 0.5, 1.0],
                                          ).createShader(bounds),
                                          child: Text(
                                            'Weltenwind',
                                            style: TextStyle(
                                              fontSize: 56,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 3,
                                              shadows: [
                                                Shadow(
                                                  color: AppTheme.primaryColor.withOpacity(0.5),
                                                  blurRadius: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        
                                        const SizedBox(height: 20),
                                        
                                        // Enhanced Subtitle
                                        Text(
                                          'Dein Portal zu unendlichen Welten',
                                          style: TextStyle(
                                            color: Colors.grey[200],
                                            fontSize: 22,
                                            fontWeight: FontWeight.w300,
                                            letterSpacing: 1,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        
                                        const SizedBox(height: 12),
                                        
                                        // Tagline
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: AppTheme.primaryColor.withOpacity(0.3),
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '🎮 Spiele • 🌍 Erkunde • 🤝 Verbinde',
                                            style: TextStyle(
                                              color: AppTheme.primaryColor.withOpacity(0.9),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        
                                        const SizedBox(height: 48),
                                        
                                        // CTA Buttons with enhanced styling
                                        Column(
                                          children: [
                                            // Primary CTA - Register
                                            MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 200),
                                                width: double.infinity,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      AppTheme.primaryColor,
                                                      AppTheme.primaryColor.withBlue(255),
                                                    ],
                                                  ),
                                                  borderRadius: BorderRadius.circular(16),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppTheme.primaryColor.withOpacity(0.4),
                                                      blurRadius: 20,
                                                      offset: const Offset(0, 8),
                                                    ),
                                                  ],
                                                ),
                                                child: ElevatedButton(
                                                  onPressed: () => context.goNamed('register'),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.transparent,
                                                    shadowColor: Colors.transparent,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(16),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      const Icon(
                                                        Icons.rocket_launch,
                                                        color: Colors.white,
                                                        size: 24,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          const Text(
                                                            'Jetzt kostenlos starten',
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            'Keine Kreditkarte erforderlich',
                                                            style: TextStyle(
                                                              color: Colors.white.withOpacity(0.8),
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            
                                            const SizedBox(height: 16),
                                            
                                            // Secondary CTA - Login
                                            Container(
                                              width: double.infinity,
                                              height: 56,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2D2D2D),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: AppTheme.primaryColor.withOpacity(0.5),
                                                  width: 2,
                                                ),
                                              ),
                                              child: ElevatedButton.icon(
                                                onPressed: () => context.goNamed('login'),
                                                icon: const Icon(
                                                  Icons.login,
                                                  color: AppTheme.primaryColor,
                                                ),
                                                label: const Text(
                                                  'Bereits Mitglied? Anmelden',
                                                  style: TextStyle(
                                                    color: AppTheme.primaryColor,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.transparent,
                                                  shadowColor: Colors.transparent,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        const SizedBox(height: 40),
                                        
                                        // Stats Row
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _buildStatItem('500+', 'Welten'),
                                            Container(
                                              height: 40,
                                              width: 1,
                                              color: Colors.grey[700],
                                            ),
                                            _buildStatItem('1000+', 'Spieler'),
                                            Container(
                                              height: 40,
                                              width: 1,
                                              color: Colors.grey[700],
                                            ),
                                            _buildStatItem('24/7', 'Online'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Scroll indicator
                if (_showFeatures)
                  FadeTransition(
                    opacity: _featureAnimation,
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        children: [
                          Text(
                            'Entdecke mehr',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Icon(
                            Icons.expand_more,
                            color: AppTheme.primaryColor,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Features Section
                if (_showFeatures)
                  FadeTransition(
                    opacity: _featureAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                      child: Column(
                        children: [
                          const Text(
                            'Was macht Weltenwind besonders?',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erlebe Gaming auf einem neuen Level',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[300],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 60),
                          
                          // Feature Grid
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final crossAxisCount = constraints.maxWidth > 800 ? 3 : 
                                                    constraints.maxWidth > 500 ? 2 : 1;
                              return GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 24,
                                crossAxisSpacing: 24,
                                childAspectRatio: 1.2,
                                children: [
                                  _buildFeatureCard(
                                    icon: Icons.public,
                                    title: 'Unendliche Welten',
                                    description: 'Erkunde hunderte einzigartige Spielwelten oder erschaffe deine eigene',
                                    color: Colors.blue,
                                  ),
                                  _buildFeatureCard(
                                    icon: Icons.group,
                                    title: 'Community',
                                    description: 'Verbinde dich mit Spielern aus der ganzen Welt',
                                    color: Colors.green,
                                  ),
                                  _buildFeatureCard(
                                    icon: Icons.security,
                                    title: 'Sicher & Fair',
                                    description: 'Modernste Sicherheit und faire Spielregeln für alle',
                                    color: Colors.orange,
                                  ),
                                  _buildFeatureCard(
                                    icon: Icons.speed,
                                    title: 'Blitzschnell',
                                    description: 'Optimierte Server für minimale Latenz',
                                    color: Colors.purple,
                                  ),
                                  _buildFeatureCard(
                                    icon: Icons.devices,
                                    title: 'Überall spielen',
                                    description: 'Auf PC, Tablet oder Smartphone - immer dabei',
                                    color: Colors.red,
                                  ),
                                  _buildFeatureCard(
                                    icon: Icons.star,
                                    title: 'Belohnungen',
                                    description: 'Sammle Erfolge und exklusive Belohnungen',
                                    color: Colors.amber,
                                  ),
                                ],
                              );
                            },
                          ),
                          
                          const SizedBox(height: 80),
                          
                          // Final CTA
                          Container(
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor.withOpacity(0.1),
                                  AppTheme.primaryColor.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Bereit für dein Abenteuer?',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Schließe dich tausenden Spielern an und starte noch heute!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[300],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () => context.goNamed('register'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      padding: const EdgeInsets.symmetric(horizontal: 48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Kostenlos registrieren →',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Footer
                Container(
                  margin: const EdgeInsets.only(top: 40),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey[800] ?? Colors.grey,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '© 2024 Weltenwind. Alle Rechte vorbehalten.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Datenschutz',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text('•', style: TextStyle(color: Colors.grey[600])),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Impressum',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text('•', style: TextStyle(color: Colors.grey[600])),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Support',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }
  
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 40,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 
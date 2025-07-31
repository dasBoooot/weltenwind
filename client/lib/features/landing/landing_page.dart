import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/background_widget.dart';
import '../../shared/widgets/language_switcher.dart';
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
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(
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
                                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
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
                                                      color: AppTheme.primaryColor.withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(35),
                                                      border: Border.all(
                                                        color: AppTheme.primaryColor.withValues(alpha: 0.4),
                                                        width: 2,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: AppTheme.primaryColor.withValues(alpha: 0.4),
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
                                                                    color: AppTheme.primaryColor.withValues(alpha: 0.8),
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
                                                AppLocalizations.of(context).appTitle,
                                                style: TextStyle(
                                                  fontSize: 56,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  letterSpacing: 3,
                                                  shadows: [
                                                    Shadow(
                                                      color: AppTheme.primaryColor.withValues(alpha: 0.5),
                                                      blurRadius: 20,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            
                                            const SizedBox(height: 20),
                                            
                                            // Enhanced Subtitle
                                            Text(
                                              AppLocalizations.of(context).landingSubtitle,
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
                                                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                AppLocalizations.of(context).landingTagline,
                                                style: TextStyle(
                                                  color: AppTheme.primaryColor.withValues(alpha: 0.9),
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
                                                          color: AppTheme.primaryColor.withValues(alpha: 0.4),
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
                                                              Text(
                                                                AppLocalizations.of(context).landingStartButton,
                                                                style: const TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              Text(
                                                                AppLocalizations.of(context).landingNoCreditCard,
                                                                style: TextStyle(
                                                                  color: Colors.white.withValues(alpha: 0.8),
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
                                                      color: AppTheme.primaryColor.withValues(alpha: 0.5),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: ElevatedButton.icon(
                                                    onPressed: () => context.goNamed('login'),
                                                    icon: const Icon(
                                                      Icons.login,
                                                      color: AppTheme.primaryColor,
                                                    ),
                                                    label: Text(
                                                      AppLocalizations.of(context).landingLoginPrompt,
                                                      style: const TextStyle(
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
                                                _buildStatItem('500+', AppLocalizations.of(context).navWorldList),
                                                Container(
                                                  height: 40,
                                                  width: 1,
                                                  color: Colors.grey[700],
                                                ),
                                                _buildStatItem('1000+', AppLocalizations.of(context).landingStatsPlayers),
                                                Container(
                                                  height: 40,
                                                  width: 1,
                                                  color: Colors.grey[700],
                                                ),
                                                _buildStatItem('24/7', AppLocalizations.of(context).landingStatsOnline),
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
                                AppLocalizations.of(context).landingDiscoverMore,
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
                              Text(
                                AppLocalizations.of(context).landingFeaturesTitle,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context).landingFeaturesSubtitle,
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
                                        title: AppLocalizations.of(context).landingFeatureWorldsTitle,
                                        description: AppLocalizations.of(context).landingFeatureWorldsDesc,
                                        color: Colors.blue,
                                      ),
                                      _buildFeatureCard(
                                        icon: Icons.group,
                                        title: AppLocalizations.of(context).landingFeatureCommunityTitle,
                                        description: AppLocalizations.of(context).landingFeatureCommunityDesc,
                                        color: Colors.green,
                                      ),
                                      _buildFeatureCard(
                                        icon: Icons.security,
                                        title: AppLocalizations.of(context).landingFeatureSecurityTitle,
                                        description: AppLocalizations.of(context).landingFeatureSecurityDesc,
                                        color: Colors.orange,
                                      ),
                                      _buildFeatureCard(
                                        icon: Icons.speed,
                                        title: AppLocalizations.of(context).landingFeatureSpeedTitle,
                                        description: AppLocalizations.of(context).landingFeatureSpeedDesc,
                                        color: Colors.purple,
                                      ),
                                      _buildFeatureCard(
                                        icon: Icons.devices,
                                        title: AppLocalizations.of(context).landingFeatureMobileTitle,
                                        description: AppLocalizations.of(context).landingFeatureMobileDesc,
                                        color: Colors.red,
                                      ),
                                      _buildFeatureCard(
                                        icon: Icons.star,
                                        title: AppLocalizations.of(context).landingFeatureRewardsTitle,
                                        description: AppLocalizations.of(context).landingFeatureRewardsDesc,
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
                                      AppTheme.primaryColor.withValues(alpha: 0.1),
                                      AppTheme.primaryColor.withValues(alpha: 0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context).landingCtaTitle,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      AppLocalizations.of(context).landingCtaSubtitle,
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
                                        child: Text(
                                          AppLocalizations.of(context).landingRegisterButton,
                                          style: const TextStyle(
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
                            AppLocalizations.of(context).footerCopyright,
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
                                  AppLocalizations.of(context).footerPrivacy,
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
                                  AppLocalizations.of(context).footerLegal,
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
                                  AppLocalizations.of(context).footerSupport,
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
          
          // Language Switcher (oben links)
          const Positioned(
            top: 40.0,
            left: 20.0,
            child: SafeArea(
              child: LanguageSwitcher(),
            ),
          ),
        ],
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
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
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
                color: color.withValues(alpha: 0.1),
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
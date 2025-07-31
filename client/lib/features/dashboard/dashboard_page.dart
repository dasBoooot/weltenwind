import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/background_widget.dart';
import '../../shared/widgets/user_info_widget.dart';
import '../../shared/widgets/navigation_widget.dart';
import '../../shared/widgets/language_switcher.dart';
import '../../theme/tokens/spacing.dart';

class DashboardPage extends StatelessWidget {
  final String worldId;
  
  const DashboardPage({super.key, required this.worldId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: Stack(
          children: [
            // Main content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Card(
                    elevation: 12,
                    color: const Color(0xFF1A1A1A), // Dunkle Karte
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
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
                            // Icon
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.5),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.rocket_launch,
                                size: 40,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Title
                            Text(
                              'Welt-Dashboard',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Subtitle
                            Text(
                              'Welt ID: $worldId',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[300],
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Info message
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.construction,
                                    color: AppTheme.primaryColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Das Dashboard befindet sich noch im Aufbau.',
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 16,
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
                  ),
                ),
              ),
            ),
            
            // User info widget in top-left corner
            const UserInfoWidget(),
            
            // Language switcher (left of NavigationWidget)
            const Positioned(
              top: AppSpacing.md,
              right: 96, // 20px Abstand vom NavigationWidget (76 + 20)
              child: SafeArea(
                child: LanguageSwitcher(),
              ),
            ),
            
            // Navigation widget in top-right corner
            NavigationWidget(
              currentRoute: 'world-dashboard',
              routeParams: {'id': worldId},
              isJoinedWorld: true, // User muss in der Welt sein um das Dashboard zu sehen
            ),
          ],
        ),
      ),
    );
  }
} 
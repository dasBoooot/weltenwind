import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

/// 🏛️ ROMAN IMPERIUM DASHBOARD
/// 
/// Majestic Roman Empire interface with ranks, legions, architecture, and golden marble effects!
/// Full integration with roman theme extensions for authentic imperial experience!
class RomanImperiumWidget extends StatefulWidget {
  final String? worldName;
  final int? worldId;
  final ThemeData theme;
  final Map<String, dynamic>? extensions;

  const RomanImperiumWidget({
    super.key,
    required this.worldName,
    required this.worldId,
    required this.theme,
    required this.extensions,
  });

  @override
  State<RomanImperiumWidget> createState() => _RomanImperiumWidgetState();
}

class _RomanImperiumWidgetState extends State<RomanImperiumWidget> 
    with TickerProviderStateMixin {
  late AnimationController _goldController;
  late AnimationController _marbleController;
  late AnimationController _eagleController;
  late AnimationController _legionController;
  late Timer _imperiumTimer;
  
  String _selectedRank = 'senator';
  String _activeArchitecture = 'column';
  int _imperiumPower = 89;
  int _legionStrength = 76;
  final Map<String, int> _legionStatus = {
    'I_Augusta': 92,
    'II_Victrix': 87,
    'III_Gallica': 81,
    'V_Macedonica': 78,
  };
  final List<String> _imperiumLog = [
    '🏛️ Senate session convened in Forum',
    '⚔️ Legion III advances on Gaul',
    '🏺 Trade routes established with Egypt',
    '🎖️ Centurion Maximus promoted'
  ];

  @override
  void initState() {
    super.initState();
    _goldController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
    
    _marbleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _eagleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _legionController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
    
    _startImperiumUpdates();
  }

  void _startImperiumUpdates() {
    _imperiumTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          // Legion movements and status changes
          _legionStatus.forEach((legion, strength) {
            _legionStatus[legion] = math.max(60, math.min(100, strength + (math.Random().nextInt(8) - 4)));
          });
          
          // Imperial power fluctuations
          _imperiumPower = math.max(70, math.min(100, _imperiumPower + (math.Random().nextInt(6) - 3)));
          _legionStrength = math.max(60, math.min(95, _legionStrength + (math.Random().nextInt(10) - 5)));
          
          // Add imperium log entry
          _imperiumLog.add(_getRandomImperiumMessage());
          if (_imperiumLog.length > 6) _imperiumLog.removeAt(0);
        });
      }
    });
  }

  @override
  void dispose() {
    _goldController.dispose();
    _marbleController.dispose();
    _eagleController.dispose();
    _legionController.dispose();
    _imperiumTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roman = widget.extensions?['roman'] as Map<String, dynamic>?;
    final worldTheme = widget.extensions?['worldTheme'] as Map<String, dynamic>?;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildImperialHeader(worldTheme),
          const SizedBox(height: 20),
          
          // 🏛️ Main Imperial Interface
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Ranks & Architecture
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildRankHierarchy(roman),
                    const SizedBox(height: 16),
                    _buildArchitecturePanel(roman),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              
              // Center: Legion Command & Imperial Status
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _buildLegionCommand(),
                    const SizedBox(height: 16),
                    _buildImperialStatus(),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              
              // Right: Trade Routes & Imperial Log
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildTradeRoutes(),
                    const SizedBox(height: 16),
                    _buildImperialLog(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🏛️ Imperial Header with golden marble effects
  Widget _buildImperialHeader(Map<String, dynamic>? worldTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFD700).withValues(alpha: 0.15),
            const Color(0xFFCD853F).withValues(alpha: 0.1),
            const Color(0xFFDDBEA9).withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
            blurRadius: 25,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Marble texture effect
          AnimatedBuilder(
            animation: _marbleController,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [
                      _marbleController.value * 0.3,
                      _marbleController.value * 0.6,
                      _marbleController.value * 0.9,
                    ],
                    colors: [
                      const Color(0xFFF5F5DC).withValues(alpha: 0.1),
                      const Color(0xFFDDBEA9).withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Content
          Row(
            children: [
              // Imperial Eagle with golden animation
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Golden aureole
                    AnimatedBuilder(
                      animation: _goldController,
                      builder: (context, child) {
                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Color.lerp(
                                  const Color(0xFFFFD700),
                                  const Color(0xFFCD853F),
                                  math.sin(_goldController.value * 2 * math.pi) * 0.5 + 0.5,
                                )!.withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    // Rotating border
                    AnimatedBuilder(
                      animation: _eagleController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _eagleController.value * 2 * math.pi,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFFFD700),
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Central eagle
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [
                            Color(0xFF800020),
                            Color(0xFFB22222),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: AnimatedBuilder(
                        animation: _eagleController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + 0.1 * math.sin(_eagleController.value * 4 * math.pi),
                            child: const Icon(
                              Icons.flight,
                              color: Color(0xFFFFD700),
                              size: 30,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              
              // Imperial Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.worldName ?? 'Imperium Romanum',
                      style: widget.theme.textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFF800020),
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.7),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '🏛️ ${worldTheme?['atmosphere'] ?? 'golden-forum'} • ${worldTheme?['timeOfDay'] ?? 'midday-sun'}',
                      style: widget.theme.textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFFCD853F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '🎵 ${worldTheme?['ambientSound'] ?? 'forum-chatter'}',
                      style: widget.theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFDDBEA9),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Imperial indicators
                    Row(
                      children: [
                        _buildImperialIndicator('PODER', _imperiumPower, const Color(0xFFFFD700)),
                        const SizedBox(width: 16),
                        _buildImperialIndicator('LEGION', _legionStrength, const Color(0xFF800020)),
                        const SizedBox(width: 16),
                        _buildImperialIndicator('GLORIA', 95, const Color(0xFFCD853F)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Imperial indicator
  Widget _buildImperialIndicator(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: widget.theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        AnimatedBuilder(
          animation: _goldController,
          builder: (context, child) {
            return Text(
              '$value%',
              style: widget.theme.textTheme.bodySmall?.copyWith(
                color: Color.lerp(
                  color,
                  color.withValues(alpha: 0.7),
                  math.sin(_goldController.value * 2 * math.pi + value * 0.05) * 0.3 + 0.3,
                ),
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ],
    );
  }

  /// 🎖️ Rank Hierarchy
  Widget _buildRankHierarchy(Map<String, dynamic>? roman) {
    final ranks = roman?['ranks'] as Map<String, dynamic>? ?? {};
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF800020).withValues(alpha: 0.1),
            const Color(0xFFFFD700).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getRankColor(_selectedRank, ranks),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.military_tech,
                color: _getRankColor(_selectedRank, ranks),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '🎖️ HIERARCHIA',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF800020),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...ranks.entries.map((rank) => _buildRankOption(rank.key, rank.value)),
        ],
      ),
    );
  }

  /// Rank selection option
  Widget _buildRankOption(String rankName, dynamic rankData) {
    final isSelected = _selectedRank == rankName;
    final rankColor = Color(int.parse(rankData['primaryColor'].substring(1), radix: 16) + 0xFF000000);
    final accentColor = Color(int.parse(rankData['accentColor'].substring(1), radix: 16) + 0xFF000000);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedRank = rankName),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: isSelected ? LinearGradient(
              colors: [
                rankColor.withValues(alpha: 0.2),
                accentColor.withValues(alpha: 0.1),
              ],
            ) : null,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? rankColor : rankColor.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.4),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ] : null,
          ),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [rankColor, accentColor],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  _getRankIcon(rankName),
                  color: Colors.white,
                  size: 10,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  rankName.toUpperCase(),
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected ? rankColor : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.verified,
                  color: accentColor,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🏛️ Architecture Panel
  Widget _buildArchitecturePanel(Map<String, dynamic>? roman) {
    final architecture = roman?['architecture'] as Map<String, dynamic>? ?? {};
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF5F5DC).withValues(alpha: 0.1),
            const Color(0xFFDDBEA9).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getArchitectureColor(_activeArchitecture, architecture),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance,
                color: _getArchitectureColor(_activeArchitecture, architecture),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '🏛️ ARCHITECTURA',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFFCD853F),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Architecture grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: architecture.entries.map((arch) => _buildArchitectureOption(arch.key, arch.value)).toList(),
          ),
        ],
      ),
    );
  }

  /// Architecture option
  Widget _buildArchitectureOption(String archName, dynamic archColor) {
    final isSelected = _activeArchitecture == archName;
    final color = Color(int.parse(archColor.toString().substring(1), radix: 16) + 0xFF000000);
    
    return GestureDetector(
      onTap: () => setState(() => _activeArchitecture = archName),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isSelected ? RadialGradient(
            colors: [
              color.withValues(alpha: 0.3),
              color.withValues(alpha: 0.1),
            ],
          ) : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 8,
            ),
          ] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _marbleController,
              builder: (context, child) {
                return Transform.scale(
                  scale: isSelected ? 1.0 + 0.1 * math.sin(_marbleController.value * 2 * math.pi) : 1.0,
                  child: Icon(
                    _getArchitectureIcon(archName),
                    color: color,
                    size: 20,
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              archName.toUpperCase(),
              style: widget.theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? color : Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ⚔️ Legion Command
  Widget _buildLegionCommand() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF800020).withValues(alpha: 0.15),
            const Color(0xFFB22222).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF800020),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _legionController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: math.sin(_legionController.value * 2 * math.pi) * 0.1,
                    child: const Icon(
                      Icons.shield,
                      color: Color(0xFF800020),
                      size: 24,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                '⚔️ LEGIO COMMAND',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF800020),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Legion status
          ..._legionStatus.entries.map((legion) => _buildLegionStatus(legion.key, legion.value)),
        ],
      ),
    );
  }

  /// Legion status display
  Widget _buildLegionStatus(String legionName, int strength) {
    final displayName = legionName.replaceAll('_', ' ');
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _legionController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + 0.1 * math.sin(_legionController.value * 2 * math.pi + strength * 0.02),
                        child: const Icon(
                          Icons.military_tech,
                          color: Color(0xFF800020),
                          size: 16,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    displayName,
                    style: widget.theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF800020),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Text(
                '$strength%',
                style: widget.theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 6,
                  color: const Color(0xFF800020).withValues(alpha: 0.2),
                ),
                AnimatedBuilder(
                  animation: _legionController,
                  builder: (context, child) {
                    return FractionallySizedBox(
                      widthFactor: (strength / 100) * (1.0 + 0.05 * math.sin(_legionController.value * 2 * math.pi)),
                      child: Container(
                        height: 6,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF800020),
                              Color(0xFFFFD700),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🏛️ Imperial Status
  Widget _buildImperialStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            const Color(0xFFFFD700).withValues(alpha: 0.1),
            const Color(0xFFCD853F).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFD700),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _goldController,
                builder: (context, child) {
                  return Icon(
                    Icons.account_balance,
                    color: Color.lerp(
                      const Color(0xFFFFD700),
                      const Color(0xFFCD853F),
                      math.sin(_goldController.value * 2 * math.pi) * 0.5 + 0.5,
                    ),
                    size: 24,
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                '🏛️ STATUS IMPERIALIS',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Imperial power circle
          Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _goldController,
                    builder: (context, child) {
                      return CircularProgressIndicator(
                        value: (_imperiumPower / 100) * (1.0 + 0.05 * math.sin(_goldController.value * 2 * math.pi)),
                        strokeWidth: 8,
                        backgroundColor: const Color(0xFF800020).withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                      );
                    },
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$_imperiumPower%',
                          style: widget.theme.textTheme.titleLarge?.copyWith(
                            color: const Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'IMPERIUM',
                          style: widget.theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFCD853F),
                            fontSize: 10,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🏺 Trade Routes
  Widget _buildTradeRoutes() {
    final tradeRoutes = [
      {'name': 'VIA AEGYPTUS', 'status': 'ACTIVE', 'value': '2,400 AU'},
      {'name': 'VIA BRITANNIA', 'status': 'DELAYED', 'value': '1,800 AU'},
      {'name': 'VIA HISPANIA', 'status': 'ACTIVE', 'value': '3,200 AU'},
      {'name': 'VIA GALLIA', 'status': 'ACTIVE', 'value': '2,900 AU'},
    ];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2F1B14).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFCD853F),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_shipping,
                color: Color(0xFFCD853F),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '🏺 MERCATURA',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFFCD853F),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...tradeRoutes.map((route) => _buildTradeRoute(route)),
        ],
      ),
    );
  }

  /// Trade route display
  Widget _buildTradeRoute(Map<String, String> route) {
    final isActive = route['status'] == 'ACTIVE';
    final statusColor = isActive ? const Color(0xFF32CD32) : const Color(0xFFFFD700);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                route['name']!,
                style: widget.theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFCD853F),
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                route['value']!,
                style: widget.theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.6),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                route['status']!,
                style: widget.theme.textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 📜 Imperial Log
  Widget _buildImperialLog() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2F1B14).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF800020),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.history_edu,
                color: Color(0xFF800020),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '📜 ACTA DIURNA',
                style: widget.theme.textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF800020),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Log entries
          SizedBox(
            height: 120,
            child: ListView.builder(
              itemCount: _imperiumLog.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: AnimatedBuilder(
                    animation: _goldController,
                    builder: (context, child) {
                      return Text(
                        _imperiumLog[index],
                        style: TextStyle(
                          color: Color.lerp(
                            const Color(0xFF800020),
                            const Color(0xFFCD853F),
                            (math.sin(_goldController.value * 2 * math.pi + index * 0.7) * 0.3 + 0.7),
                          ),
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getRankColor(String rankName, Map<String, dynamic> ranks) {
    try {
      final rankData = ranks[rankName];
      return Color(int.parse(rankData['primaryColor'].substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return const Color(0xFF800020);
    }
  }

  Color _getArchitectureColor(String archName, Map<String, dynamic> architecture) {
    try {
      final archColor = architecture[archName].toString();
      return Color(int.parse(archColor.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return const Color(0xFFF5F5DC);
    }
  }

  IconData _getRankIcon(String rankName) {
    switch (rankName) {
      case 'senator': return Icons.account_balance;
      case 'centurion': return Icons.military_tech;
      case 'citizen': return Icons.person;
      case 'slave': return Icons.person_outline;
      default: return Icons.person;
    }
  }

  IconData _getArchitectureIcon(String archName) {
    switch (archName) {
      case 'column': return Icons.view_column;
      case 'arch': return Icons.architecture;
      case 'dome': return Icons.account_balance;
      case 'fresco': return Icons.palette;
      default: return Icons.account_balance;
    }
  }

  String _getRandomImperiumMessage() {
    final messages = [
      '👑 Caesar addresses the Senate',
      '⚔️ Victory reported from Germania',
      '🏺 New trade agreement with Carthage',
      '🎭 Gladiator games announced',
      '🏛️ Temple construction completed',
      '📜 New laws enacted by Senate',
      '🛡️ Border fortifications reinforced',
      '💰 Tax collection exceeded quota'
    ];
    return messages[math.Random().nextInt(messages.length)];
  }
}
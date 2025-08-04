import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

/// 🌿 NATURE ECOSYSTEM DASHBOARD
/// 
/// Living, breathing nature interface with seasons, biomes, wildlife, and organic growth animations!
/// Full integration with nature theme extensions for authentic eco-system experience!
class NatureEcoWidget extends StatefulWidget {
  final String? worldName;
  final int? worldId;
  final ThemeData theme;
  final Map<String, dynamic>? extensions;

  const NatureEcoWidget({
    super.key,
    required this.worldName,
    required this.worldId,
    required this.theme,
    required this.extensions,
  });

  @override
  State<NatureEcoWidget> createState() => _NatureEcoWidgetState();
}

class _NatureEcoWidgetState extends State<NatureEcoWidget> 
    with TickerProviderStateMixin {
  late AnimationController _growthController;
  late AnimationController _windController;
  late AnimationController _seasonController;
  late AnimationController _lifeController;
  late Timer _ecosystemTimer;
  
  String _currentSeason = 'spring';
  String _activeBiome = 'grove';
  int _biodiversity = 87;
  int _ecosystemHealth = 92;
  final Map<String, int> _wildlifePopulation = {
    'butterflies': 234,
    'birds': 45,
    'mammals': 18,
    'insects': 1847,
  };
  final List<String> _ecoLog = [
    '🌱 New saplings detected in Grove sector',
    '🦋 Butterfly migration in progress',
    '🌸 Spring bloom cycle initiated',
    '🐦 Songbird activity increased'
  ];

  @override
  void initState() {
    super.initState();
    _growthController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    _windController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
    
    _seasonController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _lifeController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _startEcosystemUpdates();
  }

  void _startEcosystemUpdates() {
    _ecosystemTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          // Natural fluctuations in wildlife
          _wildlifePopulation.forEach((species, count) {
            _wildlifePopulation[species] = math.max(0, count + (math.Random().nextInt(20) - 10));
          });
          
          // Ecosystem health variations
          _ecosystemHealth = math.max(70, math.min(100, _ecosystemHealth + (math.Random().nextInt(6) - 3)));
          _biodiversity = math.max(60, math.min(100, _biodiversity + (math.Random().nextInt(8) - 4)));
          
          // Add eco log entry
          _ecoLog.add(_getRandomEcoMessage());
          if (_ecoLog.length > 6) _ecoLog.removeAt(0);
        });
      }
    });
  }

  @override
  void dispose() {
    _growthController.dispose();
    _windController.dispose();
    _seasonController.dispose();
    _lifeController.dispose();
    _ecosystemTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nature = widget.extensions?['nature'] as Map<String, dynamic>?;
    final worldTheme = widget.extensions?['worldTheme'] as Map<String, dynamic>?;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildLivingHeader(worldTheme),
          const SizedBox(height: 20),
          
          // 🌿 Main Ecosystem Interface
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Seasons & Biomes
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildSeasonControl(nature),
                    const SizedBox(height: 16),
                    _buildBiomeExplorer(nature),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              
              // Center: Wildlife & Growth Monitor
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _buildWildlifeTracker(),
                    const SizedBox(height: 16),
                    _buildGrowthMonitor(),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              
              // Right: Ecosystem Status & Log
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildEcosystemStatus(),
                    const SizedBox(height: 16),
                    _buildEcoLog(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🌳 Living Header with organic animations
  Widget _buildLivingHeader(Map<String, dynamic>? worldTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [
            _getSeasonColor(_currentSeason).withValues(alpha: 0.15),
            const Color(0xFF228B22).withValues(alpha: 0.08),
            const Color(0xFF32CD32).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getSeasonColor(_currentSeason),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getSeasonColor(_currentSeason).withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Living Tree Icon with growing animation
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Growing rings
                AnimatedBuilder(
                  animation: _growthController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.8 + 0.3 * math.sin(_growthController.value * 2 * math.pi),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF32CD32).withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Seasonal glow
                AnimatedBuilder(
                  animation: _seasonController,
                  builder: (context, child) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _getSeasonColor(_currentSeason).withValues(alpha: 0.6 + 0.2 * math.sin(_seasonController.value * 2 * math.pi)),
                            _getSeasonColor(_currentSeason).withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Central tree icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF228B22),
                        const Color(0xFF32CD32),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF32CD32).withValues(alpha: 0.5),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: _windController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: math.sin(_windController.value * 2 * math.pi) * 0.1,
                        child: const Icon(
                          Icons.park,
                          color: Colors.white,
                          size: 20,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          
          // Ecosystem Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.worldName ?? 'Enchanted Grove',
                  style: widget.theme.textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF228B22),
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF32CD32).withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '🌲 ${worldTheme?['atmosphere'] ?? 'enchanted-grove'} • ${worldTheme?['timeOfDay'] ?? 'dappled-sunlight'}',
                  style: widget.theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF32CD32),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '🎵 ${worldTheme?['ambientSound'] ?? 'forest-whispers'}',
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                    color: _getSeasonColor(_currentSeason),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Quick ecosystem vitals
                Row(
                  children: [
                    _buildVitalSign('HEALTH', _ecosystemHealth, const Color(0xFF32CD32)),
                    const SizedBox(width: 16),
                    _buildVitalSign('BIODIV', _biodiversity, const Color(0xFF9ACD32)),
                    const SizedBox(width: 16),
                    _buildVitalSign('SEASON', 25 * (_currentSeason == 'spring' ? 1 : _currentSeason == 'summer' ? 2 : _currentSeason == 'autumn' ? 3 : 4), _getSeasonColor(_currentSeason)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Ecosystem vital sign indicator
  Widget _buildVitalSign(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: widget.theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        AnimatedBuilder(
          animation: _lifeController,
          builder: (context, child) {
            return Text(
              label == 'SEASON' ? _currentSeason.toUpperCase() : '$value%',
              style: widget.theme.textTheme.bodySmall?.copyWith(
                color: Color.lerp(
                  color,
                  color.withValues(alpha: 0.7),
                  math.sin(_lifeController.value * 2 * math.pi) * 0.3 + 0.3,
                ) ?? color,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ],
    );
  }

  /// 🍂 Season Control Panel
  Widget _buildSeasonControl(Map<String, dynamic>? nature) {
    final seasons = nature?['seasons'] as Map<String, dynamic>? ?? {};
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _getSeasonColor(_currentSeason).withValues(alpha: 0.1),
            _getSeasonColor(_currentSeason).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getSeasonColor(_currentSeason),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _seasonController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _seasonController.value * 2 * math.pi,
                    child: Icon(
                      _getSeasonIcon(_currentSeason),
                      color: _getSeasonColor(_currentSeason),
                      size: 24,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                '🍂 SEASONAL CYCLE',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF228B22),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Season grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: seasons.entries.map((season) => _buildSeasonOption(season.key, season.value)).toList(),
          ),
        ],
      ),
    );
  }

  /// Season selection option
  Widget _buildSeasonOption(String seasonName, dynamic seasonData) {
    final isSelected = _currentSeason == seasonName;
    final seasonColor = Color(int.parse(seasonData['primaryColor'].substring(1), radix: 16) + 0xFF000000);
    
    return GestureDetector(
      onTap: () => setState(() => _currentSeason = seasonName),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isSelected ? RadialGradient(
            colors: [
              seasonColor.withValues(alpha: 0.3),
              seasonColor.withValues(alpha: 0.1),
            ],
          ) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? seasonColor : seasonColor.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: seasonColor.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _seasonController,
              builder: (context, child) {
                return Transform.scale(
                  scale: isSelected ? 1.0 + 0.2 * math.sin(_seasonController.value * 2 * math.pi) : 1.0,
                  child: Icon(
                    _getSeasonIcon(seasonName),
                    color: seasonColor,
                    size: 24,
                  ),
                );
              },
            ),
            const SizedBox(height: 6),
            Text(
              seasonName.toUpperCase(),
              style: widget.theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? seasonColor : Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🌲 Biome Explorer
  Widget _buildBiomeExplorer(Map<String, dynamic>? nature) {
    final biomes = nature?['biomes'] as Map<String, dynamic>? ?? {};
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF228B22).withValues(alpha: 0.1),
            const Color(0xFF32CD32).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getBiomeColor(_activeBiome, biomes),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.terrain,
                color: _getBiomeColor(_activeBiome, biomes),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '🌲 BIOME EXPLORER',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF228B22),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...biomes.entries.map((biome) => _buildBiomeOption(biome.key, biome.value)),
        ],
      ),
    );
  }

  /// Biome selection option
  Widget _buildBiomeOption(String biomeName, dynamic biomeData) {
    final isSelected = _activeBiome == biomeName;
    final biomeColor = Color(int.parse(biomeData['primaryColor'].substring(1), radix: 16) + 0xFF000000);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => setState(() => _activeBiome = biomeName),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? biomeColor.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? biomeColor : biomeColor.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _windController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      isSelected ? math.sin(_windController.value * 2 * math.pi) * 2 : 0,
                      0,
                    ),
                    child: Icon(
                      _getBiomeIcon(biomeName),
                      color: biomeColor,
                      size: 20,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  biomeName.toUpperCase(),
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected ? biomeColor : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              if (isSelected)
                AnimatedBuilder(
                  animation: _lifeController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + 0.3 * math.sin(_lifeController.value * 2 * math.pi),
                      child: Icon(
                        Icons.eco,
                        color: biomeColor,
                        size: 16,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🦋 Wildlife Tracker
  Widget _buildWildlifeTracker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            const Color(0xFF9ACD32).withValues(alpha: 0.1),
            const Color(0xFF32CD32).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF9ACD32),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _lifeController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      math.sin(_lifeController.value * 4 * math.pi) * 3,
                      math.cos(_lifeController.value * 3 * math.pi) * 2,
                    ),
                    child: const Icon(
                      Icons.pets,
                      color: Color(0xFF9ACD32),
                      size: 24,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                '🦋 WILDLIFE TRACKER',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF9ACD32),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Wildlife population display
          ...(_wildlifePopulation.entries.map((species) => _buildWildlifeSpecies(species.key, species.value))),
        ],
      ),
    );
  }

  /// Wildlife species display
  Widget _buildWildlifeSpecies(String species, int population) {
    final color = _getSpeciesColor(species);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _lifeController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + 0.1 * math.sin(_lifeController.value * 2 * math.pi + population * 0.01),
                    child: Icon(
                      _getSpeciesIcon(species),
                      color: color,
                      size: 18,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                species.toUpperCase(),
                style: widget.theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          AnimatedBuilder(
            animation: _growthController,
            builder: (context, child) {
              return Text(
                population.toString(),
                style: widget.theme.textTheme.bodyMedium?.copyWith(
                  color: Color.lerp(
                    color,
                    color.withValues(alpha: 0.7),
                    math.sin(_growthController.value * 2 * math.pi + population * 0.1) * 0.3 + 0.3,
                  ),
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 🌱 Growth Monitor with organic progress bars
  Widget _buildGrowthMonitor() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF228B22).withValues(alpha: 0.1),
            const Color(0xFF32CD32).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF228B22),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _growthController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + 0.2 * math.sin(_growthController.value * 2 * math.pi),
                    child: const Icon(
                      Icons.trending_up,
                      color: Color(0xFF228B22),
                      size: 24,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                '🌱 GROWTH MONITOR',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF228B22),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Growth indicators
          _buildGrowthIndicator('Forest Coverage', 78, const Color(0xFF228B22)),
          _buildGrowthIndicator('Flower Blooms', 65, const Color(0xFF9ACD32)),
          _buildGrowthIndicator('Tree Maturity', 89, const Color(0xFF32CD32)),
          _buildGrowthIndicator('Soil Health', 93, const Color(0xFF6B8E23)),
        ],
      ),
    );
  }

  /// Organic growth indicator
  Widget _buildGrowthIndicator(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: widget.theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '$value%',
                style: widget.theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 6,
                  color: color.withValues(alpha: 0.2),
                ),
                AnimatedBuilder(
                  animation: _growthController,
                  builder: (context, child) {
                    final growthValue = value / 100 * (1.0 + 0.1 * math.sin(_growthController.value * 2 * math.pi));
                    return FractionallySizedBox(
                      widthFactor: growthValue,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color,
                              color.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
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

  /// 🌍 Ecosystem Status
  Widget _buildEcosystemStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2A0F).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF32CD32),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _lifeController,
                builder: (context, child) {
                  return Icon(
                    Icons.eco,
                    color: Color.lerp(
                      const Color(0xFF32CD32),
                      const Color(0xFF9ACD32),
                      math.sin(_lifeController.value * 2 * math.pi) * 0.5 + 0.5,
                    ),
                    size: 24,
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                '🌍 ECO STATUS',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF32CD32),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Ecosystem health circle
          Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _growthController,
                    builder: (context, child) {
                      return CircularProgressIndicator(
                        value: (_ecosystemHealth / 100) * (1.0 + 0.05 * math.sin(_growthController.value * 2 * math.pi)),
                        strokeWidth: 6,
                        backgroundColor: const Color(0xFF0F2A0F),
                        valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF32CD32)),
                      );
                    },
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$_ecosystemHealth%',
                          style: widget.theme.textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF32CD32),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'HEALTHY',
                          style: widget.theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF9ACD32),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Status indicators
          _buildStatusIndicator('🌡️ TEMPERATURE', '${18 + math.Random().nextInt(8)}°C', const Color(0xFF9ACD32)),
          _buildStatusIndicator('💧 HUMIDITY', '${65 + math.Random().nextInt(20)}%', const Color(0xFF32CD32)),
          _buildStatusIndicator('🌬️ WIND SPEED', '${5 + math.Random().nextInt(10)} km/h', const Color(0xFF228B22)),
        ],
      ),
    );
  }

  /// Status indicator row
  Widget _buildStatusIndicator(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: widget.theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontSize: 11,
            ),
          ),
          Text(
            value,
            style: widget.theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  /// 📜 Eco Log
  Widget _buildEcoLog() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2A0F).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF228B22),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.article,
                color: Color(0xFF228B22),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '📜 ECO LOG',
                style: widget.theme.textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF228B22),
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
              itemCount: _ecoLog.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: AnimatedBuilder(
                    animation: _lifeController,
                    builder: (context, child) {
                      return Text(
                        _ecoLog[index],
                        style: TextStyle(
                          color: Color.lerp(
                            const Color(0xFF228B22),
                            const Color(0xFF32CD32),
                            (math.sin(_lifeController.value * 2 * math.pi + index * 0.5) * 0.3 + 0.7),
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
  Color _getSeasonColor(String seasonName) {
    switch (seasonName) {
      case 'spring': return const Color(0xFF9ACD32);
      case 'summer': return const Color(0xFF228B22);
      case 'autumn': return const Color(0xFFFF8C00);
      case 'winter': return const Color(0xFF2F4F4F);
      default: return const Color(0xFF32CD32);
    }
  }

  IconData _getSeasonIcon(String seasonName) {
    switch (seasonName) {
      case 'spring': return Icons.local_florist;
      case 'summer': return Icons.wb_sunny;
      case 'autumn': return Icons.eco;
      case 'winter': return Icons.ac_unit;
      default: return Icons.nature;
    }
  }

  Color _getBiomeColor(String biomeName, Map<String, dynamic> biomes) {
    try {
      final biomeData = biomes[biomeName];
      return Color(int.parse(biomeData['primaryColor'].substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return const Color(0xFF32CD32);
    }
  }

  IconData _getBiomeIcon(String biomeName) {
    switch (biomeName) {
      case 'deepwood': return Icons.forest;
      case 'meadow': return Icons.grass;
      case 'grove': return Icons.park;
      case 'swamp': return Icons.water;
      default: return Icons.terrain;
    }
  }

  Color _getSpeciesColor(String species) {
    switch (species) {
      case 'butterflies': return const Color(0xFFFF69B4);
      case 'birds': return const Color(0xFF87CEEB);
      case 'mammals': return const Color(0xFF8B4513);
      case 'insects': return const Color(0xFF9ACD32);
      default: return const Color(0xFF32CD32);
    }
  }

  IconData _getSpeciesIcon(String species) {
    switch (species) {
      case 'butterflies': return Icons.flutter_dash;
      case 'birds': return Icons.flutter_dash;
      case 'mammals': return Icons.pets;
      case 'insects': return Icons.bug_report;
      default: return Icons.pets;
    }
  }

  String _getRandomEcoMessage() {
    final messages = [
      '🌺 Rare orchid species discovered',
      '🐝 Bee colony established in sector 7',
      '🌳 Ancient oak shows new growth',
      '🦅 Migratory birds arriving',
      '🍄 Mushroom rings forming naturally',
      '🌿 Medicinal herbs blooming',
      '🐸 Frog populations increasing',
      '🌙 Night-blooming flowers detected'
    ];
    return messages[math.Random().nextInt(messages.length)];
  }
}
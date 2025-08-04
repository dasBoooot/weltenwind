import 'package:flutter/material.dart';


/// 🧙‍♂️ TOLKIEN ADVENTURE DASHBOARD
/// 
/// An immersive Middle-earth experience with dynamic fantasy elements!
class TolkienAdventureWidget extends StatefulWidget {
  final String? worldName;
  final int? worldId;
  final ThemeData theme;
  final Map<String, dynamic>? extensions;

  const TolkienAdventureWidget({
    super.key,
    required this.worldName,
    required this.worldId,
    required this.theme,
    required this.extensions,
  });

  @override
  State<TolkienAdventureWidget> createState() => _TolkienAdventureWidgetState();
}

class _TolkienAdventureWidgetState extends State<TolkienAdventureWidget>
    with TickerProviderStateMixin {
  late AnimationController _magicController;
  late AnimationController _questController;
  late Animation<double> _magicGlow;
  late Animation<double> _questPulse;

  final List<String> _fellowshipMembers = ['Frodo', 'Sam', 'Gandalf', 'Aragorn', 'Legolas'];
  int _selectedQuest = 0;
  final double _magicPower = 75.0;
  
  final List<Map<String, dynamic>> _quests = [
    {'name': 'Ring Bearer\'s Journey', 'progress': 0.8, 'danger': 'High', 'reward': 'One Ring'},
    {'name': 'White City Defense', 'progress': 0.6, 'danger': 'Medium', 'reward': 'Honor'},
    {'name': 'Shire Protection', 'progress': 0.9, 'danger': 'Low', 'reward': 'Peace'},
  ];

  @override
  void initState() {
    super.initState();
    
    _magicController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _questController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _magicGlow = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _magicController, curve: Curves.easeInOut),
    );
    
    _questPulse = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _questController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _magicController.dispose();
    _questController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fantasy = widget.extensions?['fantasy'] as Map<String, dynamic>? ?? {};
    // Use fantasy theme extension for mystical styling
    if (fantasy.isNotEmpty) {
      // Theme-specific customizations available
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildMiddleEarthHeader(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildFellowshipTracker()),
              const SizedBox(width: 24),
              Expanded(child: _buildMagicOrb()),
            ],
          ),
          const SizedBox(height: 24),
          _buildQuestTracker(),
          const SizedBox(height: 24),
          _buildMiddleEarthMap(),
        ],
      ),
    );
  }

  Widget _buildMiddleEarthHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.theme.colorScheme.primary.withValues(alpha: 0.2),
            widget.theme.colorScheme.secondary.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.theme.colorScheme.primary.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.theme.colorScheme.primary,
                  widget.theme.colorScheme.primary.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.worldName ?? "Middle-earth"} - Adventure Awaits',
                  style: widget.theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The One Ring must be destroyed. The fate of Middle-earth lies in your hands.',
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                    color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFellowshipTracker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.group, color: widget.theme.colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Fellowship Status',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._fellowshipMembers.map((member) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  member,
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                    color: widget.theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.favorite,
                  color: Colors.red.withValues(alpha: 0.7),
                  size: 16,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMagicOrb() {
    return AnimatedBuilder(
      animation: _magicGlow,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.theme.colorScheme.surface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.theme.colorScheme.primary.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: widget.theme.colorScheme.primary.withValues(alpha: _magicGlow.value * 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Magic Power',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.theme.colorScheme.primary.withValues(alpha: _magicGlow.value),
                      widget.theme.colorScheme.primary.withValues(alpha: 0.3),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    '${_magicPower.toInt()}%',
                    style: widget.theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestTracker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.explore, color: widget.theme.colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Active Quests',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._quests.asMap().entries.map((entry) {
            final index = entry.key;
            final quest = entry.value;
            return AnimatedBuilder(
              animation: _questPulse,
              builder: (context, child) {
                return Transform.scale(
                  scale: _selectedQuest == index ? _questPulse.value : 1.0,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedQuest = index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _selectedQuest == index 
                          ? widget.theme.colorScheme.primary.withValues(alpha: 0.2)
                          : widget.theme.colorScheme.surface.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedQuest == index 
                            ? widget.theme.colorScheme.primary
                            : widget.theme.colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  quest['name'],
                                  style: widget.theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: widget.theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getDangerColor(quest['danger']).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  quest['danger'],
                                  style: widget.theme.textTheme.bodySmall?.copyWith(
                                    color: _getDangerColor(quest['danger']),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: quest['progress'],
                            backgroundColor: widget.theme.colorScheme.primary.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation(widget.theme.colorScheme.primary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Reward: ${quest['reward']}',
                            style: widget.theme.textTheme.bodySmall?.copyWith(
                              color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMiddleEarthMap() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.map, color: widget.theme.colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Middle-earth Map',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                final locations = ['Shire', 'Rivendell', 'Moria', 'Gondor', 'Rohan', 'Mordor', 'Isengard', 'Fangorn'];
                return Container(
                  decoration: BoxDecoration(
                    color: widget.theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: widget.theme.colorScheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: Text(
                      locations[index],
                      style: widget.theme.textTheme.bodySmall?.copyWith(
                        color: widget.theme.colorScheme.onSurface,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getDangerColor(String danger) {
    switch (danger) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return widget.theme.colorScheme.primary;
    }
  }
}
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

/// 🚀 SPACE CONSOLE DASHBOARD
/// 
/// Orbital command center with real-time stellar phenomena and navigation!
class SpaceConsoleWidget extends StatefulWidget {
  final String? worldName;
  final int? worldId;
  final ThemeData theme;
  final Map<String, dynamic>? extensions;

  const SpaceConsoleWidget({
    super.key,
    required this.worldName,
    required this.worldId,
    required this.theme,
    required this.extensions,
  });

  @override
  State<SpaceConsoleWidget> createState() => _SpaceConsoleWidgetState();
}

class _SpaceConsoleWidgetState extends State<SpaceConsoleWidget>
    with TickerProviderStateMixin {
  late AnimationController _radarController;
  late AnimationController _starsController;
  late AnimationController _warpController;
  late Animation<double> _radarSweep;
  late Animation<double> _starTwinkle;
  late Animation<double> _warpPulse;

  Timer? _logTimer;
  List<String> _commandLog = [];
  int _selectedSystem = 0;
  double _warpCharge = 85.0;
  
  final List<Map<String, dynamic>> _stellarBodies = [
    {'name': 'Alpha Centauri', 'type': 'Star', 'distance': '4.37 ly', 'status': 'Stable'},
    {'name': 'Kepler-442b', 'type': 'Planet', 'distance': '1200 ly', 'status': 'Habitable'},
    {'name': 'Sagittarius A*', 'type': 'Black Hole', 'distance': '26000 ly', 'status': 'Active'},
  ];

  final List<String> _logMessages = [
    'Orbital mechanics stable',
    'Solar array efficiency: 97%',
    'Life support nominal',
    'Navigation systems online',
    'Quantum drive ready',
  ];

  @override
  void initState() {
    super.initState();
    
    _radarController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    _starsController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _warpController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _radarSweep = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(_radarController);
    _starTwinkle = Tween<double>(begin: 0.3, end: 1.0).animate(_starsController);
    _warpPulse = Tween<double>(begin: 0.8, end: 1.2).animate(_warpController);
    
    _startCommandLog();
  }

  void _startCommandLog() {
    _commandLog = [
      '> Orbital Command Center Online',
      '> All systems nominal',
      '> Awaiting orders...',
    ];
    
    _logTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_commandLog.length > 8) {
        _commandLog.removeAt(0);
      }
      setState(() {
        _commandLog.add('> ${_logMessages[math.Random().nextInt(_logMessages.length)]}');
      });
    });
  }

  @override
  void dispose() {
    _radarController.dispose();
    _starsController.dispose();
    _warpController.dispose();
    _logTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildSpaceHeader(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildRadarSystem()),
              const SizedBox(width: 24),
              Expanded(child: _buildWarpCore()),
            ],
          ),
          const SizedBox(height: 24),
          _buildStellarPhenomena(),
          const SizedBox(height: 24),
          _buildCommandLog(),
        ],
      ),
    );
  }

  Widget _buildSpaceHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0066CC).withValues(alpha: 0.2),
            const Color(0xFF9900FF).withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0066CC).withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFF0099FF), Color(0xFF003366)],
              ),
            ),
            child: const Icon(Icons.public, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.worldName ?? "Deep Space"} Command Center',
                  style: widget.theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0099FF),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore the cosmos. Chart new worlds. Command the void.',
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF66CCFF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarSystem() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF001122).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0099FF).withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(
            'Long Range Sensors',
            style: widget.theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0099FF),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: AnimatedBuilder(
              animation: _radarSweep,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(120, 120),
                  painter: RadarPainter(_radarSweep.value),
                );
              },
            ),
          ),
          Text(
            'Scanner Active',
            style: widget.theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF00FF88),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarpCore() {
    return AnimatedBuilder(
      animation: _warpPulse,
      builder: (context, child) {
        return Transform.scale(
          scale: _warpPulse.value,
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF001122).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF9900FF).withValues(alpha: 0.5)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Warp Core',
                  style: widget.theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF9900FF),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF9900FF).withValues(alpha: 0.8),
                        const Color(0xFF330066).withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${_warpCharge.toInt()}%',
                      style: widget.theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Core Stable',
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF00FF88),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStellarPhenomena() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF001122).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0099FF).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars, color: const Color(0xFF0099FF), size: 24),
              const SizedBox(width: 12),
              Text(
                'Stellar Phenomena',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0099FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._stellarBodies.asMap().entries.map((entry) {
            final index = entry.key;
            final body = entry.value;
            return GestureDetector(
              onTap: () => setState(() => _selectedSystem = index),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _selectedSystem == index 
                    ? const Color(0xFF0099FF).withValues(alpha: 0.2)
                    : const Color(0xFF002244).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedSystem == index 
                      ? const Color(0xFF0099FF)
                      : const Color(0xFF004488).withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getBodyColor(body['type']),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            body['name'],
                            style: widget.theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0099FF),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${body['type']} • ${body['distance']} • ${body['status']}',
                            style: widget.theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF66CCFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCommandLog() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0099FF).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.terminal, color: const Color(0xFF0099FF), size: 24),
              const SizedBox(width: 12),
              Text(
                'Command Log',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0099FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _commandLog.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    _commandLog[index],
                    style: const TextStyle(
                      color: Color(0xFF0099FF),
                      fontFamily: 'Courier',
                      fontSize: 12,
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

  Color _getBodyColor(String type) {
    switch (type) {
      case 'Star':
        return const Color(0xFFFFAA00);
      case 'Planet':
        return const Color(0xFF00FF88);
      case 'Black Hole':
        return const Color(0xFF9900FF);
      default:
        return const Color(0xFF66CCFF);
    }
  }
}

class RadarPainter extends CustomPainter {
  final double sweepAngle;

  RadarPainter(this.sweepAngle);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw radar circles
    final circlePaint = Paint()
      ..color = const Color(0xFF0099FF).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * i / 3, circlePaint);
    }

    // Draw cross lines
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      circlePaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      circlePaint,
    );

    // Draw sweep line
    final sweepPaint = Paint()
      ..color = const Color(0xFF00FF88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final sweepEnd = Offset(
      center.dx + radius * math.cos(sweepAngle - math.pi / 2),
      center.dy + radius * math.sin(sweepAngle - math.pi / 2),
    );
    canvas.drawLine(center, sweepEnd, sweepPaint);

    // Draw random dots (contacts)
    final dotPaint = Paint()
      ..color = const Color(0xFF00FF88)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final angle = math.Random().nextDouble() * 2 * math.pi;
      final distance = math.Random().nextDouble() * radius;
      final dotPos = Offset(
        center.dx + distance * math.cos(angle),
        center.dy + distance * math.sin(angle),
      );
      canvas.drawCircle(dotPos, 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
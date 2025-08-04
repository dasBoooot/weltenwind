import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

/// 🌐 CYBERPUNK HACKING DASHBOARD
/// 
/// Neural interface with real-time hacking simulation and neon aesthetics!
class CyberpunkHackingWidget extends StatefulWidget {
  final String? worldName;
  final int? worldId;
  final ThemeData theme;
  final Map<String, dynamic>? extensions;

  const CyberpunkHackingWidget({
    super.key,
    required this.worldName,
    required this.worldId,
    required this.theme,
    required this.extensions,
  });

  @override
  State<CyberpunkHackingWidget> createState() => _CyberpunkHackingWidgetState();
}

class _CyberpunkHackingWidgetState extends State<CyberpunkHackingWidget>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _glitchController;
  late AnimationController _terminalController;
  late Animation<double> _scanAnimation;
  late Animation<double> _glitchAnimation;
  late Animation<double> _terminalBlink;

  Timer? _hackingTimer;
  List<String> _terminalLines = [];
  int _hackingProgress = 0;
  bool _isHacking = false;
  
  final List<Map<String, dynamic>> _networks = [
    {'name': 'CORP-NET-01', 'security': 'High', 'reward': '₿ 2500', 'status': 'Protected'},
    {'name': 'DATA-VAULT-7', 'security': 'Medium', 'reward': '₿ 1200', 'status': 'Breached'},
    {'name': 'STREET-CAM-X', 'security': 'Low', 'reward': '₿ 350', 'status': 'Accessible'},
  ];

  final List<String> _hackingMessages = [
    '> Initiating neural link...',
    '> Scanning for vulnerabilities...',
    '> Bypassing firewall [████████  ] 89%',
    '> Injecting payload...',
    '> Access granted. Data streaming...',
    '> Cryptocurrency extracted successfully',
    '> Disconnecting to avoid trace...',
  ];

  @override
  void initState() {
    super.initState();
    
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _glitchController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _terminalController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_scanController);
    _glitchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_glitchController);
    _terminalBlink = Tween<double>(begin: 0.3, end: 1.0).animate(_terminalController);
    
    _initTerminal();
  }

  void _initTerminal() {
    _terminalLines = [
      '> Neural interface active',
      '> Scanning local networks...',
      '> 3 targets identified',
      '> Ready for operation',
    ];
  }

  void _startHacking() {
    if (_isHacking) return;
    
    setState(() {
      _isHacking = true;
      _hackingProgress = 0;
      _terminalLines.clear();
    });
    
    _glitchController.repeat();
    
    _hackingTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (_hackingProgress >= _hackingMessages.length) {
        timer.cancel();
        setState(() {
          _isHacking = false;
          _hackingProgress = 0;
        });
        _glitchController.stop();
        _initTerminal();
        return;
      }
      
      setState(() {
        _terminalLines.add(_hackingMessages[_hackingProgress]);
        _hackingProgress++;
      });
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _glitchController.dispose();
    _terminalController.dispose();
    _hackingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cyberpunk = widget.extensions?['cyberpunk'] as Map<String, dynamic>? ?? {};
    // Use cyberpunk theme extension for advanced styling
    if (cyberpunk.isNotEmpty) {
      // Theme-specific customizations available
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildNeuralHeader(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildNetworkScanner()),
              const SizedBox(width: 24),
              Expanded(child: _buildSystemStatus()),
            ],
          ),
          const SizedBox(height: 24),
          _buildHackingTerminal(),
          const SizedBox(height: 24),
          _buildCyberGrid(),
        ],
      ),
    );
  }

  Widget _buildNeuralHeader() {
    return AnimatedBuilder(
      animation: _glitchAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: _isHacking 
            ? Offset(math.Random().nextDouble() * 4 - 2, 0)
            : Offset.zero,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00FF88).withValues(alpha: 0.2),
                  const Color(0xFF0088FF).withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00FF88).withValues(alpha: 0.7)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FF88).withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0xFF00FF88), Color(0xFF004422)],
                    ),
                  ),
                  child: const Icon(Icons.memory, color: Colors.black, size: 30),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.worldName ?? "Neo-Tokyo"} Neural Network',
                        style: widget.theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00FF88),
                          fontFamily: 'Courier',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Jack into the matrix. Hack the planet. Own the grid.',
                        style: widget.theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF88CCFF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNetworkScanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00FF88).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radar, color: Color(0xFF00FF88), size: 24),
              const SizedBox(width: 12),
              Text(
                'Network Scanner',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00FF88),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._networks.map((network) => Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF001122).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _getSecurityColor(network['security']).withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        network['name'],
                        style: widget.theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF00FF88),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getSecurityColor(network['security']).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        network['security'],
                        style: widget.theme.textTheme.bodySmall?.copyWith(
                          color: _getSecurityColor(network['security']),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Reward: ${network['reward']}',
                      style: widget.theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF88CCFF),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      network['status'],
                      style: widget.theme.textTheme.bodySmall?.copyWith(
                        color: network['status'] == 'Breached' 
                          ? const Color(0xFF00FF88)
                          : const Color(0xFFFFAA00),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSystemStatus() {
    return AnimatedBuilder(
      animation: _scanAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF0088FF).withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Text(
                'System Status',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0088FF),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0088FF), width: 3),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        'ONLINE',
                        style: widget.theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00FF88),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: CircularProgressIndicator(
                        value: _scanAnimation.value,
                        strokeWidth: 2,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF00FF88)),
                        backgroundColor: const Color(0xFF004422),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isHacking ? null : _startHacking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF88),
                  foregroundColor: Colors.black,
                ),
                child: Text(_isHacking ? 'HACKING...' : 'INITIATE HACK'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHackingTerminal() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00FF88).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal, color: Color(0xFF00FF88), size: 24),
              const SizedBox(width: 12),
              Text(
                'Hacking Terminal',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00FF88),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _terminalLines.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      if (index == _terminalLines.length - 1 && _isHacking)
                        AnimatedBuilder(
                          animation: _terminalBlink,
                          builder: (context, child) {
                            return Text(
                              _terminalLines[index],
                              style: TextStyle(
                                color: Color.lerp(
                                  const Color(0xFF00FF88),
                                  const Color(0xFF88CCFF),
                                  _terminalBlink.value,
                                ),
                                fontFamily: 'Courier',
                                fontSize: 12,
                              ),
                            );
                          },
                        )
                      else
                        Text(
                          _terminalLines[index],
                          style: const TextStyle(
                            color: Color(0xFF00FF88),
                            fontFamily: 'Courier',
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCyberGrid() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0088FF).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.grid_view, color: Color(0xFF0088FF), size: 24),
              const SizedBox(width: 12),
              Text(
                'Cyber Grid',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0088FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: 24,
              itemBuilder: (context, index) {
                final isActive = math.Random().nextBool();
                return Container(
                  decoration: BoxDecoration(
                    color: isActive 
                      ? const Color(0xFF00FF88).withValues(alpha: 0.3)
                      : const Color(0xFF001122).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isActive 
                        ? const Color(0xFF00FF88)
                        : const Color(0xFF004422),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      isActive ? Icons.circle : Icons.circle_outlined,
                      color: isActive 
                        ? const Color(0xFF00FF88)
                        : const Color(0xFF004422),
                      size: 12,
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

  Color _getSecurityColor(String security) {
    switch (security) {
      case 'High':
        return const Color(0xFFFF0044);
      case 'Medium':
        return const Color(0xFFFFAA00);
      case 'Low':
        return const Color(0xFF00FF88);
      default:
        return const Color(0xFF0088FF);
    }
  }
}
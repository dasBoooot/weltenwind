import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../config/logger.dart';
import '../../theme/background_widget.dart';

class SplashScreen extends StatefulWidget {
  final Future<void> Function() initializationFunction;
  final Widget child;
  final String? loadingText;
  final Duration? timeout;
  final VoidCallback? onTimeout;
  final List<String>? initSteps;
  final String? appName;
  final Widget? logo;

  const SplashScreen({
    super.key,
    required this.initializationFunction,
    required this.child,
    this.loadingText,
    this.timeout,
    this.onTimeout,
    this.initSteps,
    this.appName = 'Weltenwind',
    this.logo,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isInitialized = false;
  String? _error;
  bool _timedOut = false;
  int _currentStepIndex = 0;
  String? _currentStepName;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _animationController.forward();
      
      // Timeout für Initialisierung
      final timeout = widget.timeout;
      if (timeout != null) {
        final result = await Future.any([
          _runInitializationWithSteps().then((_) => 'success'),
          Future.delayed(timeout).then((_) {
            AppLogger.app.w('⏰ SplashScreen Initialisierung timeout');
            return 'timeout';
          }),
        ]);
        
        if (result == 'timeout') {
          _timedOut = true;
          final onTimeout = widget.onTimeout;
          if (onTimeout != null) {
            onTimeout();
          }
        }
      } else {
        await _runInitializationWithSteps();
      }
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        
        // Kurze Verzögerung für smooth Transition
        await Future.delayed(const Duration(milliseconds: 500));
        
        // KEIN reverse() mehr - das hat die App ausgeblendet!
        // _animationController.reverse(); // ENTFERNT
      }
    } catch (e) {
      AppLogger.logError('SplashScreen Initialisierung fehlgeschlagen', e);
      
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _runInitializationWithSteps() async {
    final initSteps = widget.initSteps;
    if (initSteps != null && initSteps.isNotEmpty) {
      for (int i = 0; i < initSteps.length; i++) {
        if (mounted) {
          setState(() {
            _currentStepIndex = i;
            _currentStepName = initSteps[i];
          });
        }
        
        // Simuliere Schritt-für-Schritt Initialisierung
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
    
    // Führe die eigentliche Initialisierung aus
    await widget.initializationFunction();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorScreen();
    }
    
    if (_isInitialized) {
      // Direkt das Child anzeigen ohne FadeTransition die ausblendet
      return widget.child;
    }
    
    return _buildSplashScreen();
  }

  Widget _buildSplashScreen() {
    final initSteps = widget.initSteps;
    final loadingText = widget.loadingText;
    
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon
            widget.logo ?? Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.public,
                size: 60,
                color: Colors.blue,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // App Name
            Text(
              widget.appName ?? 'App',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Progress Indicator mit Steps
            if (initSteps != null && initSteps.isNotEmpty) ...[
              // Progress Bar
              Container(
                width: 200,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (_currentStepIndex + 1) / initSteps.length,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Current Step Text
              if (_currentStepName != null)
                Text(
                  _currentStepName ?? 'Initialisiere...',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              
              const SizedBox(height: 20),
            ] else ...[
              // Standard Loading Indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
            
            if (loadingText != null) ...[
              const SizedBox(height: 20),
              Text(
                loadingText,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
            
            // Timeout Warning
            if (_timedOut) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: const Text(
                  'Initialisierung dauert länger als erwartet...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red.shade400,
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                'Initialisierungsfehler',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 10),
              
              Text(
                _error ?? 'Unbekannter Fehler',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 30),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _error = null;
                        _isInitialized = false;
                        _timedOut = false;
                        _currentStepIndex = 0;
                        _currentStepName = null;
                      });
                      _initialize();
                    },
                    child: const Text('Erneut versuchen'),
                  ),
                  
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _error = null;
                        _isInitialized = true;
                      });
                    },
                    child: const Text('Überspringen'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
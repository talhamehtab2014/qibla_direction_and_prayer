import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qibla_direction/providers/remote_config_provider.dart';
import 'package:qibla_direction/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();

    // Navigate to home screen after initialization
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Wait for at least 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remoteConfig = Provider.of<RemoteConfigProvider>(context);
    final isRamadan = remoteConfig.showRamadanCalendar;

    // Theme Colors (Emerald/Green branding)
    final List<Color> colors = isDark
        ? [const Color(0xFF1E1E1E), const Color(0xFF2C5F2D)]
        : [const Color(0xFF2E7D32), const Color(0xFF66BB6A)];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: Stack(
          children: [
            // Subtle Background Pattern for Ramadan
            if (isRamadan)
               Positioned(
                 top: -50,
                 right: -50,
                 child: Opacity(
                   opacity: 0.1,
                   child: Icon(
                     Icons.nightlight_round,
                     size: 250,
                     color: Colors.amber[100],
                   ),
                 ),
               ),
            
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Decorative Glow for Ramadan
                              if (isRamadan)
                                Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.amber.withOpacity(0.2),
                                        blurRadius: 40,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(30),
                                  border: isRamadan 
                                    ? Border.all(color: Colors.amber.withOpacity(0.3), width: 2)
                                    : null,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'Iman360',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isRamadan) ...[
                          const SizedBox(height: 8),
                          Text(
                            'RAMADAN KAREEM',
                            style: TextStyle(
                              color: Colors.amber[200],
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      isRamadan ? 'Gathering Blessings.' : 'Faith in Every Direction.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

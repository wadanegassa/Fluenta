import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _waveController;
  double _loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    
    // 1. Initial brand name fade-in transition
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutBack,
    );
    
    // 2. Continuous voice pulse waveform animation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _fadeController.forward();
    _startLoadingSimulation();
    _handleNavigation();
  }

  void _startLoadingSimulation() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _loadingProgress = 0.3);
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _loadingProgress = 0.7);
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _loadingProgress = 1.0);
    });
  }

  Future<void> _handleNavigation() async {
    // Elegant 2.2 second wait for users to enjoy the branding animations
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      final userId = session.user.id;
      try {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('level, goal, native_language')
            .eq('id', userId)
            .maybeSingle();

        if (!mounted) return;

        if (profile == null) {
          context.go('/onboarding');
        } else if (profile['goal'] == null || profile['native_language'] == null) {
          context.go('/setup');
        } else if (profile['level'] == 'unassigned') {
          context.go('/placement');
        } else {
          context.go('/home');
        }
      } catch (_) {
        if (mounted) context.go('/onboarding');
      }
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F172A), // Deep Obsidian Blue
              Color(0xFF1E1B4B), // Premium Indigo
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Center Brand Content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.85, end: 1.0).animate(_fadeAnimation),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Elegant Voice Pulse Visualizer Icon
                      AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              final double heightFactor = [0.4, 0.75, 1.0, 0.75, 0.4][index];
                              final double currentPulse = heightFactor * 
                                  (0.3 + 0.7 * (0.5 + 0.5 * MathHelper.sinWave(_waveController.value * 2 * 3.1415 + (index * 0.8))));
                              
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: 4.5,
                                height: 48 * currentPulse,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF38BDF8), // Turquoise
                                      Color(0xFFC084FC), // Lavender Accent
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFC084FC).withOpacity(0.3),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    )
                                  ]
                                ),
                              );
                            }),
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                      // Premium Voce Logo
                      Text(
                        'Voce',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 54,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.25),
                              offset: const Offset(0, 4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Modern subtitle
                      Text(
                        'AI-POWERED VOICE COMPANION',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF38BDF8),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom Loading Indicator Panel
            Positioned(
              bottom: 60,
              left: 48,
              right: 48,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Thin premium progress track
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 3,
                        color: Colors.white.withOpacity(0.08),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: MediaQuery.of(context).size.width * 0.7 * _loadingProgress,
                            height: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF38BDF8),
                                  Color(0xFFC084FC),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Secure Connection Initialized",
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Inline Math Helper to keep execution self-contained and performant
class MathHelper {
  static double sinWave(double radians) {
    // Precision approximation of native sine waves for high performance UI loops
    double x = radians % (2 * 3.1415926535);
    if (x < 0) x += 2 * 3.1415926535;
    double sinVal = 0.0;
    double term = x;
    double power = x;
    double fact = 1.0;
    for (int i = 1; i <= 7; i += 2) {
      if (i % 4 == 1) {
        sinVal += power / fact;
      } else {
        sinVal -= power / fact;
      }
      power *= x * x;
      fact *= (i + 1) * (i + 2);
    }
    return sinVal;
  }
}

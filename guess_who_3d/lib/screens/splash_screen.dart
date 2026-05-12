import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  double _progress = 0.0;
  String _statusText = 'Initializing Board';
  String _subStatusText = 'Fetching player avatars...';
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  final List<Map<String, String>> _loadingStages = [
    {'status': 'Initializing Board', 'sub': 'Fetching player avatars...'},
    {'status': 'Loading Characters', 'sub': 'Preparing game assets...'},
    {'status': 'Setting Up Arena', 'sub': 'Almost ready to play!'},
    {'status': 'Ready!', 'sub': 'Starting game...'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _simulateLoading();
  }

  void _simulateLoading() {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _progress += 0.015;
        if (_progress > 1.0) _progress = 1.0;

        int stageIndex = (_progress * (_loadingStages.length - 1)).floor();
        if (stageIndex >= _loadingStages.length) {
          stageIndex = _loadingStages.length - 1;
        }
        _statusText = _loadingStages[stageIndex]['status']!;
        _subStatusText = _loadingStages[stageIndex]['sub']!;
      });

      if (_progress >= 1.0) {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient and pattern
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryContainer.withValues(alpha: 0.1),
                  AppColors.surface,
                  AppColors.primaryFixedDim.withValues(alpha: 0.15),
                ],
              ),
            ),
          ),
          // Dot pattern overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _DotPatternPainter(),
            ),
          ),

          // Top App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                left: 20,
                right: 20,
                bottom: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.85),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.videogame_asset,
                          color: AppColors.primary, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'GUESS WHO 3D',
                        style: AppTheme.headlineMd.copyWith(
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings,
                        color: AppColors.onSurfaceVariant, size: 28),
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 80),

                  // Game Logo
                  Column(
                    children: [
                      Text(
                        'GUESS',
                        style: AppTheme.headlineLg.copyWith(
                          fontSize: 56,
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2,
                          shadows: [
                            const Shadow(
                              color: AppColors.onPrimaryContainer,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Text(
                          'WHO?',
                          style: AppTheme.headlineLg.copyWith(
                            fontSize: 42,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -2,
                            shadows: [
                              const Shadow(
                                color: AppColors.onSecondaryFixed,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Character Image
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulsing glow ring
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 280,
                                height: 280,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                ),
                              ),
                            );
                          },
                        ),
                        // Dashed ring
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              width: 3,
                            ),
                          ),
                        ),
                        // Character
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuAQENvbVffY5in9FHvM2H2UoeNzfrmpxr4hJCwNXRu6pOvwc_SwtQD6TPrdLdZgGXPu3iByKYnylGgij-z4kwtjlki_IS6WUmJpjKSEPmwUyiaOOv7phvCTI4b5mGkTypVlRv-qyTDoiBGK-NjrefctVSienoT-0OByjYQDPBAR3UpGt1dITCLMA8mC0dzRWqFamlRTOt8awdYxDylAVRB8uTNgjWpWyeaxplmrxa8eKqDJCmYHJOGNAUCO_1NgneErQmGXKoxwfuJt',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.primaryContainer,
                                  child: const Icon(
                                    Icons.person_search,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // Floating "SEARCHING..." badge
                        Positioned(
                          top: 10,
                          right: 20,
                          child: Transform.rotate(
                            angle: 0.2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.tertiaryFixed,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                border: const Border(
                                  bottom: BorderSide(
                                    color: AppColors.tertiary,
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.search,
                                      size: 16,
                                      color: AppColors.onTertiaryFixed),
                                  const SizedBox(width: 4),
                                  Text(
                                    'SEARCHING...',
                                    style: AppTheme.labelBold.copyWith(
                                      color: AppColors.onTertiaryFixed,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Floating "IDENTIFYING" badge
                        Positioned(
                          bottom: 40,
                          left: 10,
                          child: Transform.rotate(
                            angle: -0.1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryContainer,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                border: const Border(
                                  bottom: BorderSide(
                                    color: AppColors.onSecondaryFixedVariant,
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.person,
                                      size: 16,
                                      color: AppColors.onSecondaryContainer),
                                  const SizedBox(width: 4),
                                  Text(
                                    'IDENTIFYING',
                                    style: AppTheme.labelBold.copyWith(
                                      color: AppColors.onSecondaryContainer,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _statusText.toUpperCase(),
                                  style: AppTheme.labelBold.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _subStatusText,
                                  style: AppTheme.bodyMd.copyWith(
                                    color: AppColors.onSurfaceVariant
                                        .withValues(alpha: 0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${(_progress * 100).toInt()}%',
                              style: AppTheme.headlineMd.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Glossy progress bar
                        Container(
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                offset: const Offset(0, 3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(3),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                // Progress fill
                                FractionallySizedBox(
                                  widthFactor: _progress,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.black.withValues(alpha: 0.2),
                                          offset: const Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        // Glossy overlay
                                        Positioned.fill(
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.white
                                                      .withValues(alpha: 0.35),
                                                  Colors.white
                                                      .withValues(alpha: 0.0),
                                                  Colors.black
                                                      .withValues(alpha: 0.08),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Shimmer
                                        AnimatedBuilder(
                                          animation: _shimmerAnimation,
                                          builder: (context, child) {
                                            return Positioned(
                                              left: 0,
                                              right: 0,
                                              top: 0,
                                              bottom: 0,
                                              child: Transform.translate(
                                                offset: Offset(
                                                  _shimmerAnimation.value * 200,
                                                  0,
                                                ),
                                                child: Container(
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.white
                                                            .withValues(
                                                                alpha: 0.0),
                                                        Colors.white
                                                            .withValues(
                                                                alpha: 0.25),
                                                        Colors.white
                                                            .withValues(
                                                                alpha: 0.0),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tip banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBright.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(24),
                        border:
                            Border.all(color: AppColors.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lightbulb_outline,
                              color: AppColors.tertiary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "TIP: Knock down cards you're sure about!",
                            style: AppTheme.bodyMd.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Bottom Nav
                  BottomNavBar(
                    currentIndex: 1,
                    onTap: (i) {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryContainer.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

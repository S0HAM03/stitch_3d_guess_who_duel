import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlossyButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final VoidCallback? onTap;
  final double height;

  const GlossyButton({
    super.key,
    required this.label,
    this.icon,
    required this.color,
    this.onTap,
    this.height = 72,
  });

  @override
  State<GlossyButton> createState() => _GlossyButtonState();
}

class _GlossyButtonState extends State<GlossyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(0, _isPressed ? 4 : 0, 0),
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              offset: Offset(0, _isPressed ? 2 : 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Glossy sheen overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.35),
                      Colors.white.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.1),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Top shine line
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
            ),
            // Content
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    widget.label,
                    style: AppTheme.buttonText.copyWith(
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          offset: const Offset(0, 1),
                        ),
                      ],
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

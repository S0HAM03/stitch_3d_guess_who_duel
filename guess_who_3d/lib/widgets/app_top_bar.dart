import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? trailing;

  const AppTopBar({super.key, this.trailing});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.videogame_asset,
                  color: AppColors.primary,
                  size: 28,
                ),
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
            trailing ??
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.settings,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

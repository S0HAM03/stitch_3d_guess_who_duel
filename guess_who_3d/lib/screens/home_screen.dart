import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/join_lobby_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE8F0FE), Color(0xFFF8F9FD), Color(0xFFFFF8E1)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        _buildHeroBanner(),
                        const SizedBox(height: 20),
                        _buildActionButtons(context),
                        const SizedBox(height: 24),
                        _buildRulesSection(),
                        const SizedBox(height: 24),
                        _buildStatsRow(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                BottomNavBar(currentIndex: 0, onTap: (i) {
                  if (i == 1) Navigator.pushNamed(context, '/category');
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A73E8), Color(0xFF0052CC)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            const Icon(Icons.videogame_asset, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            Text('GUESS WHO 3D', style: AppTheme.headlineMd.copyWith(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
          ]),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
              child: Consumer<GameState>(
                builder: (context, gameState, _) => Row(children: [
                  const Icon(Icons.stars, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text('${gameState.gems}', style: AppTheme.labelBold.copyWith(color: Colors.white, fontSize: 12)),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showSettingsDialog(context),
              child: const Icon(Icons.settings, color: Colors.white70, size: 24),
            ),
          ]),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: Icon(Icons.volume_up), title: Text('Sound Effects')),
            ListTile(leading: Icon(Icons.notifications), title: Text('Notifications')),
            ListTile(leading: Icon(Icons.info), title: Text('App Version: 0.1.0')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        Expanded(child: Consumer<GameState>(
          builder: (context, gameState, _) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFB9082C).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Text('BEGINNER RANK', style: AppTheme.labelBold.copyWith(color: const Color(0xFFB9082C), fontSize: 11)),
            ),
            const SizedBox(height: 8),
            Text(gameState.localPlayerName.isEmpty ? 'Guest Player' : gameState.localPlayerName, style: AppTheme.headlineMd.copyWith(color: AppColors.onSurface, fontSize: 24)),
            const SizedBox(height: 4),
            Row(children: [
              _StatPill(value: '${gameState.wins}', label: 'Wins', color: const Color(0xFF1A73E8)),
              const SizedBox(width: 8),
              _StatPill(value: '${gameState.gamesPlayed}', label: 'Games', color: const Color(0xFFB9082C)),
              const SizedBox(width: 8),
              _StatPill(value: gameState.gamesPlayed > 0 ? '${(gameState.wins / gameState.gamesPlayed * 100).toInt()}%' : '0%', label: 'WR', color: Colors.green),
            ]),
          ]),
        )),
        const SizedBox(width: 14),
        // Avatar
        Stack(clipBehavior: Clip.none, children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1A73E8), width: 3),
              boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 12)],
            ),
            child: ClipOval(child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAaCXN_JGMnBKYxEU834rcZy1akTXv9e6AhSfBdPeAoF8WIVn2Ay1RdNkt3k5sFaMKnDFH0sa1cbLzz79ieULb8Sx1So02t3Vw5WzDEayT7hWeScoywYf1DPxciCU4SNdkX-PsKqd6b6HBamut5PywoF--hbf5He2ke8g2qgMEnPisqjSPzuG5CuLizUlO1dvdGI26omyS067visP51OgWwLHO2LhLxQhmp0qs5GkTFq8bVW5NBXJezYVE42obBRX5X-xShs6Q-UN5V',
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: const Color(0xFF1A73E8).withValues(alpha: 0.2), child: const Icon(Icons.person, size: 48, color: Color(0xFF1A73E8))),
            )),
          ),
          Positioned(bottom: 0, right: 0, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFFB9082C), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white, width: 2)),
            child: Text('12', style: AppTheme.labelBold.copyWith(color: Colors.white, fontSize: 10)),
          )),
        ]),
      ]),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(children: [
      // HOST button
      GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/category'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1A73E8), Color(0xFF0052CC)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.blue.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 5)),
              BoxShadow(color: Colors.white.withValues(alpha: 0.15), blurRadius: 1, offset: const Offset(0, -1)),
            ],
            border: const Border(top: BorderSide(color: Colors.white38, width: 1.5)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: const Icon(Icons.add_circle_rounded, color: Colors.white, size: 22)),
            const SizedBox(width: 12),
            Text('HOST GAME', style: AppTheme.buttonText.copyWith(color: Colors.white, fontSize: 18, letterSpacing: 1.5)),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      // JOIN button
      GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (_) => const JoinLobbySheet(),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFB9082C), Color(0xFF7A0010)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.red.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 5)),
              BoxShadow(color: Colors.white.withValues(alpha: 0.1), blurRadius: 1, offset: const Offset(0, -1)),
            ],
            border: const Border(top: BorderSide(color: Colors.white24, width: 1.5)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: const Icon(Icons.sports_esports_rounded, color: Colors.white, size: 22)),
            const SizedBox(width: 12),
            Text('JOIN GAME', style: AppTheme.buttonText.copyWith(color: Colors.white, fontSize: 18, letterSpacing: 1.5)),
          ]),
        ),
      ),
    ]);
  }

  Widget _buildRulesSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('HOW TO PLAY', style: AppTheme.labelBold.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 2.5, fontSize: 12)),
      const SizedBox(height: 12),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          _RuleCard(icon: Icons.person_search, title: 'Pick Secret', description: 'Choose your mystery card.', color: Colors.blue),
          const SizedBox(width: 12),
          _RuleCard(icon: Icons.question_answer, title: 'Ask Questions', description: 'Ask YES/NO questions.', color: Colors.orange),
          const SizedBox(width: 12),
          _RuleCard(icon: Icons.check_circle, title: 'Eliminate', description: 'Knock down characters.', color: Colors.green),
          const SizedBox(width: 12),
          _RuleCard(icon: Icons.emoji_events, title: 'Win Game', description: 'Guess first to win!', color: Colors.purple),
        ]),
      ),
    ]);
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('YOUR STATS', style: AppTheme.labelBold.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 2)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFB9082C).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Text('SEASON 1', style: AppTheme.labelBold.copyWith(color: const Color(0xFFB9082C), fontSize: 10))),
        ]),
        const SizedBox(height: 14),
        Consumer<GameState>(
          builder: (context, gameState, _) => Row(children: [
            _BigStatBox(value: '${gameState.wins}', label: 'WINS', icon: Icons.emoji_events_rounded, color: const Color(0xFF1A73E8)),
            const SizedBox(width: 10),
            _BigStatBox(value: '${gameState.gamesPlayed}', label: 'PLAYED', icon: Icons.sports_esports_rounded, color: const Color(0xFF735C00)),
            const SizedBox(width: 10),
            _BigStatBox(value: '${gameState.gems}', label: 'GEMS', icon: Icons.diamond_rounded, color: Colors.purple),
          ]),
        ),
      ]),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatPill({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(value, style: AppTheme.labelBold.copyWith(color: color, fontSize: 12)),
        const SizedBox(width: 3),
        Text(label, style: AppTheme.bodyMd.copyWith(color: color.withValues(alpha: 0.8), fontSize: 11)),
      ]),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final IconData icon;
  final String title, description;
  final Color color;
  const _RuleCard({required this.icon, required this.title, required this.description, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: AppTheme.labelBold.copyWith(color: AppColors.onSurface, fontSize: 13)),
          const SizedBox(height: 4),
          Text(description, style: AppTheme.bodyMd.copyWith(color: AppColors.onSurfaceVariant, fontSize: 11)),
        ],
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final String emoji, label;
  final List<Color> gradient;
  final Color borderColor;
  const _TopicCard({required this.emoji, required this.label, required this.gradient, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [BoxShadow(color: borderColor.withValues(alpha: 0.15), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 6),
        Text(label, textAlign: TextAlign.center, style: AppTheme.labelBold.copyWith(color: AppColors.onSurface, fontSize: 12)),
      ]),
    );
  }
}

class _BigStatBox extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _BigStatBox({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value, style: AppTheme.headlineMd.copyWith(color: color, fontSize: 22)),
        Text(label, style: AppTheme.labelBold.copyWith(color: color.withValues(alpha: 0.7), fontSize: 10)),
      ]),
    ));
  }
}

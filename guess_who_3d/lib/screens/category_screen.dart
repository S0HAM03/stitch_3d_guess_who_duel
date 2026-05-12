import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../data/characters_data.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with SingleTickerProviderStateMixin {
  String? _selected;
  late AnimationController _controller;

  final List<_CategoryData> _categories = [
    _CategoryData(
      id: 'default',
      emoji: '🎭',
      title: 'Classic Mix',
      subtitle: '20 fun & quirky characters',
      gradient: [const Color(0xFF1A73E8), const Color(0xFF0052CC)],
      borderColor: const Color(0xFF1A73E8),
    ),
    _CategoryData(
      id: 'celebrities',
      emoji: '🎬',
      title: 'Indian Celebrities',
      subtitle: 'SRK, Deepika, Ranveer & more',
      gradient: [const Color(0xFFB9082C), const Color(0xFF7A0010)],
      borderColor: const Color(0xFFB9082C),
    ),
    _CategoryData(
      id: 'cricketers',
      emoji: '🏏',
      title: 'Indian Cricketers',
      subtitle: 'Virat, Rohit, Dhoni & more',
      gradient: [const Color(0xFF2E7D32), const Color(0xFF1B5E20)],
      borderColor: const Color(0xFF388E3C),
    ),
    _CategoryData(
      id: 'bollywood',
      emoji: '🌟',
      title: 'Bollywood Icons',
      subtitle: 'Legends of Hindi cinema',
      gradient: [const Color(0xFF6A1B9A), const Color(0xFF4A148C)],
      borderColor: const Color(0xFF8E24AA),
    ),
    _CategoryData(
      id: 'sports',
      emoji: '🏆',
      title: 'Sports Stars',
      subtitle: "India's sporting champions",
      gradient: [const Color(0xFFE65100), const Color(0xFFBF360C)],
      borderColor: const Color(0xFFF57C00),
    ),
    _CategoryData(
      id: 'politicians',
      emoji: '🇮🇳',
      title: 'Political Leaders',
      subtitle: 'Know your leaders!',
      gradient: [const Color(0xFF004D40), const Color(0xFF00251A)],
      borderColor: const Color(0xFF00796B),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startGame() async {
    if (_selected == null) return;
    final gs = context.read<GameState>();
    gs.setTopic(_selected!);
    await gs.hostGame();
    if (mounted) {
      Navigator.pushNamed(context, '/lobby', arguments: {'isHost': true});
    }
  }

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
                colors: [Color(0xFFE8F0FE), Color(0xFFF8F9FD), Color(0xFFF0F4FF)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        const SizedBox(height: 4),
                        Text('Choose Category',
                            style: AppTheme.headlineLg.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w800,
                                fontSize: 28)),
                        const SizedBox(height: 4),
                        Text(
                            'Select a topic for this game. Both players will use the same set.',
                            style: AppTheme.bodyMd.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 14)),
                        const SizedBox(height: 20),

                        // Category grid
                        ...List.generate(_categories.length, (i) {
                          final cat = _categories[i];
                          final isSelected = _selected == cat.id;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildCategoryCard(cat, isSelected),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating bottom bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, -4))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selected != null) ...[
                    Row(children: [
                      Text(
                          _categories
                              .firstWhere((c) => c.id == _selected)
                              .emoji,
                          style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Selected Category',
                            style: AppTheme.labelBold.copyWith(
                                color: AppColors.onSurfaceVariant, fontSize: 11)),
                        Text(
                            _categories
                                .firstWhere((c) => c.id == _selected)
                                .title,
                            style: AppTheme.headlineMd.copyWith(
                                color: AppColors.onSurface, fontSize: 18)),
                      ]),
                    ]),
                    const SizedBox(height: 12),
                  ],
                  GestureDetector(
                    onTap: _selected != null ? _startGame : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      decoration: BoxDecoration(
                        gradient: _selected != null
                            ? const LinearGradient(
                                colors: [Color(0xFF1A73E8), Color(0xFF0052CC)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight)
                            : null,
                        color: _selected == null
                            ? AppColors.surfaceContainerHigh
                            : null,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: _selected != null
                            ? [
                                BoxShadow(
                                    color: Colors.blue.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 5))
                              ]
                            : null,
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.group_add_rounded,
                                color: _selected != null
                                    ? Colors.white
                                    : AppColors.onSurfaceVariant,
                                size: 22),
                            const SizedBox(width: 10),
                            Text('HOST GAME',
                                style: AppTheme.buttonText.copyWith(
                                    color: _selected != null
                                        ? Colors.white
                                        : AppColors.onSurfaceVariant,
                                    fontSize: 18,
                                    letterSpacing: 1.5)),
                          ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6)
                ]),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.onSurface, size: 18),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text('Game Mode',
              style: AppTheme.headlineMd
                  .copyWith(color: AppColors.onSurface, fontSize: 22)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.primaryContainer.withValues(alpha: 0.3))),
          child: Row(children: [
            const Icon(Icons.videogame_asset,
                color: AppColors.primaryContainer, size: 16),
            const SizedBox(width: 6),
            Text('HOST',
                style: AppTheme.labelBold.copyWith(
                    color: AppColors.primaryContainer, fontSize: 12)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildCategoryCard(_CategoryData cat, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selected = cat.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.transparent : Colors.white,
          gradient: isSelected
              ? LinearGradient(
                  colors: cat.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)
              : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected
                  ? cat.borderColor
                  : AppColors.outlineVariant.withValues(alpha: 0.6),
              width: isSelected ? 2 : 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: cat.borderColor.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6))
                ]
              : [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
        ),
        child: Row(children: [
          // Emoji badge
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.15)
                  : cat.borderColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
                child:
                    Text(cat.emoji, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 14),
          // Text
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cat.title,
                  style: AppTheme.headlineMd.copyWith(
                      color: isSelected ? Colors.white : AppColors.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(cat.subtitle,
                  style: AppTheme.bodyMd.copyWith(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.onSurfaceVariant,
                      fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(10)),
                child: Text('20 Characters',
                    style: AppTheme.labelBold.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.onSurfaceVariant,
                        fontSize: 11)),
              ),
            ]),
          ),
          // Check
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? Colors.white
                  : AppColors.surfaceContainerHigh,
              border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : AppColors.outlineVariant,
                  width: 2),
            ),
            child: isSelected
                ? Icon(Icons.check_rounded,
                    color: cat.gradient.first, size: 18)
                : null,
          ),
        ]),
      ),
    );
  }
}

class _CategoryData {
  final String id, emoji, title, subtitle;
  final List<Color> gradient;
  final Color borderColor;

  const _CategoryData({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.borderColor,
  });
}

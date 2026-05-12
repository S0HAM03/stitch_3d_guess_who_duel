import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class JoinLobbySheet extends StatefulWidget {
  const JoinLobbySheet({super.key});

  @override
  State<JoinLobbySheet> createState() => _JoinLobbySheetState();
}

class _JoinLobbySheetState extends State<JoinLobbySheet> {
  final List<String> _digits = [];
  bool _error = false;

  void _addDigit(String digit) {
    if (_digits.length < 4) {
      setState(() {
        _digits.add(digit);
        _error = false;
      });
      if (_digits.length == 4) {
        _tryJoin();
      }
    }
  }

  void _removeDigit() {
    if (_digits.isNotEmpty) {
      setState(() {
        _digits.removeLast();
        _error = false;
      });
    }
  }

  Future<void> _tryJoin() async {
    final code = _digits.join();
    final gs = context.read<GameState>();
    final success = await gs.joinLobby(code);
    if (success) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/lobby', arguments: {'isHost': false});
        }
      });
    } else {
      setState(() {
        _error = true;
        _digits.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 40, offset: const Offset(0, -10)),
        ],
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(width: 48, height: 5,
            decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(3))),
          const SizedBox(height: 20),

          // Title
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.sports_esports, color: AppColors.primaryContainer, size: 28),
            const SizedBox(width: 10),
            Text('Join Lobby', style: AppTheme.headlineMd.copyWith(color: AppColors.onSurface)),
          ]),
          const SizedBox(height: 6),
          Text('Enter the 4-digit code from your friend', style: AppTheme.bodyMd.copyWith(color: AppColors.onSurfaceVariant, fontSize: 14)),
          const SizedBox(height: 24),

          // Code boxes
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < _digits.length;
                return Container(
                  width: 58, height: 72,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: filled ? AppColors.primaryContainer.withValues(alpha: 0.08) : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _error
                          ? AppColors.error
                          : filled ? AppColors.primaryContainer : AppColors.outlineVariant,
                      width: filled ? 2.5 : 1.5,
                    ),
                    boxShadow: filled ? [BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.18), blurRadius: 8)] : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    filled ? _digits[i] : '·',
                    style: TextStyle(
                      fontSize: filled ? 30 : 22,
                      fontWeight: FontWeight.w800,
                      color: filled ? AppColors.onSurface : AppColors.outlineVariant,
                    ),
                  ),
                );
              }),
            ),
          ),

          if (_error) ...[
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 16),
              const SizedBox(width: 6),
              Text('Invalid code. Please try again.', style: AppTheme.bodyMd.copyWith(color: AppColors.error, fontSize: 13)),
            ]),
          ],

          const SizedBox(height: 24),

          // Keypad
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.0,
            children: [
              ...[1, 2, 3, 4, 5, 6, 7, 8, 9].map((n) => _KeypadButton(label: '$n', onTap: () => _addDigit('$n'))),
              const SizedBox(),
              _KeypadButton(label: '0', onTap: () => _addDigit('0')),
              _KeypadButton(icon: Icons.backspace_outlined, isDelete: true, onTap: _removeDigit),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool isDelete;
  final VoidCallback onTap;

  const _KeypadButton({this.label, this.icon, this.isDelete = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDelete ? AppColors.errorContainer.withValues(alpha: 0.6) : AppColors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Center(
          child: icon != null
              ? Icon(icon, color: isDelete ? AppColors.error : AppColors.onSurface, size: 22)
              : Text(label ?? '', style: AppTheme.headlineMd.copyWith(color: AppColors.onSurface)),
        ),
      ),
    );
  }
}

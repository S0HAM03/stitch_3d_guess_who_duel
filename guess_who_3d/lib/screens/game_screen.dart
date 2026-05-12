import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../data/questions_data.dart';
import '../models/character.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final Map<int, AnimationController> _flipControllers = {};
  final Map<int, Animation<double>> _flipAnimations = {};
  Character? _tempSelectedCard;
  final _questionController = TextEditingController();
  
  Timer? _turnTimer;
  String _timeLeft = "02:00";

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gs = context.read<GameState>();
      for (int i = 0; i < gs.boardCharacters.length; i++) {
        final ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
        _flipControllers[i] = ctrl;
        _flipAnimations[i] = Tween<double>(begin: 0, end: 1)
            .animate(CurvedAnimation(parent: ctrl, curve: Curves.easeInOut));
      }
      setState(() {});
    });
  }

  void _startTimer() {
    _turnTimer?.cancel();
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final gs = context.read<GameState>();
      if (gs.turnEndTimestamp == null) return;

      final now = DateTime.now().millisecondsSinceEpoch;
      final diff = gs.turnEndTimestamp! - now;

      if (diff <= 0) {
        if (gs.isPlayerTurn) gs.passTurn();
        setState(() => _timeLeft = "00:00");
      } else {
        final duration = Duration(milliseconds: diff);
        final mins = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
        final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
        setState(() => _timeLeft = "$mins:$secs");
      }
    });
  }

  void _giveFeedback() {
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    for (final c in _flipControllers.values) { c.dispose(); }
    _questionController.dispose();
    super.dispose();
  }

  void _toggleKnockDown(GameState gs, int index) {
    gs.knockDownCard(index);
    if (gs.boardCharacters[index].isKnockedDown) {
      _flipControllers[index]?.forward();
      _giveFeedback();
    } else {
      _flipControllers[index]?.reverse();
      _giveFeedback();
    }
  }

  void _showCardActionSheet(BuildContext ctx, GameState gs, int index) {
    final char = gs.boardCharacters[index];
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 44, height: 4,
              decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            // Character preview
            Row(children: [
              Container(
                width: 64, height: 80,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryContainer, width: 2)),
                child: ClipRRect(borderRadius: BorderRadius.circular(10),
                  child: Image.network(char.imageUrl, fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: AppColors.primaryFixed, child: const Icon(Icons.person, color: Colors.white)))),
              ),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(char.name, style: AppTheme.headlineMd.copyWith(fontSize: 22, color: AppColors.onSurface)),
                const SizedBox(height: 4),
                Text('What do you want to do?', style: AppTheme.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
              ]),
            ]),
            const SizedBox(height: 20),
            // Knock Down button
            _ActionButton(
              icon: char.isKnockedDown ? Icons.undo_rounded : Icons.arrow_downward_rounded,
              label: char.isKnockedDown ? 'Flip Back Up' : 'Knock Down',
              subtitle: 'Eliminate this character from your board',
              color: char.isKnockedDown ? AppColors.surfaceContainerHigh : AppColors.primaryContainer.withValues(alpha: 0.12),
              textColor: char.isKnockedDown ? AppColors.onSurfaceVariant : AppColors.primaryContainer,
              onTap: () {
                Navigator.pop(ctx);
                _toggleKnockDown(gs, index);
              },
            ),
            const SizedBox(height: 10),
            // Guess button
            _ActionButton(
              icon: Icons.emoji_events_rounded,
              label: '🎯 Guess This Character!',
              subtitle: 'Think this is their secret card? Go for it!',
              color: const Color(0xFFB9082C).withValues(alpha: 0.1),
              textColor: const Color(0xFFB9082C),
              onTap: () {
                Navigator.pop(ctx);
                _doGuess(gs, char);
              },
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  void _doGuess(GameState gs, Character guessed) async {
    final result = await gs.guessCharacter(guessed);
    final isWin = result == GameResult.win;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: isWin
                  ? [const Color(0xFF1A73E8), const Color(0xFF0052CC)]
                  : [const Color(0xFFB9082C), const Color(0xFF7A0010)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(isWin ? '🎉' : '😅', style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(isWin ? 'YOU WIN!' : 'WRONG GUESS!',
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(
              isWin
                  ? 'Correct! The answer was\n${gs.opponentSecretCard?.name ?? "?"}'
                  : 'Wrong! The answer was\n${gs.opponentSecretCard?.name ?? "?"}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15),
            ),
            const SizedBox(height: 24),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
              },
              child: const Text('Back to Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gs, _) {
        return Scaffold(
          // Lighter wood/table background
          backgroundColor: const Color(0xFFFDE8C0),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildTopBar(context, gs),
                if (gs.phase == GamePhase.selectingCard) _buildSelectCardBanner(),
                
                // Main 3D Play Area
                Expanded(
                  child: Stack(
                    children: [
                      // Table background gradient
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFE8C898), Color(0xFFFDE8C0)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      
                      Column(
                        children: [
                          const SizedBox(height: 10),
                          _buildOpponentSection(gs),
                          Expanded(child: _buildGameBoard(gs)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                if (gs.mySecretCard != null) _buildMyCardStrip(gs),
                if (gs.phase == GamePhase.playing) _buildInteractionTray(gs),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSettingsDialog(GameState gs) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Game Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Game is in Sync mode. Feedback is active.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext ctx, GameState gs) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(ctx).padding.top + 8, left: 16, right: 14, bottom: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF1A73E8), Color(0xFF0052CC)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          const Icon(Icons.videogame_asset, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          Text('GUESS WHO 3D', style: AppTheme.headlineMd.copyWith(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
        ]),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              const Icon(Icons.stars, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text('1,250', style: AppTheme.labelBold.copyWith(color: Colors.white, fontSize: 13)),
            ]),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showSettingsDialog(gs),
            child: Container(padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.settings, color: Colors.white, size: 20)),
          ),
        ]),
      ]),
    );
  }

  Widget _buildSelectCardBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF735C00), Color(0xFFB9082C)]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        if (_tempSelectedCard == null) ...[
          const Text('👆', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SELECT YOUR SECRET CARD', style: AppTheme.labelBold.copyWith(color: Colors.white, letterSpacing: 1)),
            Text('Tap any character — this is what your opponent must guess!', style: AppTheme.bodyMd.copyWith(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
          ])),
        ] else ...[
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: NetworkImage(_tempSelectedCard!.imageUrl), fit: BoxFit.cover)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CONFIRM SECRET CARD?', style: AppTheme.labelBold.copyWith(color: Colors.white, letterSpacing: 1)),
            Text(_tempSelectedCard!.name, style: AppTheme.bodyMd.copyWith(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ])),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFB9082C)),
            onPressed: () {
              context.read<GameState>().selectMyCard(_tempSelectedCard!);
              setState(() => _tempSelectedCard = null);
            },
            child: const Text('CONFIRM', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ]
      ]),
    );
  }


  Widget _buildCharacterCard(BuildContext ctx, GameState gs, int index) {
    if (_flipAnimations[index] == null) return const SizedBox();
    final char = gs.boardCharacters[index];

    return GestureDetector(
      onTap: () {
        if (gs.phase == GamePhase.selectingCard) {
          setState(() => _tempSelectedCard = char);
        } else if (gs.phase == GamePhase.playing) {
          if (!char.isKnockedDown) {
            _showCardActionSheet(ctx, gs, index);
          } else {
            _toggleKnockDown(gs, index); // tap flat card to restore
          }
        }
      },
      child: AnimatedBuilder(
        animation: _flipAnimations[index]!,
        builder: (context, child) {
          // Flip value: 0 = standing, 1 = knocked down flat
          final flipVal = _flipAnimations[index]!.value;
          final tiltAngle = 0.9; // Must match the board's rotateX
          
          // Interpolate from standing (-0.9 to counter board tilt) to flat (0.0 relative to board)
          final currentTilt = -tiltAngle * (1.0 - flipVal);
          
          final isEliminated = flipVal > 0.5;

          return Transform(
            alignment: Alignment.bottomCenter,
            transform: Matrix4.identity()..rotateX(currentTilt),
            child: _buildCardFront(char, gs.phase == GamePhase.selectingCard, isEliminated),
          );
        },
      ),
    );
  }

  Widget _buildCardFront(Character char, bool isSelectingPhase, bool isEliminated) {
    return Container(
      decoration: BoxDecoration(
        color: isEliminated ? Colors.grey[400] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelectingPhase && _tempSelectedCard == char 
              ? Colors.green 
              : (isEliminated ? Colors.grey[600]! : Colors.white), 
          width: isSelectingPhase && _tempSelectedCard == char ? 3 : 2
        ),
        boxShadow: isEliminated ? [] : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 5, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Container(
                width: double.infinity, 
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isEliminated ? Colors.grey[700] : const Color(0xFF1A73E8),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
                child: Text(
                  char.name.toUpperCase(), 
                  textAlign: TextAlign.center,
                  style: AppTheme.labelBold.copyWith(color: Colors.white, fontSize: 9, letterSpacing: 0.5), 
                  overflow: TextOverflow.ellipsis
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
                  child: Image.network(
                    char.imageUrl, 
                    fit: BoxFit.cover, 
                    width: double.infinity,
                    color: isEliminated ? Colors.black.withValues(alpha: 0.5) : null,
                    colorBlendMode: isEliminated ? BlendMode.darken : null,
                    errorBuilder: (c, e, s) => Container(color: AppColors.primaryFixed.withValues(alpha: 0.3),
                      child: Icon(Icons.person, size: 32, color: AppColors.primary.withValues(alpha: 0.5))),
                  ),
                ),
              ),
            ],
          ),
          if (isEliminated)
            Center(
              child: Icon(Icons.close_rounded, color: Colors.red.withValues(alpha: 0.8), size: 48),
            ),
          if (isSelectingPhase && _tempSelectedCard == char)
            Container(
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(child: Icon(Icons.check_circle, color: Colors.white, size: 36)),
            ),
        ],
      ),
    );
  }



  Widget _buildMyCardStrip(GameState gs) {
    final card = gs.mySecretCard!;
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 6, 10, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6)],
      ),
      child: Row(children: [
        Container(
          width: 46, height: 58,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.primaryContainer, width: 2),
            boxShadow: [BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.4), blurRadius: 6)]),
          child: ClipRRect(borderRadius: BorderRadius.circular(6),
            child: Image.network(card.imageUrl, fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: AppColors.primaryFixed, child: const Icon(Icons.person, color: Colors.white, size: 24)))),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('YOUR SECRET CARD', style: AppTheme.labelBold.copyWith(color: AppColors.primary, fontSize: 10, letterSpacing: 1)),
          Text(card.name, style: AppTheme.headlineMd.copyWith(color: AppColors.onSurface, fontSize: 17)),
        ]),
        const Spacer(),
        Text('🤫', style: const TextStyle(fontSize: 22)),
      ]),
    );
  }

  Widget _buildInteractionTray(GameState gs) {
    // If there's an active question and I'm NOT the sender, I need to answer
    final bool hasQuestion = gs.currentQuestion != null;
    final bool isMyQuestion = hasQuestion && gs.currentQuestion!['sender'] == (gs.isHost ? 'host' : 'guest');
    final bool needToAnswer = hasQuestion && !isMyQuestion;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 15, offset: const Offset(0, -5))],
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Turn & Status indicator
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _buildTurnChip(gs),
          _buildTimerChip(),
        ]),
        const SizedBox(height: 12),

        if (needToAnswer)
          _buildAnswerQuestionSection(gs)
        else if (isMyQuestion)
          _buildWaitingForAnswerSection(gs)
        else if (gs.isPlayerTurn)
          _buildAskQuestionSection(gs)
        else
          _buildOpponentTurnSection(gs),
      ]),
    );
  }

  Widget _buildTurnChip(GameState gs) {
    final bool isMyTurn = gs.isPlayerTurn && gs.currentQuestion == null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: isMyTurn 
          ? const LinearGradient(colors: [Color(0xFF1A73E8), Color(0xFF0052CC)])
          : LinearGradient(colors: [Colors.grey[400]!, Colors.grey[600]!]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isMyTurn ? [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 8)] : [],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 8, height: 8, 
          decoration: BoxDecoration(shape: BoxShape.circle, color: isMyTurn ? Colors.greenAccent : Colors.white70)
        ),
        const SizedBox(width: 8),
        Text(
          gs.isPlayerTurn ? 'YOUR TURN' : "OPPONENT'S TURN",
          style: AppTheme.labelBold.copyWith(color: Colors.white, fontSize: 13, letterSpacing: 0.5)
        ),
      ]),
    );
  }

  Widget _buildTimerChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(children: [
        const Icon(Icons.timer_outlined, color: AppColors.onSurfaceVariant, size: 16),
        const SizedBox(width: 6),
        Text(_timeLeft, style: AppTheme.labelBold.copyWith(color: AppColors.onSurfaceVariant, fontSize: 13)),
      ]),
    );
  }

  Widget _buildAskQuestionSection(GameState gs) {
    final questions = QuestionsData.getQuestionsForCategory(gs.selectedTopic);
    return Column(children: [
      // Predefined questions
      SizedBox(height: 40, child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, a) => const SizedBox(width: 10),
        itemCount: questions.length,
        itemBuilder: (ctx, i) => GestureDetector(
          onTap: () {
            gs.askQuestion(questions[i]);
            _giveFeedback();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.5)),
              color: AppColors.primaryContainer.withValues(alpha: 0.08),
            ),
            child: Text(questions[i],
              style: AppTheme.bodyMd.copyWith(fontSize: 14, color: AppColors.primaryContainer, fontWeight: FontWeight.bold)),
          ),
        ),
      )),
      const SizedBox(height: 12),

      // Question input
      Row(children: [
        Expanded(child: TextField(
          controller: _questionController,
          decoration: InputDecoration(
            hintText: 'Ask a custom question...',
            hintStyle: AppTheme.bodyMd.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
            filled: true, fillColor: AppColors.surfaceContainerLow,
            prefixIcon: const Icon(Icons.help_outline, color: AppColors.onSurfaceVariant, size: 22),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          ),
        )),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            if (_questionController.text.isNotEmpty) {
              gs.askQuestion(_questionController.text);
              _questionController.clear();
              _giveFeedback();
            }
          },
          child: Container(
            height: 52, padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFB9082C), Color(0xFF7A0010)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.3), blurRadius: 10)],
            ),
            child: Row(children: [
              const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('ASK', style: AppTheme.labelBold.copyWith(color: Colors.white, fontSize: 15)),
            ]),
          ),
        ),
      ]),
      const SizedBox(height: 10),
      TextButton.icon(
        onPressed: () {
          gs.passTurn();
          _giveFeedback();
        },
        icon: const Icon(Icons.skip_next, size: 18),
        label: const Text('FINISH TURN / PASS'),
        style: TextButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant),
      ),
    ]);
  }

  Widget _buildAnswerQuestionSection(GameState gs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber[700]!.withValues(alpha: 0.3)),
      ),
      child: Column(children: [
        Text('OPPONENT ASKS:', style: AppTheme.labelBold.copyWith(color: Colors.amber[900], fontSize: 11)),
        const SizedBox(height: 6),
        Text(
          '"${gs.currentQuestion!['text']}"',
          textAlign: TextAlign.center,
          style: AppTheme.headlineMd.copyWith(fontSize: 18, color: AppColors.onSurface),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _buildResponseButton(gs, true)),
          const SizedBox(width: 12),
          Expanded(child: _buildResponseButton(gs, false)),
        ]),
      ]),
    );
  }

  Widget _buildResponseButton(GameState gs, bool response) {
    return GestureDetector(
      onTap: () {
        gs.answerQuestion(response);
        _giveFeedback();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: response ? Colors.green[600] : Colors.red[600],
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: (response ? Colors.green : Colors.red).withValues(alpha: 0.3), blurRadius: 8)],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(response ? Icons.check_circle_outline : Icons.cancel_outlined, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(response ? 'YES' : 'NO', style: AppTheme.labelBold.copyWith(color: Colors.white, fontSize: 16)),
        ]),
      ),
    );
  }

  Widget _buildWaitingForAnswerSection(GameState gs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: [
        const CircularProgressIndicator(strokeWidth: 3),
        const SizedBox(height: 16),
        Text('Waiting for opponent to answer...', style: AppTheme.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
        Text('"${gs.currentQuestion!['text']}"', style: AppTheme.labelBold.copyWith(color: AppColors.onSurface, fontSize: 14)),
      ]),
    );
  }

  Widget _buildOpponentTurnSection(GameState gs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: [
        const Icon(Icons.hourglass_bottom_rounded, size: 32, color: AppColors.onSurfaceVariant),
        const SizedBox(height: 12),
        Text('Opponent is thinking...', style: AppTheme.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
      ]),
    );
  }

  Widget _buildGameBoard(GameState gs) {
    if (gs.boardCharacters.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // The perspective tilt for the whole board
    final perspectiveMatrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0012) // Slightly less perspective for better visibility
      ..rotateX(0.85); // Adjusted tilt

    return Center(
      child: Transform(
        transform: perspectiveMatrix,
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF326996), // Brighter blue board
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF1E4264), width: 8),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 25, offset: const Offset(0, 15)),
              BoxShadow(color: Colors.white.withValues(alpha: 0.1), blurRadius: 2, offset: const Offset(0, -2)),
            ],
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, 
              childAspectRatio: 0.72, 
              crossAxisSpacing: 10, 
              mainAxisSpacing: 24 // Increased spacing to prevent overlap
            ),
            itemCount: gs.boardCharacters.length,
            itemBuilder: (ctx, i) => _buildCharacterCard(ctx, gs, i),
          ),
        ),
      ),
    );
  }

  Widget _buildOpponentSection(GameState gs) {
    // Add a perspective view of the opponent's board (the backs of their cards)
    return Column(
      children: [
        // Opponent's mini board (Backs of cards)
        Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(-0.5), // Tilted away from us
          alignment: Alignment.center,
          child: Container(
            width: 200,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E4264).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              spacing: 4, runSpacing: 4,
              children: List.generate(8, (index) => Container(
                width: 20, height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFB9082C),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: Colors.white24),
                ),
              )),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 54, height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1A73E8), width: 3),
                  boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 8)],
                ),
                child: ClipOval(child: Image.network('https://api.dicebear.com/7.x/avataaars/png?seed=opponent&size=100', fit: BoxFit.cover)),
              ),
              Positioned(
                right: -4, top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFFB9082C), shape: BoxShape.circle),
                  child: Text(
                    '${gs.opponentStandingCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(gs.isHost ? gs.guestName : gs.hostName, style: AppTheme.headlineMd.copyWith(fontSize: 18, color: AppColors.onSurface)),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(color: gs.isPlayerTurn ? AppColors.surfaceContainerHigh : Colors.green[600], borderRadius: BorderRadius.circular(8)),
                child: Text(gs.isPlayerTurn ? 'WAITING...' : 'THINKING...', style: AppTheme.labelBold.copyWith(color: gs.isPlayerTurn ? AppColors.onSurfaceVariant : Colors.white, fontSize: 10)),
              ),
              const SizedBox(width: 6),
              Text('Cards Left: ${gs.opponentStandingCount}', style: AppTheme.labelBold.copyWith(fontSize: 10, color: AppColors.onSurfaceVariant)),
            ]),
          ]),
        ]),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.subtitle, required this.color, required this.textColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: AppTheme.labelBold.copyWith(color: textColor, fontSize: 15)),
              Text(subtitle, style: AppTheme.bodyMd.copyWith(color: textColor.withValues(alpha: 0.7), fontSize: 12)),
            ])),
            Icon(Icons.chevron_right, color: textColor.withValues(alpha: 0.5)),
          ]),
        ),
      ),
    );
  }
}

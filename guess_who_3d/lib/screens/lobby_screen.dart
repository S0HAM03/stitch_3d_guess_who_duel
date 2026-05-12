import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/glossy_button.dart';
import '../data/characters_data.dart';

class LobbyScreen extends StatefulWidget {
  final bool isHost;
  const LobbyScreen({super.key, this.isHost = true});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> with SingleTickerProviderStateMixin {
  final _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final gs = context.read<GameState>();
      gs.addListener(_onGameStateChange);
      if (widget.isHost && gs.lobbyCode.isEmpty) {
        await gs.hostGame();
      }
    });
  }

  void _onGameStateChange() {
    if (!mounted) return;
    final gs = context.read<GameState>();
    if (gs.phase == GamePhase.selectingCard && ModalRoute.of(context)?.isCurrent == true) {
      Navigator.pushReplacementNamed(context, '/game');
    }
  }

  @override
  void dispose() {
    context.read<GameState>().removeListener(_onGameStateChange);
    _pulseController.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(GameState gs) {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    gs.sendMessage(text);
    _chatController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gs, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF0F4FF),
          body: Column(
            children: [
              _buildTopBar(context, gs),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Column(
                    children: [
                      _buildLobbyCode(gs),
                      const SizedBox(height: 20),
                      _buildPlayersSection(gs),
                      const SizedBox(height: 20),
                      _buildChat(gs),
                      const SizedBox(height: 20),
                      if (widget.isHost && gs.guestJoined)
                        GlossyButton(
                          label: 'START GAME',
                          icon: Icons.play_arrow_rounded,
                          color: AppColors.primaryContainer,
                          onTap: () {
                            gs.startGame(CharactersData.getCharactersForTopic(gs.selectedTopic));
                          },
                        ),
                      if (widget.isHost && !gs.guestJoined)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (_, child) => Transform.scale(scale: _pulseAnim.value, child: child),
                              child: Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.tertiary)),
                            ),
                            const SizedBox(width: 10),
                            Text('Waiting for Player 2 to join...', style: AppTheme.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                          ]),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              BottomNavBar(currentIndex: 1, onTap: (i) {
                if (i == 0) Navigator.pushReplacementNamed(context, '/home');
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, GameState gs) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 20, right: 20, bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A73E8), Color(0xFF0052CC)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          const Icon(Icons.videogame_asset, color: Colors.white, size: 26),
          const SizedBox(width: 10),
          Text('GUESS WHO 3D', style: AppTheme.headlineMd.copyWith(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
          child: Text(widget.isHost ? 'HOST' : 'PLAYER 2', style: AppTheme.labelBold.copyWith(color: Colors.white, fontSize: 12)),
        ),
      ]),
    );
  }

  Widget _buildLobbyCode(GameState gs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 14, offset: const Offset(0, 4))],
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.tag, color: AppColors.onSurfaceVariant, size: 16),
          const SizedBox(width: 6),
          Text('LOBBY CODE', style: AppTheme.labelBold.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 2.5, fontSize: 12)),
        ]),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: gs.lobbyCode.split('').map((d) => Container(
            width: 52, height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1A73E8), Color(0xFF0052CC)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 3))],
            ),
            alignment: Alignment.center,
            child: Text(d, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 0)),
          )).toList(),
        ),
        const SizedBox(height: 10),
        Text('Share this code with your friend', style: AppTheme.bodyMd.copyWith(color: AppColors.onSurfaceVariant, fontSize: 13)),
      ]),
    );
  }

  Widget _buildPlayersSection(GameState gs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        Expanded(child: _buildPlayerTile(name: gs.hostName, tag: 'HOST', color: AppColors.primaryContainer, avatarSeed: 'host123', isReady: true)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('VS', style: AppTheme.headlineMd.copyWith(color: AppColors.onSurfaceVariant, fontSize: 22)),
        ),
        Expanded(child: gs.guestJoined
          ? _buildPlayerTile(name: gs.guestName, tag: 'P2', color: AppColors.secondaryContainer, avatarSeed: 'guest456', isReady: true,
              trailingWidget: widget.isHost ? IconButton(
                onPressed: () {},
                icon: const Icon(Icons.person_remove, color: AppColors.secondary, size: 20),
              ) : null)
          : _buildWaitingTile(),
        ),
      ]),
    );
  }

  Widget _buildPlayerTile({required String name, required String tag, required Color color, required String avatarSeed, required bool isReady, Widget? trailingWidget}) {
    return Column(children: [
      Stack(children: [
        Container(
          width: 70, height: 70,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 3),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10)]),
          child: ClipOval(child: Image.network('https://api.dicebear.com/7.x/avataaars/png?seed=$avatarSeed&size=200',
            fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: color.withValues(alpha: 0.3), child: const Icon(Icons.person, size: 36, color: Colors.white)))),
        ),
        Positioned(bottom: 0, right: 0, child: Container(
          width: 18, height: 18,
          decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
        )),
      ]),
      const SizedBox(height: 6),
      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
        child: Text(tag, style: AppTheme.labelBold.copyWith(color: Colors.white, fontSize: 10))),
      const SizedBox(height: 4),
      Text(name, style: AppTheme.bodyMd.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w700, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
      ?trailingWidget,
    ]);
  }

  Widget _buildWaitingTile() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, child) => Transform.scale(scale: _pulseAnim.value, child: child),
      child: Column(children: [
        Container(
          width: 70, height: 70,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.outlineVariant, width: 2, style: BorderStyle.solid),
            color: AppColors.surfaceContainerLow),
          child: const Icon(Icons.person_add_outlined, color: AppColors.onSurfaceVariant, size: 32),
        ),
        const SizedBox(height: 6),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(6)),
          child: Text('WAITING', style: AppTheme.labelBold.copyWith(color: AppColors.onSurfaceVariant, fontSize: 10))),
        const SizedBox(height: 4),
        Text('...', style: AppTheme.bodyMd.copyWith(color: AppColors.outlineVariant)),
      ]),
    );
  }

  Widget _buildChat(GameState gs) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1A73E8), Color(0xFF0052CC)]),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(children: [
            const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('LOBBY CHAT', style: AppTheme.labelBold.copyWith(color: Colors.white)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
              child: Text('${gs.chatMessages.length}', style: AppTheme.labelBold.copyWith(color: Colors.white, fontSize: 12)),
            ),
          ]),
        ),

        // Messages
        Container(
          height: 180,
          padding: const EdgeInsets.all(12),
          child: gs.chatMessages.isEmpty
            ? Center(child: Text('No messages yet. Say hi! 👋', style: AppTheme.bodyMd.copyWith(color: AppColors.onSurfaceVariant)))
            : ListView.builder(
                controller: _scrollController,
                itemCount: gs.chatMessages.length,
                itemBuilder: (ctx, i) {
                  final msg = gs.chatMessages[i];
                  if (msg.isSystem) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Center(child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(20)),
                        child: Text(msg.message, style: AppTheme.bodyMd.copyWith(color: AppColors.onSurfaceVariant, fontSize: 12)),
                      )),
                    );
                  }
                  final isMe = (widget.isHost && msg.sender == gs.hostName) || (!widget.isHost && msg.sender == gs.guestName);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isMe) ...[
                          CircleAvatar(radius: 14, backgroundColor: AppColors.secondaryContainer.withValues(alpha: 0.3),
                            child: Text(msg.sender[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.secondaryContainer))),
                          const SizedBox(width: 6),
                        ],
                        Flexible(child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isMe ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(14),
                              topRight: const Radius.circular(14),
                              bottomLeft: Radius.circular(isMe ? 14 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 14),
                            ),
                          ),
                          child: Text(msg.message, style: AppTheme.bodyMd.copyWith(color: isMe ? Colors.white : AppColors.onSurface, fontSize: 13)),
                        )),
                      ],
                    ),
                  );
                },
              ),
        ),

        // Input
        Container(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _chatController,
              onSubmitted: (_) => _sendMessage(gs),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: AppTheme.bodyMd.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
            )),
            const SizedBox(width: 8),
            Material(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => _sendMessage(gs),
                borderRadius: BorderRadius.circular(12),
                child: const SizedBox(width: 44, height: 44, child: Icon(Icons.send_rounded, color: Colors.white, size: 20)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

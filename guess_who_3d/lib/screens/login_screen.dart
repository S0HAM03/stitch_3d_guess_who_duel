import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isEnteringName = false;

  void _handleGuestLogin() {
    setState(() {
      _isEnteringName = true;
    });
  }

  void _submitName() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      Provider.of<GameState>(context, listen: false).updateLocalPlayerName(name);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF006399), Color(0xFF00A8FF), Color(0xFFF8F9FD)],
            stops: [0.0, 0.4, 0.8],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or Icon
                const Icon(Icons.videogame_asset, size: 80, color: Colors.white),
                const SizedBox(height: 20),
                Text(
                  'GUESS WHO 3D',
                  style: AppTheme.headlineLg.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'THE ULTIMATE DUEL',
                  style: AppTheme.labelBold.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 60),

                if (!_isEnteringName) ...[
                  _buildLoginButton(
                    label: 'SIGN IN WITH GOOGLE',
                    icon: Icons.login,
                    color: Colors.white,
                    textColor: AppColors.primary,
                    onTap: () {
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Google Sign-In coming soon! Use Guest Mode.')),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildLoginButton(
                    label: 'GUEST MODE LOGIN',
                    icon: Icons.person_outline,
                    color: Colors.white.withOpacity(0.2),
                    textColor: Colors.white,
                    isOutline: true,
                    onTap: _handleGuestLogin,
                  ),
                ] else ...[
                  _buildNameInput(),
                ],
                
                const SizedBox(height: 40),
                Text(
                  'By continuing, you agree to our Terms & Privacy Policy',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMd.copyWith(
                    color: _isEnteringName ? AppColors.onSurfaceVariant : Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
    bool isOutline = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isOutline ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(16),
          border: isOutline ? Border.all(color: Colors.white, width: 2) : null,
          boxShadow: isOutline ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTheme.buttonText.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameInput() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _nameController,
            autofocus: true,
            style: AppTheme.bodyMd.copyWith(fontSize: 18),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey.shade400),
            ),
            onSubmitted: (_) => _submitName(),
          ),
        ),
        const SizedBox(height: 20),
        _buildLoginButton(
          label: 'START PLAYING',
          icon: Icons.play_arrow_rounded,
          color: AppColors.secondary,
          textColor: Colors.white,
          onTap: _submitName,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _isEnteringName = false),
          child: Text(
            'Go Back',
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

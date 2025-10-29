import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../screens/signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onToggleTheme; // callback to trigger light/dark switch
  final bool isDarkMode; // so we know which icon to show

  const WelcomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          // simple icon button to toggle theme
          IconButton(
            tooltip: isDarkMode
                ? 'Switch to light mode'
                : 'Switch to dark mode',
            icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: onToggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // nice gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.primary.withOpacity(.08),
                    cs.secondary.withOpacity(.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // fun emoji icon at the top
                    Text(
                      '🧭',
                      style: TextStyle(fontSize: 72, color: cs.primary),
                    ),
                    const SizedBox(height: 16),

                    // animated intro text
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 56,
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                          overflow: TextOverflow.visible,
                        ),
                        child: AnimatedTextKit(
                          repeatForever: true,
                          pause: const Duration(milliseconds: 800),
                          animatedTexts: [
                            TyperAnimatedText(
                              'Welcome to your adventure',
                              textAlign: TextAlign.center,
                              speed: const Duration(milliseconds: 50),
                            ),
                            TyperAnimatedText(
                              'Make it personal',
                              textAlign: TextAlign.center,
                              speed: const Duration(milliseconds: 50),
                            ),
                            TyperAnimatedText(
                              'Let\'s get started!',
                              textAlign: TextAlign.center,
                              speed: const Duration(milliseconds: 50),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Text(
                      'Create your profile with animations, rewards, and fun feedback.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),

                    const SizedBox(height: 24),
                    FilledButton.tonal(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(
                              milliseconds: 450,
                            ),
                            pageBuilder: (_, __, ___) => const SignupScreen(),
                            transitionsBuilder: (_, animation, __, child) {
                              final curve = CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              );
                              return FadeTransition(
                                opacity: curve,
                                child: SlideTransition(
                                  position: Tween(
                                    begin: const Offset(0, .06),
                                    end: Offset.zero,
                                  ).animate(curve),
                                  child: child,
                                ),
                              );
                            },
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Text('Start Adventure →'),
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

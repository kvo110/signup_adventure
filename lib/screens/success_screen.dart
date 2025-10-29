import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../screens/welcome_screen.dart';
import '../main.dart';

class SuccessScreen extends StatefulWidget {
  final String name;
  final String avatar;
  final List<String> badges;

  const SuccessScreen({
    super.key,
    required this.name,
    required this.avatar,
    required this.badges,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  late final ConfettiController confetti = ConfettiController(
    duration: const Duration(seconds: 2),
  );

  @override
  void initState() {
    super.initState();
    // start confetti as soon as screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) => confetti.play());
  }

  @override
  void dispose() {
    confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // we want to access the App's theme state to allow user to toggle again
    final appState = context.findAncestorStateOfType<State<StatefulWidget>>();

    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Confetti layer on top
          ConfettiWidget(
            confettiController: confetti,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.06,
            numberOfParticles: 26,
            gravity: 0.35,
          ),

          // Main content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // chosen avatar displayed large
                  Text(widget.avatar, style: const TextStyle(fontSize: 72)),
                  const SizedBox(height: 10),

                  // welcome message
                  Text(
                    'Welcome, ${widget.name}!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Your adventure begins now 🎉',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),

                  // badges earned
                  if (widget.badges.isNotEmpty) ...[
                    Text(
                      'Your Achievements',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.badges.map((b) {
                        return Chip(
                          avatar: const Icon(Icons.verified, size: 18),
                          label: Text(b),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 30),
                  // go back to start
                  FilledButton.tonal(
                    onPressed: () {
                      // Find the parent app state that holds theme data
                      final appState = context
                          .findAncestorStateOfType<AppState>();
                      if (appState != null) {
                        // Use real theme state
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => WelcomeScreen(
                              onToggleTheme: appState.toggleTheme,
                              isDarkMode: appState.isDarkMode,
                            ),
                          ),
                          (route) => false,
                        );
                      } else {
                        // Fallback (if for some reason state isn't found)
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => WelcomeScreen(
                              onToggleTheme: () {}, // no-op just in case
                              isDarkMode: false,
                            ),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    child: const Text('Back to Start'),
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

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:confetti/confetti.dart';

// validation helpers
bool _nameOk(String v) => v.trim().length >= 2;
bool _emailOk(String v) => RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w+$').hasMatch(v);

int _scorePwd(String v) {
  int s = 0;
  if (v.length >= 8) s++;
  if (RegExp(r'[A-Z]').hasMatch(v)) s++;
  if (RegExp(r'[0-9]').hasMatch(v)) s++;
  if (RegExp(r'''[!@#$%^&*()_\-+=\{\}\[\]:;"'<>,.?/\\|~`]''').hasMatch(v)) s++;
  return s;
}

String _labelPwd(int s) {
  if (s <= 1) return 'Weak';
  if (s == 2) return 'Okay';
  if (s == 3) return 'Strong';
  return 'Very Strong';
}

Color _colorPwd(BuildContext ctx, int s) {
  final cs = Theme.of(ctx).colorScheme;
  if (s <= 1) return Colors.red;
  if (s == 2) return Colors.orange;
  if (s == 3) return Colors.teal;
  return cs.primary;
}

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signup Adventure',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6C63FF),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
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
                    Text(
                      '🧭',
                      style: TextStyle(fontSize: 72, color: cs.primary),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width:
                          MediaQuery.of(context).size.width *
                          0.9, // makes sure it doesn't wrap
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
                          displayFullTextOnTap: false,
                          stopPauseOnTap: false,
                          animatedTexts: [
                            TyperAnimatedText(
                              'Welcome to your adventure',
                              textAlign: TextAlign.center,
                              speed: Duration(milliseconds: 50),
                            ),
                            TyperAnimatedText(
                              'Make it personal',
                              textAlign: TextAlign.center,
                              speed: Duration(milliseconds: 50),
                            ),
                            TyperAnimatedText(
                              'Let\'s get started!',
                              textAlign: TextAlign.center,
                              speed: Duration(milliseconds: 50),
                            ),
                          ],
                          pause: const Duration(milliseconds: 800),
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

class ProgressTracker extends StatefulWidget {
  final double percent;
  const ProgressTracker({super.key, required this.percent});

  @override
  State<ProgressTracker> createState() => _ProgressTrackerState();
}

class _ProgressTrackerState extends State<ProgressTracker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  double lastMilestone = 0;
  String message = '';

  static final milestones = [0.25, 0.50, 0.75, 1.0];
  static final messages = {
    0.25: 'Great start!',
    0.50: 'Halfway there!',
    0.75: 'Almost done!',
    1.00: 'Ready for adventure!',
  };

  @override
  void didUpdateWidget(covariant ProgressTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final m in milestones) {
      if (oldWidget.percent < m && widget.percent >= m && lastMilestone < m) {
        lastMilestone = m;
        message = messages[m]!;
        HapticFeedback.lightImpact();
        SystemSound.play(SystemSoundType.click);
        _pulse.forward(from: 0);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = (widget.percent.clamp(0.0, 1.0) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: widget.percent,
            backgroundColor: cs.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: 8),
        ScaleTransition(
          scale: Tween<double>(
            begin: 1.0,
            end: 1.1,
          ).animate(CurvedAnimation(parent: _pulse, curve: Curves.elasticOut)),
          child: Text(
            '$pct%',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600, color: cs.primary),
          ),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: message.isEmpty ? 0 : 1,
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.primary, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();

  DateTime? dob;
  bool hidePwd = true;
  bool submitting = false;

  final avatars = ['🦊', '🐼', '🐧', '🐸', '🐯'];
  String? pickedAvatar;

  // controllers for shake animation on invalid fields
  late final shakeName = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final shakeEmail = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final shakePwd = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final shakeDob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  double progress = 0;

  @override
  void initState() {
    super.initState();
    nameCtrl.addListener(_recalc);
    emailCtrl.addListener(_recalc);
    pwdCtrl.addListener(_recalc);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    pwdCtrl.dispose();
    shakeName.dispose();
    shakeEmail.dispose();
    shakePwd.dispose();
    shakeDob.dispose();
    super.dispose();
  }

  void _recalc() {
    int done = 0;
    if (_nameOk(nameCtrl.text)) done++;
    if (_emailOk(emailCtrl.text)) done++;
    if (_scorePwd(pwdCtrl.text) >= 3) done++;
    if (dob != null) done++;
    if (pickedAvatar != null) done++;
    setState(() => progress = done / 5);
  }

  void _shake(AnimationController c) {
    c.forward(from: 0);
    HapticFeedback.vibrate();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: now,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      helpText: 'Select your birthday',
    );
    if (selected != null) {
      setState(() => dob = selected);
      _recalc();
      HapticFeedback.selectionClick();
    }
  }

  Widget _shakeWrap({
    required AnimationController c,
    required bool valid,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: c,
      builder: (_, __) {
        final t = c.value;
        final dx = valid ? 0.0 : sin(t * pi * 5) * (1 - t) * 8;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
    );
  }

  Future<void> _submit() async {
    final ok = formKey.currentState?.validate() ?? false;
    if (!ok || dob == null || pickedAvatar == null) {
      if (!_nameOk(nameCtrl.text)) _shake(shakeName);
      if (!_emailOk(emailCtrl.text)) _shake(shakeEmail);
      if (_scorePwd(pwdCtrl.text) < 3) _shake(shakePwd);
      if (dob == null) _shake(shakeDob);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete everything to continue 🚀'),
        ),
      );
      return;
    }

    setState(() => submitting = true);
    await Future.delayed(const Duration(milliseconds: 1200)); // fake loading
    setState(() => submitting = false);

    final early = TimeOfDay.now().hour < 12;
    final strong = _scorePwd(pwdCtrl.text) >= 3;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SuccessScreen(
          name: nameCtrl.text.trim(),
          avatar: pickedAvatar!,
          badges: [
            if (strong) 'Strong Password Master',
            if (early) 'The Early Bird Special',
            'Profile Completer',
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pwdScore = _scorePwd(pwdCtrl.text);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup Adventure'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(progress >= 1 ? Icons.rocket_launch : Icons.explore),
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProgressTracker(percent: progress),
                const SizedBox(height: 16),

                Text('Pick an avatar'),
                Wrap(
                  spacing: 10,
                  children: avatars.map((a) {
                    return ChoiceChip(
                      label: Text(a, style: const TextStyle(fontSize: 20)),
                      selected: pickedAvatar == a,
                      onSelected: (val) {
                        setState(() => pickedAvatar = val ? a : null);
                        _recalc();
                        HapticFeedback.selectionClick();
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      _shakeWrap(
                        c: shakeName,
                        valid: _nameOk(nameCtrl.text),
                        child: TextFormField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Please enter your name';
                            if (!_nameOk(v)) return 'Name looks too short';
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _shakeWrap(
                        c: shakeEmail,
                        valid: _emailOk(emailCtrl.text),
                        child: TextFormField(
                          controller: emailCtrl,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Enter your email';
                            if (!_emailOk(v))
                              return 'That email doesn\'t look right';
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _shakeWrap(
                        c: shakePwd,
                        valid: pwdScore >= 3 && pwdCtrl.text.isNotEmpty,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: pwdCtrl,
                              obscureText: hidePwd,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    hidePwd
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () =>
                                      setState(() => hidePwd = !hidePwd),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Please enter a password';
                                if (_scorePwd(v) < 2)
                                  return 'Try adding uppercase, numbers, or symbols';
                                return null;
                              },
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 8),
                            PasswordStrengthBar(score: pwdScore),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      _shakeWrap(
                        c: shakeDob,
                        valid: dob != null,
                        child: InkWell(
                          onTap: _pickDob,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date of Birth',
                              border: OutlineInputBorder(),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.cake_outlined,
                                  color: dob != null
                                      ? Colors.green
                                      : cs.onSurfaceVariant,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  dob == null
                                      ? 'Tap to pick your birthday'
                                      : '${dob!.year}-${dob!.month.toString().padLeft(2, '0')}-${dob!.day.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    color: dob != null
                                        ? cs.onSurface
                                        : cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: submitting ? null : _submit,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, anim) =>
                                FadeTransition(opacity: anim, child: child),
                            child: submitting
                                ? const SizedBox(
                                    key: ValueKey('loading'),
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.6,
                                    ),
                                  )
                                : const Text(
                                    'Finish Signup',
                                    key: ValueKey('text'),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordStrengthBar extends StatelessWidget {
  final int score;
  const PasswordStrengthBar({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final color = _colorPwd(context, score);
    final label = _labelPwd(score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: (score / 4).clamp(0, 1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            backgroundColor: color.withOpacity(.15),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Password Strength: $label',
          style: TextStyle(
            fontSize: 12.5,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

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
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          ConfettiWidget(
            confettiController: confetti,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.06,
            numberOfParticles: 26,
            gravity: 0.35,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.avatar, style: const TextStyle(fontSize: 72)),
                  const SizedBox(height: 10),
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
                      children: widget.badges
                          .map(
                            (b) => Chip(
                              avatar: const Icon(Icons.verified, size: 18),
                              label: Text(b),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 30),
                  FilledButton.tonal(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const WelcomeScreen(),
                        ),
                        (route) => false,
                      );
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

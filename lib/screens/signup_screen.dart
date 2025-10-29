import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/progress_tracker.dart';
import '../widgets/password_strength_bar.dart';
import '../utils/validators.dart';
import 'success_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  // form controllers
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();

  // user details
  DateTime? dob;
  bool hidePwd = true;
  bool submitting = false;
  String? pickedAvatar;

  // avatar options
  final avatars = ['🦊', '🐼', '🐧', '🐸', '🐯'];

  // shake animations for invalid fields
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
    // recalc progress whenever user types
    nameCtrl.addListener(_recalc);
    emailCtrl.addListener(_recalc);
    pwdCtrl.addListener(_recalc);
  }

  @override
  void dispose() {
    // clean up controllers
    nameCtrl.dispose();
    emailCtrl.dispose();
    pwdCtrl.dispose();
    shakeName.dispose();
    shakeEmail.dispose();
    shakePwd.dispose();
    shakeDob.dispose();
    super.dispose();
  }

  // live progress calculation
  void _recalc() {
    int done = 0;
    if (nameOk(nameCtrl.text)) done++;
    if (emailOk(emailCtrl.text)) done++;
    if (scorePwd(pwdCtrl.text) >= 3) done++;
    if (dob != null) done++;
    if (pickedAvatar != null) done++;

    setState(() => progress = done / 5);
  }

  // quick helper to trigger shake + vibration
  void _shake(AnimationController c) {
    c.forward(from: 0);
    HapticFeedback.vibrate();
  }

  // date picker for birthday
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

  // reusable shake wrapper
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

  // final submission handler
  Future<void> _submit() async {
    final ok = formKey.currentState?.validate() ?? false;

    if (!ok || dob == null || pickedAvatar == null) {
      if (!nameOk(nameCtrl.text)) _shake(shakeName);
      if (!emailOk(emailCtrl.text)) _shake(shakeEmail);
      if (scorePwd(pwdCtrl.text) < 3) _shake(shakePwd);
      if (dob == null) _shake(shakeDob);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete everything to continue 🚀'),
        ),
      );
      return;
    }

    setState(() => submitting = true);
    await Future.delayed(const Duration(milliseconds: 1200)); // pretend loading
    setState(() => submitting = false);

    // badges logic
    final early = TimeOfDay.now().hour < 12;
    final strong = scorePwd(pwdCtrl.text) >= 3;

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
    final pwdScore = scorePwd(pwdCtrl.text);

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
          onTap: () => FocusScope.of(context).unfocus(), // dismiss keyboard
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProgressTracker(percent: progress), // progress bar
                const SizedBox(height: 16),

                Text('Pick an avatar:', style: TextStyle(color: cs.onSurface)),
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
                const SizedBox(height: 24),

                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      _shakeWrap(
                        c: shakeName,
                        valid: nameOk(nameCtrl.text),
                        child: TextFormField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Please enter your name';
                            if (!nameOk(v)) return 'Name looks too short';
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _shakeWrap(
                        c: shakeEmail,
                        valid: emailOk(emailCtrl.text),
                        child: TextFormField(
                          controller: emailCtrl,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Enter your email';
                            if (!emailOk(v))
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
                                if (scorePwd(v) < 2)
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

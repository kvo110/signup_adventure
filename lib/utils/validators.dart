import 'package:flutter/material.dart';

// quick check to make sure name is long enough
bool nameOk(String v) => v.trim().length >= 2;

// basic email pattern (not too strict but catches most invalid input)
bool emailOk(String v) => RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w+$').hasMatch(v);

// password scoring system: the more conditions matched, the stronger the score
int scorePwd(String v) {
  int s = 0;
  if (v.length >= 8) s++; // good length
  if (RegExp(r'[A-Z]').hasMatch(v)) s++; // contains uppercase
  if (RegExp(r'[0-9]').hasMatch(v)) s++; // contains a number
  if (RegExp(r'''[!@#$%^&*()_\-+=\{\}\[\]:;"'<>,.?/\\|~`]''').hasMatch(v))
    s++; // has symbol
  return s;
}

// label we show user based on score
String labelPwd(int s) {
  if (s <= 1) return 'Weak';
  if (s == 2) return 'Okay';
  if (s == 3) return 'Strong';
  return 'Very Strong';
}

// color feedback for password strength bar
Color colorPwd(BuildContext ctx, int s) {
  final cs = Theme.of(ctx).colorScheme;
  if (s <= 1) return Colors.red;
  if (s == 2) return Colors.orange;
  if (s == 3) return Colors.teal;
  return cs.primary;
}

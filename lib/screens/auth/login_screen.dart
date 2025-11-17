import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _obscure = true;
  bool _isLoading = false; // 🔹 manejamos la carga localmente

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    // 🔹 Disparamos el evento del bloc
    context.read<AuthBloc>().add(
      AuthLoginRequested(email: _email, password: _password),
    );

    // 🔹 Esperamos un poco para mostrar feedback
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.unauthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error al iniciar sesión')),
            );
          }
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 48),
                    const _PatoLogo(),
                    const SizedBox(height: 16),
                    const Text(
                      'Pato Delivery',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 36),
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.amber,
                      decoration: _buildFieldDecoration('Email'),
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (v) => _email = v!.trim(),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingresá tu email';
                        if (!v.contains('@')) return 'Email inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      obscureText: _obscure,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.amber,
                      decoration: _buildFieldDecoration(
                        'Contraseña',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.amber,
                          ),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                      onSaved: (v) => _password = v!.trim(),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Ingresá tu contraseña';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                    FilledButton(
                      onPressed: _isLoading ? null : _login,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Ingresar'),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildFieldDecoration(
    String label, {
    Widget? suffixIcon,
  }) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.amber),
    );
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.amber),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: baseBorder,
      focusedBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: Colors.amber, width: 2),
      ),
      border: baseBorder,
      suffixIcon: suffixIcon,
    );
  }
}

class _PatoLogo extends StatelessWidget {
  const _PatoLogo();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Logo Pato Delivery',
      child: SizedBox(
        height: 150,
        child: CustomPaint(
          painter: _PatoLogoPainter(),
          size: const Size.square(150),
        ),
      ),
    );
  }
}

class _PatoLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shortestSide = size.shortestSide;
    final origin = Offset((size.width - shortestSide) / 2,
        (size.height - shortestSide) / 2);
    Offset p(double x, double y) =>
        Offset(origin.dx + x * shortestSide, origin.dy + y * shortestSide);

    final amber = const Color(0xFFFFC107);
    final borderPaint = Paint()
      ..color = amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = shortestSide * 0.06
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()..color = Colors.black;

    canvas.drawCircle(p(0.5, 0.5), shortestSide * 0.45, fillPaint);
    canvas.drawCircle(p(0.5, 0.5), shortestSide * 0.38, borderPaint);

    final body = Path()
      ..moveTo(p(0.32, 0.58).dx, p(0.32, 0.58).dy)
      ..quadraticBezierTo(
        p(0.55, 0.50).dx,
        p(0.55, 0.50).dy,
        p(0.70, 0.58).dx,
        p(0.70, 0.58).dy,
      )
      ..quadraticBezierTo(
        p(0.80, 0.64).dx,
        p(0.80, 0.64).dy,
        p(0.72, 0.78).dx,
        p(0.72, 0.78).dy,
      )
      ..quadraticBezierTo(
        p(0.50, 0.82).dx,
        p(0.50, 0.82).dy,
        p(0.34, 0.74).dx,
        p(0.34, 0.74).dy,
      )
      ..quadraticBezierTo(
        p(0.26, 0.68).dx,
        p(0.26, 0.68).dy,
        p(0.32, 0.58).dx,
        p(0.32, 0.58).dy,
      )
      ..close();
    canvas.drawPath(body, fillPaint);
    canvas.drawPath(
      body,
      borderPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = shortestSide * 0.018,
    );

    final headRect = Rect.fromCenter(
      center: p(0.68, 0.38),
      width: shortestSide * 0.28,
      height: shortestSide * 0.20,
    );
    canvas.drawOval(headRect, fillPaint);
    canvas.drawOval(headRect, borderPaint);

    canvas.drawCircle(p(0.74, 0.36), shortestSide * 0.03,
        Paint()..color = Colors.white);
    canvas.drawCircle(
        p(0.75, 0.36), shortestSide * 0.015, Paint()..color = Colors.black);

    final beak = Path()
      ..moveTo(p(0.80, 0.38).dx, p(0.80, 0.38).dy)
      ..lineTo(p(0.94, 0.40).dx, p(0.94, 0.40).dy)
      ..lineTo(p(0.85, 0.46).dx, p(0.85, 0.46).dy)
      ..lineTo(p(0.70, 0.43).dx, p(0.70, 0.43).dy)
      ..close();
    canvas.drawPath(beak, Paint()..color = amber);

    final hatBase = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: p(0.66, 0.26),
        width: shortestSide * 0.32,
        height: shortestSide * 0.08,
      ),
      Radius.circular(shortestSide * 0.02),
    );
    final hatTop = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: p(0.70, 0.20),
        width: shortestSide * 0.28,
        height: shortestSide * 0.12,
      ),
      Radius.circular(shortestSide * 0.03),
    );
    canvas.drawRRect(hatBase, fillPaint);
    canvas.drawRRect(hatBase, borderPaint);
    canvas.drawRRect(hatTop, fillPaint);
    canvas.drawRRect(hatTop, borderPaint);

    final bagRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: p(0.23, 0.58),
        width: shortestSide * 0.22,
        height: shortestSide * 0.26,
      ),
      Radius.circular(shortestSide * 0.04),
    );
    canvas.drawRRect(bagRect, Paint()..color = amber);
    canvas.drawRRect(
      bagRect.deflate(shortestSide * 0.04),
      fillPaint,
    );

    final lightning = Path()
      ..moveTo(p(0.20, 0.52).dx, p(0.20, 0.52).dy)
      ..lineTo(p(0.28, 0.52).dx, p(0.28, 0.52).dy)
      ..lineTo(p(0.24, 0.60).dx, p(0.24, 0.60).dy)
      ..lineTo(p(0.30, 0.60).dx, p(0.30, 0.60).dy)
      ..lineTo(p(0.20, 0.72).dx, p(0.20, 0.72).dy)
      ..lineTo(p(0.24, 0.62).dx, p(0.24, 0.62).dy)
      ..lineTo(p(0.18, 0.62).dx, p(0.18, 0.62).dy)
      ..close();
    canvas.drawPath(lightning, Paint()..color = amber);

    final wing = Path()
      ..moveTo(p(0.42, 0.58).dx, p(0.42, 0.58).dy)
      ..quadraticBezierTo(
        p(0.52, 0.54).dx,
        p(0.52, 0.54).dy,
        p(0.62, 0.62).dx,
        p(0.62, 0.62).dy,
      )
      ..lineTo(p(0.48, 0.68).dx, p(0.48, 0.68).dy)
      ..close();
    canvas.drawPath(wing, fillPaint);
    canvas.drawPath(wing, borderPaint);

    final motionPaint = Paint()
      ..color = amber
      ..strokeCap = StrokeCap.round
      ..strokeWidth = shortestSide * 0.03;
    for (var i = 0; i < 3; i++) {
      final y = 0.64 + i * 0.04;
      canvas.drawLine(p(0.08 + i * 0.04, y), p(0.20 + i * 0.04, y), motionPaint);
    }

    canvas.drawLine(
      p(0.20, 0.84),
      p(0.76, 0.84),
      motionPaint..strokeWidth = shortestSide * 0.02,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

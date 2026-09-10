import 'dart:async';
import 'package:flutter/material.dart';

class SplashPublicoExtra extends StatefulWidget {
  final Widget destino;

  const SplashPublicoExtra({
    super.key,
    required this.destino,
  });

  @override
  State<SplashPublicoExtra> createState() => _SplashPublicoExtraState();
}

class _SplashPublicoExtraState extends State<SplashPublicoExtra>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _institutionController;
  late final AnimationController _appController;
  late final AnimationController _shineController;
  late final AnimationController _exitController;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _institutionFade;
  late final Animation<Offset> _institutionSlide;
  late final Animation<double> _appFade;
  late final Animation<Offset> _appSlide;
  late final Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    );
    _logoScale = Tween<double>(begin: .72, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _institutionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _institutionFade = CurvedAnimation(
      parent: _institutionController,
      curve: Curves.easeOut,
    );
    _institutionSlide = Tween<Offset>(
      begin: const Offset(0, .18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _institutionController, curve: Curves.easeOut),
    );

    _appController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _appFade = CurvedAnimation(
      parent: _appController,
      curve: Curves.easeOut,
    );
    _appSlide = Tween<Offset>(
      begin: const Offset(0, .25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _appController, curve: Curves.easeOutBack),
    );

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _exitFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    await _logoController.forward();

    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    _institutionController.forward();

    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    _appController.forward();
    _shineController.repeat();

    await Future<void>.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;
    await _exitController.forward();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => widget.destino,
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _institutionController.dispose();
    _appController.dispose();
    _shineController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isSmall = size.height < 700;

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _exitFade,
        child: Stack(
          children: [
            const _BackgroundGlow(),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FadeTransition(
                          opacity: _logoFade,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: isSmall ? 190 : 225,
                                  height: isSmall ? 190 : 225,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF1597D4)
                                            .withOpacity(.10),
                                        blurRadius: 55,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                                Image.asset(
                                  'assets/escudo_iguaba.png',
                                  width: isSmall ? 185 : 215,
                                  height: isSmall ? 185 : 215,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: isSmall ? 16 : 25),
                        SlideTransition(
                          position: _institutionSlide,
                          child: FadeTransition(
                            opacity: _institutionFade,
                            child: const _InstitutionText(),
                          ),
                        ),
                        SizedBox(height: isSmall ? 28 : 42),
                        SlideTransition(
                          position: _appSlide,
                          child: FadeTransition(
                            opacity: _appFade,
                            child: _AppName(shine: _shineController),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 18,
              child: Text(
                'SEMOP • EXTRAS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 9,
                  letterSpacing: 2.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -.15),
            radius: .85,
            colors: [
              Color(0x160A9DDD),
              Color(0x050A9DDD),
              Colors.transparent,
            ],
            stops: [0, .45, 1],
          ),
        ),
      ),
    );
  }
}

class _InstitutionText extends StatelessWidget {
  const _InstitutionText();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'PREFEITURA MUNICIPAL',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.1,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'DE IGUABA GRANDE',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.1,
          ),
        ),
        const SizedBox(height: 14),
        Container(width: 42, height: 1, color: Colors.white24),
        const SizedBox(height: 14),
        const Text(
          'SECRETARIA MUNICIPAL DE',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 10.5,
            letterSpacing: 1.25,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'SEGURANÇA E ORDEM PÚBLICA',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.05,
          ),
        ),
      ],
    );
  }
}

class _AppName extends StatelessWidget {
  const _AppName({required this.shine});

  final Animation<double> shine;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'EXTRAS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: 6,
          ),
        ),
        const SizedBox(height: 1),
        const Text(
          'SEMOP',
          style: TextStyle(
            color: Color(0xFF16A9EA),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 7,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: 170,
          height: 3,
          child: AnimatedBuilder(
            animation: shine,
            builder: (context, _) {
              return CustomPaint(
                painter: _LinePainter(progress: shine.value),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LinePainter extends CustomPainter {
  const _LinePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()
      ..color = const Color(0xFF16A9EA).withOpacity(.25)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      base,
    );

    final x = (progress * (size.width + 50)) - 25;
    final shinePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Colors.transparent,
          Color(0xFF8DDEFF),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(x - 35, 0, 70, size.height));
    canvas.drawRect(
      Rect.fromLTWH(x - 35, 0, 70, size.height),
      shinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}


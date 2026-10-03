import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'scan_verification_screen.dart';

// ── DATA MODEL ─────────────────────────────────────────────────────────────

class _PoseStep {
  final int step;
  final String poseLabel;
  final String instruction;
  final String guidance;
  final String imagePath;
  final String shoulderLabel;
  final String waistLabel;

  const _PoseStep({
    required this.step,
    required this.poseLabel,
    required this.instruction,
    required this.guidance,
    required this.imagePath,
    required this.shoulderLabel,
    required this.waistLabel,
  });
}

// ── BODY SCAN SCREEN ────────────────────────────────────────────────────────

class BodyScanScreen extends StatefulWidget {
  const BodyScanScreen({super.key});

  @override
  State<BodyScanScreen> createState() => _BodyScanScreenState();
}

class _BodyScanScreenState extends State<BodyScanScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _isCapturing = false;
  final bool _isDetected = true;
  final List<bool> _captured = [false, false, false];

  // Countdown timer
  int _countdown = 0;
  Timer? _countdownTimer;

  late AnimationController _pulseController;
  late AnimationController _scanLineController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanLineAnimation;

  final List<_PoseStep> _poses = const [
    _PoseStep(
      step: 1,
      poseLabel: "POSE FACE",
      instruction:
          "Regardez la caméra naturellement avec les épaules détendues et les bras légèrement écartés du corps.",
      guidance:
          "Gardez les bras à 30° de votre corps et regardez droit devant",
      imagePath: "assets/images/scan_front_pose.jpg",
      shoulderLabel: "LIGNE DES ÉPAULES",
      waistLabel: "TAILLE NATURELLE",
    ),
    _PoseStep(
      step: 2,
      poseLabel: "POSE PROFIL",
      instruction:
          "Tournez-vous de profil à 90° avec une posture bien droite, les bras le long du corps.",
      guidance: "Tenez-vous droit, bras le long du corps, regardez de côté",
      imagePath: "assets/images/scan_profile_pose.jpg",
      shoulderLabel: "LIGNE ÉPAULES",
      waistLabel: "PROFIL TAILLE",
    ),
    _PoseStep(
      step: 3,
      poseLabel: "POSE DOS",
      instruction:
          "Tournez-vous de dos face à la caméra, les mains éloignées des hanches.",
      guidance: "Tournez complètement, mains éloignées des hanches",
      imagePath: "assets/images/scan_back_pose.jpg",
      shoulderLabel: "LIGNE DOS",
      waistLabel: "TAILLE DOS",
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.linear),
    );

    _initScan();
  }

  void _initScan() {
    // Simulated scan — no real camera needed
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() {});
    });
  }

  void _start3sAutoTimer() {
    if (_isCapturing || _countdown > 0) return;
    setState(() => _countdown = 3);

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        setState(() => _countdown = 0);
        _capturePhoto();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  void _capturePhoto() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    // Simulate capture with short delay
    await Future.delayed(const Duration(milliseconds: 600));

    setState(() {
      _captured[_currentStep] = true;
      _isCapturing = false;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      // All 3 poses done → navigate to ScanVerificationScreen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ScanVerificationScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pose = _poses[_currentStep];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── SIMULATED SCAN POSE IMAGE ──────────────────────────────
          Positioned.fill(
            child: Image.asset(
              pose.imagePath,
              fit: BoxFit.cover,
            ),
          ),

          // ── DARK OVERLAY FOR SCANNABILITY ─────────────────────────
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.35),
            ),
          ),

          // ── ANIMATED SCAN LINE ────────────────────────────────────
          if (!_captured[_currentStep])
            AnimatedBuilder(
              animation: _scanLineAnimation,
              builder: (context, child) {
                final screenHeight = MediaQuery.of(context).size.height;
                return Positioned(
                  top: screenHeight * 0.12 +
                      (screenHeight * 0.58 * _scanLineAnimation.value),
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          const Color(0xFFF43F5E).withValues(alpha: 0.8),
                          const Color(0xFFF43F5E),
                          const Color(0xFFF43F5E).withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF43F5E).withValues(alpha: 0.8),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          // ── ACCURATE WHITE HUMAN SILHOUETTE OUTLINE OVERLAY ─────────
          Positioned.fill(
            child: CustomPaint(
              painter: _HumanOutlinePainter(
                step: _currentStep,
                isDetected: _isDetected,
              ),
            ),
          ),

          // ── BODY MEASUREMENT OVERLAYS ─────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height * 0.28,
            child: _buildMeasurementLine(pose.shoulderLabel),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height * 0.46,
            child: _buildMeasurementLine(pose.waistLabel),
          ),

          // ── CORNER FRAME BRACKETS ─────────────────────────────────
          _buildCornerBrackets(context),

          // ── TOP BAR (Cleaned up: Close button + Step Pill) ─────────
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(pose),
                const SizedBox(height: 8),
                _buildDetectionPill(),
              ],
            ),
          ),

          // ── BOTTOM CONTROLS & STEP DOTS ────────────────────────────
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAudioGuidanceCard(pose),
                const SizedBox(height: 8),
                _buildCaptureControls(),
                const SizedBox(height: 14),
                _buildStepDots(),
              ],
            ),
          ),

          // ── COUNTDOWN OVERLAY ──────────────────────────────────────
          if (_countdown > 0)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
                child: Center(
                  child: Text(
                    "$_countdown",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 110,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFF43F5E),
                    ),
                  ),
                ),
              ),
            ),

          // ── CAPTURE FLASH OVERLAY ──────────────────────────────────
          if (_isCapturing)
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
    );
  }

  // ── CLEAN TOP BAR ────────────────────────────────────────────────────────
  Widget _buildTopBar(_PoseStep pose) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25), width: 1),
              ),
              child: const Icon(Icons.close_rounded,
                  size: 20, color: Colors.white),
            ),
          ),

          // Step indicator pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF43F5E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${pose.step} SUR 3 • ${pose.poseLabel}",
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Empty spacer to keep step indicator perfectly centered
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  // ── DETECTION PILL ────────────────────────────────────────────────────────
  Widget _buildDetectionPill() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF34A853)
                    .withValues(alpha: _pulseAnimation.value),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF34A853)
                        .withValues(alpha: 0.5 * _pulseAnimation.value),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _isDetected
                  ? "Restez à 2m • Corps entier détecté"
                  : "Ajustez votre position...",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            _isDetected ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 14,
            color: _isDetected ? const Color(0xFF34A853) : Colors.white54,
          ),
        ],
      ),
    );
  }

  // ── MEASUREMENT LINE ──────────────────────────────────────────────────────
  Widget _buildMeasurementLine(String label) {
    return Row(
      children: [
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFF43F5E).withValues(alpha: 0.6),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: const Color(0xFFF43F5E).withValues(alpha: 0.5), width: 1),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFF43F5E),
              letterSpacing: 0.6,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFF43F5E).withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  // ── CORNER BRACKETS ───────────────────────────────────────────────────────
  Widget _buildCornerBrackets(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    const bracketSize = 24.0;
    const bracketThick = 3.0;
    const color = Color(0xFFF43F5E);
    final marginH = w * 0.05;
    final marginV = h * 0.12;

    return Stack(
      children: [
        Positioned(
            top: marginV,
            left: marginH,
            child: _bracket(bracketSize, bracketThick, color, false, false)),
        Positioned(
            top: marginV,
            right: marginH,
            child: _bracket(bracketSize, bracketThick, color, false, true)),
        Positioned(
            bottom: h * 0.28,
            left: marginH,
            child: _bracket(bracketSize, bracketThick, color, true, false)),
        Positioned(
            bottom: h * 0.28,
            right: marginH,
            child: _bracket(bracketSize, bracketThick, color, true, true)),
      ],
    );
  }

  Widget _bracket(double size, double thick, Color color, bool flipV, bool flipH) {
    return Transform.flip(
      flipX: flipH,
      flipY: flipV,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _BracketPainter(color: color, thickness: thick),
        ),
      ),
    );
  }

  // ── AUDIO GUIDANCE CARD ───────────────────────────────────────────────────
  Widget _buildAudioGuidanceCard(_PoseStep pose) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFF43F5E).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.graphic_eq_rounded,
                size: 16, color: Color(0xFFF43F5E)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              pose.guidance,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── CAPTURE CONTROLS ──────────────────────────────────────────────────────
  Widget _buildCaptureControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 3s AUTO timer
          Column(
            children: [
              GestureDetector(
                onTap: _start3sAutoTimer,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3), width: 1),
                  ),
                  child: const Icon(Icons.timer_rounded,
                      size: 22, color: Colors.white),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "3s AUTO",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),

          // Main capture button
          GestureDetector(
            onTap: _capturePhoto,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _captured[_currentStep]
                      ? const Color(0xFF34A853)
                      : const Color(0xFFF43F5E),
                  boxShadow: [
                    BoxShadow(
                      color: (_captured[_currentStep]
                              ? const Color(0xFF34A853)
                              : const Color(0xFFF43F5E))
                          .withValues(alpha: 0.5 * _pulseAnimation.value),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  _captured[_currentStep]
                      ? Icons.check_rounded
                      : Icons.camera_alt_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Flip camera button (decorative in simulated mode)
          Column(
            children: [
              GestureDetector(
                onTap: null,
                child: Opacity(
                  opacity: 0.4,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3), width: 1),
                    ),
                    child: const Icon(Icons.flip_camera_ios_rounded,
                        size: 22, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "INVERSER",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── STEP DOTS ─────────────────────────────────────────────────────────────
  Widget _buildStepDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final done = _captured[i];
        final current = i == _currentStep;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: current ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: done
                ? const Color(0xFF34A853)
                : current
                    ? const Color(0xFFF43F5E)
                    : Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ── ACCURATE PROPORTIONED HUMAN SILHOUETTE PAINTER ─────────────────────────
class _HumanOutlinePainter extends CustomPainter {
  final int step; // 0: FRONT, 1: PROFILE, 2: BACK
  final bool isDetected;

  const _HumanOutlinePainter({
    required this.step,
    required this.isDetected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeColor = Colors.white.withValues(alpha: 0.9);
    final glowColor = const Color(0xFFF43F5E).withValues(alpha: 0.5);

    final linePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = glowColor
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    final dotPaint = Paint()
      ..color = isDetected ? const Color(0xFF34A853) : const Color(0xFFF43F5E)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final topY = size.height * 0.18;

    if (step == 0) {
      // ── STEP 1: FRONT POSE OUTLINE ──────────────────────────────────────
      final headCenter = Offset(cx, topY + 45);
      final headRadiusX = 36.0;
      final headRadiusY = 48.0;

      // Glow + Head
      canvas.drawOval(Rect.fromCenter(center: headCenter, width: headRadiusX * 2, height: headRadiusY * 2), glowPaint);
      canvas.drawOval(Rect.fromCenter(center: headCenter, width: headRadiusX * 2, height: headRadiusY * 2), linePaint);

      final shoulderY = topY + 115;
      final shoulderW = 82.0;
      final waistY = topY + 200;
      final waistW = 46.0;
      final hipY = topY + 250;
      final hipW = 60.0;
      final feetY = topY + 440;

      final bodyPath = Path();
      // Right shoulder curve from neck
      bodyPath.moveTo(cx - 14, topY + 92);
      bodyPath.quadraticBezierTo(cx - 45, topY + 98, cx - shoulderW, shoulderY);
      // Right arm slightly out at 30°
      bodyPath.quadraticBezierTo(cx - (shoulderW + 22), shoulderY + 80, cx - (shoulderW + 30), shoulderY + 180); // Hand
      bodyPath.lineTo(cx - (shoulderW + 14), shoulderY + 180);
      bodyPath.quadraticBezierTo(cx - (shoulderW + 8), shoulderY + 80, cx - (shoulderW - 12), shoulderY + 40);

      // Torso right side
      bodyPath.quadraticBezierTo(cx - waistW, waistY, cx - hipW, hipY);
      // Right leg
      bodyPath.quadraticBezierTo(cx - 52, topY + 340, cx - 44, feetY);
      bodyPath.lineTo(cx - 16, feetY);
      bodyPath.quadraticBezierTo(cx - 20, topY + 340, cx - 8, hipY + 40); // Crotch

      // Left leg
      bodyPath.quadraticBezierTo(cx + 20, topY + 340, cx + 16, feetY);
      bodyPath.lineTo(cx + 44, feetY);
      bodyPath.quadraticBezierTo(cx + 52, topY + 340, cx + hipW, hipY);

      // Torso left side
      bodyPath.quadraticBezierTo(cx + waistW, waistY, cx + (shoulderW - 12), shoulderY + 40);

      // Left arm slightly out at 30°
      bodyPath.quadraticBezierTo(cx + (shoulderW + 8), shoulderY + 80, cx + (shoulderW + 14), shoulderY + 180); // Hand
      bodyPath.lineTo(cx + (shoulderW + 30), shoulderY + 180);
      bodyPath.quadraticBezierTo(cx + (shoulderW + 22), shoulderY + 80, cx + shoulderW, shoulderY);

      // Neck left side
      bodyPath.quadraticBezierTo(cx + 45, topY + 98, cx + 14, topY + 92);

      canvas.drawPath(bodyPath, glowPaint);
      canvas.drawPath(bodyPath, linePaint);

      // Alignment landmarks
      canvas.drawCircle(headCenter, 4.5, dotPaint);
      canvas.drawCircle(Offset(cx - shoulderW, shoulderY), 4, dotPaint);
      canvas.drawCircle(Offset(cx + shoulderW, shoulderY), 4, dotPaint);
      canvas.drawCircle(Offset(cx - waistW, waistY), 4, dotPaint);
      canvas.drawCircle(Offset(cx + waistW, waistY), 4, dotPaint);

    } else if (step == 1) {
      // ── STEP 2: PROFILE/SIDE POSE OUTLINE ──────────────────────────────
      final headCenter = Offset(cx, topY + 45);

      // Head side profile oval
      canvas.drawOval(Rect.fromCenter(center: headCenter, width: 68, height: 92), glowPaint);
      canvas.drawOval(Rect.fromCenter(center: headCenter, width: 68, height: 92), linePaint);

      final profilePath = Path();
      // Nose / Chin side contour
      profilePath.moveTo(cx + 25, topY + 40); // Nose tip
      profilePath.lineTo(cx + 34, topY + 45);
      profilePath.lineTo(cx + 22, topY + 58); // Mouth
      profilePath.lineTo(cx + 26, topY + 70); // Chin
      profilePath.lineTo(cx + 12, topY + 92); // Neck front

      // Chest side depth
      profilePath.quadraticBezierTo(cx + 42, topY + 140, cx + 30, topY + 200); // Chest
      profilePath.quadraticBezierTo(cx + 22, topY + 240, cx + 24, topY + 280); // Thigh front
      profilePath.lineTo(cx + 18, topY + 440); // Leg front
      profilePath.lineTo(cx - 18, topY + 440); // Heel
      profilePath.quadraticBezierTo(cx - 32, topY + 320, cx - 28, topY + 260); // Buttock
      profilePath.quadraticBezierTo(cx - 35, topY + 180, cx - 24, topY + 115); // Back curve
      profilePath.lineTo(cx - 14, topY + 92); // Neck back

      canvas.drawPath(profilePath, glowPaint);
      canvas.drawPath(profilePath, linePaint);

      // Arm at side profile
      final armPath = Path();
      armPath.moveTo(cx - 5, topY + 118);
      armPath.quadraticBezierTo(cx + 2, topY + 180, cx + 6, topY + 250);
      canvas.drawPath(armPath, linePaint);

      canvas.drawCircle(headCenter, 4.5, dotPaint);
      canvas.drawCircle(Offset(cx + 28, topY + 140), 4, dotPaint);
      canvas.drawCircle(Offset(cx - 28, topY + 260), 4, dotPaint);

    } else {
      // ── STEP 3: BACK POSE OUTLINE ──────────────────────────────────────
      final headCenter = Offset(cx, topY + 45);

      canvas.drawOval(Rect.fromCenter(center: headCenter, width: 70, height: 90), glowPaint);
      canvas.drawOval(Rect.fromCenter(center: headCenter, width: 70, height: 90), linePaint);

      final shoulderY = topY + 115;
      final shoulderW = 82.0;

      final backPath = Path();
      backPath.moveTo(cx - 14, topY + 92);
      backPath.quadraticBezierTo(cx - 45, topY + 98, cx - shoulderW, shoulderY);
      backPath.quadraticBezierTo(cx - (shoulderW + 22), shoulderY + 80, cx - (shoulderW + 30), shoulderY + 180);
      backPath.lineTo(cx - (shoulderW + 14), shoulderY + 180);
      backPath.quadraticBezierTo(cx - (shoulderW + 8), shoulderY + 80, cx - (shoulderW - 12), shoulderY + 40);

      backPath.quadraticBezierTo(cx - 46, topY + 200, cx - 60, topY + 250);
      backPath.quadraticBezierTo(cx - 52, topY + 340, cx - 44, topY + 440);
      backPath.lineTo(cx - 16, topY + 440);
      backPath.quadraticBezierTo(cx - 20, topY + 340, cx - 8, topY + 290);

      backPath.quadraticBezierTo(cx + 20, topY + 340, cx + 16, topY + 440);
      backPath.lineTo(cx + 44, topY + 440);
      backPath.quadraticBezierTo(cx + 52, topY + 340, cx + 60, topY + 250);
      backPath.quadraticBezierTo(cx + 46, topY + 200, cx + (shoulderW - 12), shoulderY + 40);

      backPath.quadraticBezierTo(cx + (shoulderW + 8), shoulderY + 80, cx + (shoulderW + 14), shoulderY + 180);
      backPath.lineTo(cx + (shoulderW + 30), shoulderY + 180);
      backPath.quadraticBezierTo(cx + (shoulderW + 22), shoulderY + 80, cx + shoulderW, shoulderY);
      backPath.quadraticBezierTo(cx + 45, topY + 98, cx + 14, topY + 92);

      canvas.drawPath(backPath, glowPaint);
      canvas.drawPath(backPath, linePaint);

      canvas.drawCircle(headCenter, 4.5, dotPaint);
      canvas.drawCircle(Offset(cx - shoulderW, shoulderY), 4, dotPaint);
      canvas.drawCircle(Offset(cx + shoulderW, shoulderY), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── BRACKET PAINTER ───────────────────────────────────────────────────────────
class _BracketPainter extends CustomPainter {
  final Color color;
  final double thickness;

  const _BracketPainter({required this.color, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(0, 0), Offset(0, size.height * 0.6), paint);
    canvas.drawLine(const Offset(0, 0), Offset(size.width * 0.6, 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../home/presentation/screens/home_screen.dart';
import 'avatar_preview_screen.dart';

class NeuralMeshProcessingScreen extends StatefulWidget {
  const NeuralMeshProcessingScreen({super.key});

  @override
  State<NeuralMeshProcessingScreen> createState() =>
      _NeuralMeshProcessingScreenState();
}

class _NeuralMeshProcessingScreenState extends State<NeuralMeshProcessingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Timer? _progressTimer;

  int _progress = 15;
  int _estimatedSeconds = 8;
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _startProgressSimulation();
  }

  void _startProgressSimulation() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (!mounted || _isCancelled) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_progress < 100) {
          _progress += 3;
          if (_progress > 100) _progress = 100;

          // Estimate remaining time
          _estimatedSeconds = math.max(0, ((100 - _progress) / 12).ceil());
        } else {
          timer.cancel();
          _onProcessingComplete();
        }
      });
    });
  }

  void _onProcessingComplete() {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted || _isCancelled) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.greenAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                "Avatar 3D généré avec succès !",
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AvatarPreviewScreen()),
      );
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // Calculate active pipeline step
    int activeStep = 0;
    if (_progress >= 30 && _progress < 60) {
      activeStep = 1;
    } else if (_progress >= 60 && _progress < 90) {
      activeStep = 2;
    } else if (_progress >= 90) {
      activeStep = 3;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B101D), // Dark slate/navy background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // ── TOP HEADER BAR ──────────────────────────────────────
              _buildTopHeader(),

              const SizedBox(height: 14),

              // ── 3D MANNEQUIN WIREFRAME DISPLAY ──────────────────────
              Expanded(
                flex: 5,
                child: _buildWireframeCanvas(),
              ),

              const SizedBox(height: 16),

              // ── PROGRESS PERCENTAGE & TIME ─────────────────────────
              _buildProgressSection(),

              const SizedBox(height: 16),

              // ── PIPELINE SEQUENCE ──────────────────────────────────
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SÉQUENCE DU PIPELINE",
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF64748B),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Step 1: Photogrammétrie Optique
                      _buildPipelineStep(
                        stepIndex: 0,
                        activeStep: activeStep,
                        title: "Photogrammétrie Optique",
                        subtitle:
                            "Alignement des repères de pose 3 angles synchronisé",
                      ),

                      const SizedBox(height: 8),

                      // Step 2: Nuage de Points Biométriques
                      _buildPipelineStep(
                        stepIndex: 1,
                        activeStep: activeStep,
                        title: "Nuage de Points Biométriques",
                        subtitle: "48 coordonnées anatomiques ancrées",
                      ),

                      const SizedBox(height: 8),

                      // Step 3: Génération du Maillage Neural
                      _buildPipelineStep(
                        stepIndex: 2,
                        activeStep: activeStep,
                        title: "Génération du Maillage Neural",
                        subtitle: "Surfaçage polygonale sous-millimétrique",
                      ),

                      const SizedBox(height: 8),

                      // Step 4: Liaison du Moteur Physique
                      _buildPipelineStep(
                        stepIndex: 3,
                        activeStep: activeStep,
                        title: "Liaison du Moteur Physique",
                        subtitle: "Drapé du tissu & étalonnage de tension",
                      ),

                      const SizedBox(height: 14),

                      // ── SECURITY ENCLAVE CARD ────────────────────────
                      _buildSecurityCard(),

                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),

              // ── CANCEL BUTTON ───────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _isCancelled = true);
                    _progressTimer?.cancel();
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: const Color(0xFF94A3B8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFF334155)),
                    ),
                  ),
                  child: Text(
                    "Annuler le traitement",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── TOP HEADER BAR ──────────────────────────────────────────────────
  Widget _buildTopHeader() {
    return Row(
      children: [
        // Left Badge
        Expanded(
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFF43F5E),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFF43F5E),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  "COMPILATION DU MAILLAGE NEURAL",
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFF43F5E),
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Right Complete Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Text(
            "$_progress% TERMINÉ",
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  // ── 3D MANNEQUIN WIREFRAME CANVAS ────────────────────────────────────
  Widget _buildWireframeCanvas() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Corner Viewfinder Brackets
          _buildCornerBracket(top: 14, left: 14, isTop: true, isLeft: true),
          _buildCornerBracket(top: 14, right: 14, isTop: true, isLeft: false),
          _buildCornerBracket(bottom: 14, left: 14, isTop: false, isLeft: true),
          _buildCornerBracket(bottom: 14, right: 14, isTop: false, isLeft: false),

          // Animated Custom Wireframe Painter
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(220, 260),
                painter: _WireframePainter(
                  animationValue: _animController.value,
                  progress: _progress,
                ),
              );
            },
          ),

          // Floating Overlay Badge at Bottom of Canvas
          Positioned(
            bottom: 18,
            left: 16,
            right: 16,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFFF43F5E).withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF43F5E).withValues(alpha: 0.15),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.blur_on_rounded,
                          size: 14, color: Color(0xFFF43F5E)),
                      const SizedBox(width: 6),
                      Text(
                        "SYNTHÈSE DU RIG DE VÊTEMENT 4D",
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerBracket({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required bool isTop,
    required bool isLeft,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(color: Color(0xFF475569), width: 2)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: Color(0xFF475569), width: 2)
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(color: Color(0xFF475569), width: 2)
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(color: Color(0xFF475569), width: 2)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ── PROGRESS PERCENTAGE & ESTIMATED TIME ─────────────────────────────
  Widget _buildProgressSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "$_progress",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "%",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFF43F5E),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                "Temps restant estimé : ~${_estimatedSeconds}s",
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Glowing Gradient Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 6,
            width: double.infinity,
            color: const Color(0xFF1E293B),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _progress / 100.0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFE11D48),
                      Color(0xFFF43F5E),
                      Color(0xFFFB7185),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFF43F5E),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── PIPELINE STEP ITEM ──────────────────────────────────────────────
  Widget _buildPipelineStep({
    required int stepIndex,
    required int activeStep,
    required String title,
    required String subtitle,
  }) {
    final bool isDone = stepIndex < activeStep;
    final bool isActive = stepIndex == activeStep;

    Color containerBg = const Color(0xFF111827).withValues(alpha: 0.5);
    Color borderColor = const Color(0xFF1E293B);

    if (isActive) {
      containerBg = const Color(0xFF1E1C2A);
      borderColor = const Color(0xFFF43F5E).withValues(alpha: 0.6);
    } else if (isDone) {
      containerBg = const Color(0xFF0F172A);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isActive ? 1.5 : 1.0),
      ),
      child: Row(
        children: [
          // Step Status Icon
          if (isDone)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  size: 14, color: Color(0xFF38BDF8)),
            )
          else if (isActive)
            RotationTransition(
              turns: _animController,
              child: const Icon(Icons.sync_rounded,
                  size: 18, color: Color(0xFFF43F5E)),
            )
          else
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF475569), width: 2),
              ),
            ),

          const SizedBox(width: 12),

          // Titles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? const Color(0xFFF43F5E)
                        : (isDone ? Colors.white : const Color(0xFF94A3B8)),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Status Badge Text
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              isDone ? "TERMINÉ" : (isActive ? "EN COURS" : "EN ATTENTE"),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isActive
                    ? const Color(0xFFF43F5E)
                    : (isDone
                        ? const Color(0xFF38BDF8)
                        : const Color(0xFF475569)),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SECURITY ENCLAVE CARD ───────────────────────────────────────────
  Widget _buildSecurityCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shield_outlined,
                size: 16, color: Color(0xFF38BDF8)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Photos traitées uniquement en mémoire volatile et purgées instantanément. Jeton Secure Enclave chiffré créé.",
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF94A3B8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── CUSTOM PAINTER FOR 3D MANNEQUIN WIREFRAME & ORBITING RINGS ─────────
class _WireframePainter extends CustomPainter {
  final double animationValue;
  final int progress;

  _WireframePainter({required this.animationValue, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final linePaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final dashPaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final nodePaint = Paint()
      ..color = const Color(0xFFF43F5E)
      ..style = PaintingStyle.fill;

    // Mannequin points
    final headCenter = Offset(center.dx, center.dy - 75);
    final neck = Offset(center.dx, center.dy - 55);

    final leftShoulder = Offset(center.dx - 45, center.dy - 45);
    final rightShoulder = Offset(center.dx + 45, center.dy - 45);

    final leftWaist = Offset(center.dx - 28, center.dy + 5);
    final rightWaist = Offset(center.dx + 28, center.dy + 5);

    final leftHip = Offset(center.dx - 38, center.dy + 45);
    final rightHip = Offset(center.dx + 38, center.dy + 45);

    final leftKnee = Offset(center.dx - 28, center.dy + 105);
    final rightKnee = Offset(center.dx + 28, center.dy + 105);

    // Draw Head Circle
    canvas.drawOval(
      Rect.fromCenter(center: headCenter, width: 34, height: 44),
      linePaint,
    );

    // Shoulder line
    canvas.drawLine(leftShoulder, rightShoulder, linePaint);

    // Torso outline curves (Hourglass)
    final path = Path()
      ..moveTo(leftShoulder.dx, leftShoulder.dy)
      ..quadraticBezierTo(
          center.dx - 15, center.dy - 20, leftWaist.dx, leftWaist.dy)
      ..lineTo(leftHip.dx, leftHip.dy)
      ..lineTo(rightHip.dx, rightHip.dy)
      ..lineTo(rightWaist.dx, rightWaist.dy)
      ..quadraticBezierTo(
          center.dx + 15, center.dy - 20, rightShoulder.dx, rightShoulder.dy)
      ..close();
    canvas.drawPath(path, linePaint);

    // Dotted Legs
    _drawDottedLine(canvas, leftHip, leftKnee, dashPaint);
    _drawDottedLine(canvas, rightHip, rightKnee, dashPaint);

    // Internal Grid Lines (3D Mesh feeling)
    canvas.drawLine(neck, Offset(center.dx, center.dy + 45), dashPaint);
    canvas.drawLine(leftShoulder, rightWaist, dashPaint);
    canvas.drawLine(rightShoulder, leftWaist, dashPaint);

    // Orbiting 3D Ring around Waist
    final ringY = center.dy + 5;
    final ringRadiusX = 65.0 + math.sin(animationValue * 2 * math.pi) * 3;
    final ringRadiusY = 16.0;

    final ringPaint = Paint()
      ..color = const Color(0xFFF43F5E).withValues(alpha: 0.8)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx, ringY),
          width: ringRadiusX * 2,
          height: ringRadiusY * 2),
      ringPaint,
    );

    // Keypoint Red Nodes
    final nodes = [
      headCenter,
      leftShoulder,
      rightShoulder,
      leftWaist,
      rightWaist,
      leftHip,
      rightHip,
      leftKnee,
      rightKnee,
    ];

    for (final node in nodes) {
      canvas.drawCircle(node, 3.5, nodePaint);
      canvas.drawCircle(
          node, 6.0, Paint()..color = const Color(0xFFF43F5E).withValues(alpha: 0.3));
    }
  }

  void _drawDottedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 4;
    const double dashSpace = 4;
    double startY = p1.dy;
    while (startY < p2.dy) {
      canvas.drawLine(
        Offset(p1.dx, startY),
        Offset(p1.dx, math.min(startY + dashWidth, p2.dy)),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _WireframePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.progress != progress;
  }
}

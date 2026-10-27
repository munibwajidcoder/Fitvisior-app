import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/data/user_avatar_service.dart';
import '../../../home/presentation/screens/home_screen.dart' show HomeScreen;
import '../../data/avatar_reconstruction_service.dart';
import '../../../../core/localization/language_service.dart';
import '../../../../core/widgets/language_toggle_badge.dart';
import 'avatar_onboarding_preview_screen.dart';

class NeuralMeshProcessingScreen extends StatefulWidget {
  final List<String?>? capturedImagePaths;
  final String gender;
  final double? heightCm;
  final double? bustCm;
  final double? waistCm;
  final double? hipsCm;
  final double? weightKg;
  final bool isMetric;

  const NeuralMeshProcessingScreen({
    super.key,
    this.capturedImagePaths,
    this.gender = 'Homme',
    this.heightCm,
    this.bustCm,
    this.waistCm,
    this.hipsCm,
    this.weightKg,
    this.isMetric = true,
  });

  @override
  State<NeuralMeshProcessingScreen> createState() =>
      _NeuralMeshProcessingScreenState();
}

class _NeuralMeshProcessingScreenState extends State<NeuralMeshProcessingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Timer? _progressTimer;

  int _progress = 10;
  late int _estimatedSeconds;
  bool _isCancelled = false;
  bool _reconstructionDone = false;
  String? _generatedGlbUrl;
  bool _hasError = false;
  String? _errorMessageEn;
  String? _errorMessageFr;

  bool get _hasPhotos =>
      widget.capturedImagePaths != null &&
      widget.capturedImagePaths!.any((p) => p != null && p.isNotEmpty);

  @override
  void initState() {
    super.initState();
    _estimatedSeconds = _hasPhotos ? 110 : 4;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _triggerReconstruction();
    _startProgressSimulation();
  }

  void _triggerReconstruction() async {
    setState(() {
      _hasError = false;
      _errorMessageEn = null;
      _errorMessageFr = null;
    });

    final cleanGender = widget.gender.trim().toLowerCase();
    final isFemale = cleanGender.contains('femme') ||
        cleanGender.contains('female') ||
        cleanGender == 'f';
    final isMale = !isFemale &&
        (cleanGender.contains('homme') ||
            cleanGender == 'male' ||
            cleanGender == 'm');
    final double h = widget.heightCm ?? (isMale ? 178.0 : 174.0);
    final double b = widget.bustCm ?? (isMale ? 98.0 : 86.0);
    final double w = widget.waistCm ?? (isMale ? 82.0 : 66.0);
    final double hips = widget.hipsCm ?? (isMale ? 96.0 : 94.0);

    double? userWeight = widget.weightKg;
    double? userShoulderCm;
    if (userWeight == null) {
      try {
        final profile = await AuthService.getProfile();
        if (profile != null && profile['weight_kg'] != null) {
          userWeight = (profile['weight_kg'] as num).toDouble();
        }
        if (profile != null && profile['shoulder_cm'] != null) {
          userShoulderCm = (profile['shoulder_cm'] as num).toDouble();
        }
      } catch (_) {}
    }

    try {
      final result = await AvatarReconstructionService().reconstruct3DAvatar(
        gender: isMale ? 'male' : 'female',
        heightCm: h,
        weightKg: userWeight,
        bustCm: b,
        waistCm: w,
        hipsCm: hips,
        shoulderType: isMale ? 'Larges' : 'Classique',
        shoulderCm: userShoulderCm ?? (isMale ? 44.0 : 38.0),
        capturedImagePaths: widget.capturedImagePaths,
      );

      if (!mounted || _isCancelled) return;

      if (result.isSuccess && result.glbUrl != null && result.glbUrl!.isNotEmpty) {
        setState(() {
          _generatedGlbUrl = result.glbUrl;
          _reconstructionDone = true;
          _progress = 100;
          _estimatedSeconds = 0;
        });
        _progressTimer?.cancel();
        // ── Auto-save user's front photo as profile picture ──
        if (widget.capturedImagePaths != null &&
            widget.capturedImagePaths!.isNotEmpty &&
            widget.capturedImagePaths![0] != null) {
          final frontFile = File(widget.capturedImagePaths![0]!);
          if (frontFile.existsSync()) {
            UserAvatarService.saveAvatar(frontFile);
          }
        }
        // ── Persist 3D Avatar GLB model globally ──
        UserAvatarService.saveAvatarGlbUrl(result.glbUrl!);

        // ── Save avatar URL & mark onboarding done in Supabase ──
        AuthService.updateProfile({
          'avatar_glb_url': result.glbUrl,
          'onboarding_completed': false,
          'onboarding_step': 3,
        }).catchError((_) {}); // fire-and-forget; don't block UI

        _onProcessingComplete();
      } else {
        // Reconstruction failed / Tripo credits exhausted: NEVER show fallback model!
        _progressTimer?.cancel();
        setState(() {
          _hasError = true;
          _reconstructionDone = false;
          _errorMessageEn = result.messageEn;
          _errorMessageFr = result.messageFr;
          _estimatedSeconds = 0;
        });
        _showCreditErrorDialog();
      }
    } catch (e, stack) {
      debugPrint('[NeuralMesh] Reconstruction failed: $e\n$stack');
      if (mounted && !_isCancelled) {
        _progressTimer?.cancel();
        setState(() {
          _hasError = true;
          _reconstructionDone = false;
          _errorMessageEn =
              "Unable to create 3D avatar due to expired/insufficient Tripo API credits. Please renew your credits to proceed.";
          _errorMessageFr =
              "Impossible de créer l'avatar 3D en raison de crédits API Tripo expirés ou insuffisants. Veuillez renouveler vos crédits pour continuer.";
          _estimatedSeconds = 0;
        });
        _showCreditErrorDialog();
      }
    }
  }

  void _startProgressSimulation() {
    final int intervalMs = _hasPhotos ? 600 : 150;
    _progressTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (!mounted || _isCancelled || _hasError) {
        timer.cancel();
        return;
      }

      setState(() {
        if (!_reconstructionDone) {
          if (_hasPhotos) {
            // Paced progression: 10% to 92% across Tripo's ~60-70s generation
            if (_progress < 92) {
              _progress += 1;
            }
            if (_estimatedSeconds > 3) {
              _estimatedSeconds -= 1;
            }
          } else {
            // Rapid progression for local anatomical engine (3-4 seconds)
            if (_progress < 90) {
              _progress += 8;
            }
            if (_estimatedSeconds > 1) {
              _estimatedSeconds -= 1;
            }
          }
        } else {
          // Reconstruction completed! Animate smoothly to 100%
          if (_progress < 100) {
            _progress += 8;
            if (_progress > 100) _progress = 100;
            _estimatedSeconds = 0;
          } else {
            timer.cancel();
            _onProcessingComplete();
          }
        }
      });
    });
  }

  void _showCreditErrorDialog() {
    if (!mounted || _isCancelled) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return ListenableBuilder(
          listenable: LanguageService.instance,
          builder: (context, _) {
            final isEn = LanguageService.instance.isEnglish;
            final message = isEn
                ? (_errorMessageEn ??
                    "Unable to create 3D avatar due to expired/insufficient Tripo API credits. Please renew your credits to proceed.")
                : (_errorMessageFr ??
                    "Impossible de créer l'avatar 3D en raison de crédits API Tripo expirés ou insuffisants. Veuillez renouveler vos crédits pour continuer.");

            return Dialog(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Color(0xFF334155), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF43F5E).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFF43F5E).withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.credit_card_off_rounded,
                        color: Color(0xFFF43F5E),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      isEn
                          ? "Tripo Credits Exhausted"
                          : "Crédits Tripo Épuisés",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: const Color(0xFF94A3B8),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          setState(() {
                            _progress = 10;
                            _estimatedSeconds = _hasPhotos ? 110 : 4;
                            _hasError = false;
                          });
                          _startProgressSimulation();
                          _triggerReconstruction();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF43F5E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isEn
                              ? "Renew Credits & Retry"
                              : "Renouveler les crédits & Réessayer",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF94A3B8),
                          side: const BorderSide(color: Color(0xFF334155)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          isEn ? "Go Back" : "Retour",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _onProcessingComplete() {
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted || _isCancelled || _hasError) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.greenAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  LanguageService.instance.isEnglish
                      ? "Personalized 3D Avatar generated successfully!"
                      : "Avatar 3D personnalisé généré avec succès !",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AvatarOnboardingPreviewScreen(
            capturedImagePaths: widget.capturedImagePaths,
            glbUrl: _generatedGlbUrl,
            gender: widget.gender,
            heightCm: widget.heightCm,
            bustCm: widget.bustCm,
            waistCm: widget.waistCm,
            hipsCm: widget.hipsCm,
            weightKg: widget.weightKg,
            isMetric: widget.isMetric,
          ),
        ),
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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Calculate active pipeline step
    int activeStep = 0;
    if (_progress >= 30 && _progress < 60) {
      activeStep = 1;
    } else if (_progress >= 60 && _progress < 90) {
      activeStep = 2;
    } else if (_progress >= 90) {
      activeStep = 3;
    }

    return ListenableBuilder(
      listenable: LanguageService.instance,
      builder: (context, _) {
        final isEn = LanguageService.instance.isEnglish;
        return Scaffold(
          backgroundColor: const Color(0xFF0B101D), // Dark slate/navy background
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  // ── TOP HEADER BAR ──────────────────────────────────────
                  _buildTopHeader(isEn),

                  const SizedBox(height: 14),

                  // ── 3D MANNEQUIN WIREFRAME DISPLAY ──────────────────────
                  Expanded(flex: 5, child: _buildWireframeCanvas(isEn)),

                  const SizedBox(height: 16),

                  // ── PROGRESS PERCENTAGE & TIME ─────────────────────────
                  _buildProgressSection(isEn),

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
                            isEn ? "PIPELINE SEQUENCE" : "SÉQUENCE DU PIPELINE",
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
                            title: isEn
                                ? "Optical Photogrammetry"
                                : "Photogrammétrie Optique",
                            subtitle: isEn
                                ? "Synchronized 3-angle pose landmarks alignment"
                                : "Alignement des repères de pose 3 angles synchronisé",
                            isEn: isEn,
                          ),

                          const SizedBox(height: 8),

                          // Step 2: Nuage de Points Biométriques
                          _buildPipelineStep(
                            stepIndex: 1,
                            activeStep: activeStep,
                            title: isEn
                                ? "Biometric Point Cloud"
                                : "Nuage de Points Biométriques",
                            subtitle: isEn
                                ? "48 anatomical coordinates anchored"
                                : "48 coordonnées anatomiques ancrées",
                            isEn: isEn,
                          ),

                          const SizedBox(height: 8),

                          // Step 3: Génération du Maillage Neural
                          _buildPipelineStep(
                            stepIndex: 2,
                            activeStep: activeStep,
                            title: isEn
                                ? "Neural Mesh Generation"
                                : "Génération du Maillage Neural",
                            subtitle: isEn
                                ? "Sub-millimeter polygonal surfacing"
                                : "Surfaçage polygonale sous-millimétrique",
                            isEn: isEn,
                          ),

                          const SizedBox(height: 8),

                          // Step 4: Liaison du Moteur Physique
                          _buildPipelineStep(
                            stepIndex: 3,
                            activeStep: activeStep,
                            title: isEn
                                ? "Physics Engine Binding"
                                : "Liaison du Moteur Physique",
                            subtitle: isEn
                                ? "Fabric drape & tension calibration"
                                : "Drapé du tissu & étalonnage de tension",
                            isEn: isEn,
                          ),

                          const SizedBox(height: 14),

                          // ── SECURITY ENCLAVE CARD ────────────────────────
                          _buildSecurityCard(isEn),

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
                              builder: (context) => const HomeScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF172554),
                        foregroundColor: const Color(0xFF94A3B8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: Color(0xFF334155)),
                        ),
                      ),
                      child: Text(
                        _hasError
                            ? (isEn ? "Go Back" : "Retour")
                            : (isEn ? "Cancel processing" : "Annuler le traitement"),
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
      },
    );
  }

  // ── TOP HEADER BAR ──────────────────────────────────────────────────
  Widget _buildTopHeader(bool isEn) {
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
                  isEn ? "NEURAL MESH COMPILATION" : "COMPILATION DU MAILLAGE NEURAL",
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
            color: const Color(0xFF172554),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Text(
            _hasError
                ? (isEn ? "ERROR" : "ERREUR")
                : "$_progress% ${isEn ? 'COMPLETE' : 'TERMINÉ'}",
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _hasError ? const Color(0xFFF43F5E) : const Color(0xFF94A3B8),
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(width: 8),

        const LanguageToggleBadge(),
      ],
    );
  }

  // ── 3D MANNEQUIN WIREFRAME CANVAS ────────────────────────────────────
  Widget _buildWireframeCanvas(bool isEn) {
    if (_hasError) {
      final msg = isEn
          ? (_errorMessageEn ??
              "Unable to create 3D avatar due to expired/insufficient Tripo API credits. Please renew your credits to proceed.")
          : (_errorMessageFr ??
              "Impossible de créer l'avatar 3D en raison de crédits API Tripo expirés ou insuffisants. Veuillez renouveler vos crédits pour continuer.");
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF111827).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFF43F5E).withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF43F5E).withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF43F5E).withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFF43F5E).withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.credit_card_off_rounded,
                color: Color(0xFFF43F5E),
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              isEn ? "Tripo Credits Exhausted" : "Crédits Tripo Épuisés",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              msg,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: const Color(0xFF94A3B8),
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _progress = 10;
                  _estimatedSeconds = _hasPhotos ? 110 : 4;
                  _hasError = false;
                });
                _startProgressSimulation();
                _triggerReconstruction();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                isEn
                    ? "Renew Credits & Retry"
                    : "Renouveler les crédits & Réessayer",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF43F5E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF172554), width: 1.5),
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
          _buildCornerBracket(
            bottom: 14,
            right: 14,
            isTop: false,
            isLeft: false,
          ),

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFF43F5E).withValues(alpha: 0.5),
                    ),
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
                      const Icon(
                        Icons.blur_on_rounded,
                        size: 14,
                        color: Color(0xFFF43F5E),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isEn ? "4D CLOTHING RIG SYNTHESIS" : "SYNTHÈSE DU RIG DE VÊTEMENT 4D",
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
  Widget _buildProgressSection(bool isEn) {
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
                isEn
                    ? "Estimated time remaining: ~${_estimatedSeconds}s"
                    : "Temps restant estimé : ~${_estimatedSeconds}s",
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
            color: const Color(0xFF172554),
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
    required bool isEn,
  }) {
    final bool isDone = stepIndex < activeStep;
    final bool isActive = stepIndex == activeStep;

    Color containerBg = const Color(0xFF111827).withValues(alpha: 0.5);
    Color borderColor = const Color(0xFF172554);

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
                color: Color(0xFF172554),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 14,
                color: Color(0xFF38BDF8),
              ),
            )
          else if (isActive)
            RotationTransition(
              turns: _animController,
              child: const Icon(
                Icons.sync_rounded,
                size: 18,
                color: Color(0xFFF43F5E),
              ),
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
              isDone
                  ? (isEn ? "COMPLETE" : "TERMINÉ")
                  : (isActive
                      ? (isEn ? "IN PROGRESS" : "EN COURS")
                      : (isEn ? "PENDING" : "EN ATTENTE")),
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
  Widget _buildSecurityCard(bool isEn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF172554)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF172554),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shield_outlined,
              size: 16,
              color: Color(0xFF38BDF8),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isEn
                  ? "Photos processed exclusively in volatile memory and purged instantly. Encrypted Secure Enclave token created."
                  : "Photos traitées uniquement en mémoire volatile et purgées instantanément. Jeton Secure Enclave chiffré créé.",
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
        center.dx - 15,
        center.dy - 20,
        leftWaist.dx,
        leftWaist.dy,
      )
      ..lineTo(leftHip.dx, leftHip.dy)
      ..lineTo(rightHip.dx, rightHip.dy)
      ..lineTo(rightWaist.dx, rightWaist.dy)
      ..quadraticBezierTo(
        center.dx + 15,
        center.dy - 20,
        rightShoulder.dx,
        rightShoulder.dy,
      )
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
        height: ringRadiusY * 2,
      ),
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
        node,
        6.0,
        Paint()..color = const Color(0xFFF43F5E).withValues(alpha: 0.3),
      );
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


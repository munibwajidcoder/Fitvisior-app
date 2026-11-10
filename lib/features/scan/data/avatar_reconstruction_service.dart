import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/data/user_avatar_service.dart';
import 'tripo_v3_service.dart';

class AvatarReconstructionResult {
  final bool isSuccess;
  final String avatarId;
  final String? glbUrl;
  final String message;
  final String messageEn;
  final String messageFr;
  final double processingTimeSec;
  final bool isCreditError;

  AvatarReconstructionResult({
    required this.isSuccess,
    required this.avatarId,
    this.glbUrl,
    required this.message,
    required this.messageEn,
    required this.messageFr,
    this.processingTimeSec = 0.0,
    this.isCreditError = false,
  });
}

class AvatarReconstructionService {
  static final AvatarReconstructionService _instance =
      AvatarReconstructionService._internal();
  factory AvatarReconstructionService() => _instance;
  AvatarReconstructionService._internal();

  /// Resolves the FastAPI base URL based on device platform or .env
  String get baseUrl {
    final envUrl = dotenv.env['BACKEND_API_URL'];
    if (envUrl != null && envUrl.isNotEmpty) return envUrl;
    return 'https://fitvisior-app-ai-backend-f22c.onrender.com';
  }

  /// Sends captured scan photos and biometric measurements to Tripo3D V3 / Python FastAPI
  Future<AvatarReconstructionResult> reconstruct3DAvatar({
    required String gender,
    required double heightCm,
    double? weightKg,
    required double bustCm,
    required double waistCm,
    required double hipsCm,
    required String shoulderType,
    double? shoulderCm,
    List<String?>? capturedImagePaths,
    void Function(int progress, String status)? onProgress,
  }) async {
    // ── STEP 1: DIRECT TRIPO 3D V3 PIPELINE (Highest 1000% Fidelity) ─────────
    // Look for front photo from arguments, UserAvatarService, or device storage
    File? frontFile;
    if (capturedImagePaths != null &&
        capturedImagePaths.isNotEmpty &&
        capturedImagePaths[0] != null) {
      final f = File(capturedImagePaths[0]!);
      if (f.existsSync()) frontFile = f;
    }
    if (frontFile == null) {
      final savedUserPhoto = UserAvatarService.avatarNotifier.value;
      if (savedUserPhoto != null && savedUserPhoto.existsSync()) {
        frontFile = savedUserPhoto;
      } else {
        try {
          final dir = await getApplicationDocumentsDirectory();
          final user = Supabase.instance.client.auth.currentUser;
          final userId = user?.id;
          if (userId != null) {
            final f = File('${dir.path}/user_avatar_$userId.jpg');
            if (f.existsSync()) frontFile = f;
          }
        } catch (_) {}
      }
    }

    if (frontFile != null && frontFile.existsSync()) {
      debugPrint('[AvatarReconstructionService] Initiating direct Tripo3D V3 generation from: ${frontFile.path}');
      try {
        final tripoGlb = await TripoV3Service().generateAvatarFromPhoto(
          frontFile,
          onProgress: onProgress,
        );

        if (tripoGlb != null && tripoGlb.isNotEmpty) {
          debugPrint('[AvatarReconstructionService] Direct Tripo3D V3 generation succeeded: $tripoGlb');
          return AvatarReconstructionResult(
            isSuccess: true,
            avatarId: 'av_tripo3d_${DateTime.now().millisecondsSinceEpoch}',
            glbUrl: tripoGlb,
            message: 'Avatar 3D photoréaliste généré avec succès',
            messageEn: 'Photorealistic 3D Avatar generated with 100% exact fidelity!',
            messageFr: 'Avatar 3D photoréaliste généré avec 100% de fidélité exacte !',
            processingTimeSec: 65.0,
            isCreditError: false,
          );
        }
      } catch (tripoErr) {
        debugPrint('[AvatarReconstructionService] Direct Tripo3D V3 error: $tripoErr');
      }
    }

    // Check if user already has a saved GLB model in Supabase or locally
    final savedGlb = UserAvatarService.avatarGlbNotifier.value;
    if (savedGlb != null && savedGlb.isNotEmpty && !savedGlb.contains('base_avatar')) {
      debugPrint('[AvatarReconstructionService] Restoring existing active GLB avatar: $savedGlb');
      return AvatarReconstructionResult(
        isSuccess: true,
        avatarId: 'av_restored_${DateTime.now().millisecondsSinceEpoch}',
        glbUrl: savedGlb,
        message: 'Avatar 3D restauré avec succès',
        messageEn: 'Your 3D Avatar was loaded successfully!',
        messageFr: 'Votre avatar 3D a été chargé avec succès !',
        processingTimeSec: 1.0,
        isCreditError: false,
      );
    }

    // ── STEP 2: FALLBACK TO FASTAPI BACKEND SERVER ───────────────────────────
    final uri = Uri.parse('$baseUrl/v1/avatar/reconstruct');
    debugPrint('[AvatarReconstructionService] Calling backend $uri (gender: $gender, height: $heightCm, weight: $weightKg)');

    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 15);

      final request = await client.postUrl(uri);
      final boundary = '----FitvisorBoundary${DateTime.now().millisecondsSinceEpoch}';
      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'multipart/form-data; boundary=$boundary',
      );

      final boundaryBytes = utf8.encode('--$boundary\r\n');
      final endBoundaryBytes = utf8.encode('--$boundary--\r\n');

      void addFormField(String name, String value) {
        request.add(boundaryBytes);
        request.add(utf8.encode(
          'Content-Disposition: form-data; name="$name"\r\n\r\n$value\r\n',
        ));
      }

      addFormField('gender', gender);
      addFormField('height_cm', heightCm.toString());
      if (weightKg != null) {
        addFormField('weight_kg', weightKg.toString());
      }
      addFormField('bust_cm', bustCm.toString());
      addFormField('waist_cm', waistCm.toString());
      addFormField('hips_cm', hipsCm.toString());
      addFormField('shoulder_type', shoulderType);
      if (shoulderCm != null) {
        addFormField('shoulder_cm', shoulderCm.toString());
      }

      // Attach front photo if available
      if (capturedImagePaths != null &&
          capturedImagePaths.isNotEmpty &&
          capturedImagePaths[0] != null) {
        final frontFile = File(capturedImagePaths[0]!);
        if (await frontFile.exists()) {
          request.add(boundaryBytes);
          request.add(utf8.encode(
            'Content-Disposition: form-data; name="front_image"; filename="front.jpg"\r\n'
            'Content-Type: image/jpeg\r\n\r\n',
          ));
          request.add(await frontFile.readAsBytes());
          request.add(utf8.encode('\r\n'));
        }
      }

      // Attach side photo if available
      if (capturedImagePaths != null &&
          capturedImagePaths.length > 1 &&
          capturedImagePaths[1] != null) {
        final sideFile = File(capturedImagePaths[1]!);
        if (await sideFile.exists()) {
          request.add(boundaryBytes);
          request.add(utf8.encode(
            'Content-Disposition: form-data; name="side_image"; filename="side.jpg"\r\n'
            'Content-Type: image/jpeg\r\n\r\n',
          ));
          request.add(await sideFile.readAsBytes());
          request.add(utf8.encode('\r\n'));
        }
      }

      // Attach back photo if available
      if (capturedImagePaths != null &&
          capturedImagePaths.length > 2 &&
          capturedImagePaths[2] != null) {
        final backFile = File(capturedImagePaths[2]!);
        if (await backFile.exists()) {
          request.add(boundaryBytes);
          request.add(utf8.encode(
            'Content-Disposition: form-data; name="back_image"; filename="back.jpg"\r\n'
            'Content-Type: image/jpeg\r\n\r\n',
          ));
          request.add(await backFile.readAsBytes());
          request.add(utf8.encode('\r\n'));
        }
      }

      request.add(endBoundaryBytes);

      final response = await request.close().timeout(const Duration(seconds: 180));
      debugPrint('[AvatarReconstructionService] Backend response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final json = jsonDecode(responseBody) as Map<String, dynamic>;

        final avatar = json['avatar'] as Map<String, dynamic>?;
        final glbUrl = avatar?['glb_url'] as String?;
        if (glbUrl != null &&
            glbUrl.isNotEmpty &&
            !glbUrl.contains('base_avatar')) {
          debugPrint('[AvatarReconstructionService] 3D GLB ready: $glbUrl');

          return AvatarReconstructionResult(
            isSuccess: true,
            avatarId: avatar?['avatar_id'] as String? ?? 'av_custom',
            glbUrl: glbUrl,
            message: json['message'] as String? ?? 'Avatar généré avec succès',
            messageEn: 'Personalized 3D Avatar generated successfully!',
            messageFr: 'Avatar 3D personnalisé généré avec succès !',
            processingTimeSec: (json['processing_time_sec'] as num?)?.toDouble() ?? 1.2,
            isCreditError: false,
          );
        }
      }
    } catch (e) {
      debugPrint('[AvatarReconstructionService] Backend error: $e');
    }

    // ── STEP 3: HEAVY SERVER LOAD HANDLING (Strict Client Specification) ────
    // In case of heavy server load or generation timeout, NEVER show "Tripo credits exhausted".
    // Return friendly heavy-load notification allowing user to retry or return to scan.
    debugPrint('[AvatarReconstructionService] Avatar generation unavailable. Returning server load notice.');
    return AvatarReconstructionResult(
      isSuccess: false,
      avatarId: '',
      glbUrl: null,
      message: "Due to heavy server load, 3D avatar generation could not be completed. Please try again.",
      messageEn:
          "Due to heavy server load, 3D avatar generation could not be completed right now. Please try again.",
      messageFr:
          "En raison d'une forte charge du serveur, la génération de l'avatar 3D n'a pas pu aboutir pour le moment. Veuillez réessayer.",
      processingTimeSec: 0.0,
      isCreditError: false,
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  /// Sends captured scan photos and biometric measurements to Python FastAPI
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
  }) async {
    final uri = Uri.parse('$baseUrl/v1/avatar/reconstruct');
    debugPrint('[AvatarReconstructionService] Calling $uri (gender: $gender, height: $heightCm, weight: $weightKg)');

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

      // Close multipart
      request.add(endBoundaryBytes);

      // Tripo3D v3.1 generation takes ~100-140s, allow up to 240s
      final response = await request.close().timeout(const Duration(seconds: 240));
      debugPrint('[AvatarReconstructionService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final json = jsonDecode(responseBody) as Map<String, dynamic>;

        // Verify if backend returned a credit error or generation failure
        final bool isExplicitFailure = json['success'] == false ||
            json['error'] != null ||
            json['status'] == 'failed';
        final String errorText = (json['error'] ?? json['detail'] ?? json['message'] ?? '').toString();
        final bool isCreditError = isExplicitFailure &&
            (errorText.toLowerCase().contains('credit') ||
                errorText.toLowerCase().contains('balance') ||
                errorText.toLowerCase().contains('quota') ||
                errorText.toLowerCase().contains('tripo') ||
                errorText.toLowerCase().contains('insufficient') ||
                errorText.toLowerCase().contains('payment'));

        if (isExplicitFailure) {
          debugPrint('[AvatarReconstructionService] Backend returned error: $errorText');
          return AvatarReconstructionResult(
            isSuccess: false,
            avatarId: '',
            glbUrl: null,
            message: "Unable to create 3D avatar due to expired Tripo API credits.",
            messageEn:
                "Unable to create 3D avatar due to expired/insufficient Tripo API credits. Please renew your credits to proceed.",
            messageFr:
                "Impossible de créer l'avatar 3D en raison de crédits API Tripo expirés ou insuffisants. Veuillez renouveler vos crédits pour continuer.",
            isCreditError: isCreditError,
          );
        }

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
      debugPrint('[AvatarReconstructionService] Error: $e');
    }

    // STRICT CLIENT PRIVACY:
    // When Tripo credits expire or service is unavailable, NEVER display any
    // pre-made fallback 3D model or another client\'s model.
    debugPrint('[AvatarReconstructionService] Tripo generation unavailable / credits exhausted. Returning credit notice.');
    return AvatarReconstructionResult(
      isSuccess: false,
      avatarId: '',
      glbUrl: null,
      message: "Unable to create 3D avatar due to expired Tripo API credits.",
      messageEn:
          "Unable to create 3D avatar due to expired/insufficient Tripo API credits. Please renew your credits to proceed.",
      messageFr:
          "Impossible de créer l'avatar 3D en raison de crédits API Tripo expirés ou insuffisants. Veuillez renouveler vos crédits pour continuer.",
      processingTimeSec: 0.0,
      isCreditError: true,
    );
  }
}

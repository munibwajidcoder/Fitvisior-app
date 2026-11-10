import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../auth/data/user_avatar_service.dart';

class TripoV3Service {
  static final TripoV3Service _instance = TripoV3Service._internal();
  factory TripoV3Service() => _instance;
  TripoV3Service._internal();

  static const String _baseUrl = 'https://openapi.tripo3d.ai/v3';
  static const String _defaultApiKey = 'tsk_HLuaaCSbq8NFGez4T2Urct220isyZ1R5YCCMAqtScGw';

  String get _apiKey {
    final key = dotenv.env['TRIPO_API_KEY'];
    if (key != null && key.isNotEmpty) return key;
    return _defaultApiKey;
  }

  /// Checks available credits on Tripo developer account
  Future<int> checkBalance() async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 12);
    try {
      final uri = Uri.parse('$_baseUrl/account/balance');
      final req = await client.getUrl(uri);
      req.headers.set('Authorization', 'Bearer $_apiKey');
      final res = await req.close().timeout(const Duration(seconds: 12));
      final body = await res.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      if (json['code'] == 0 && json['data'] != null) {
        final bal = (json['data']['balance'] as num?)?.toInt() ?? 0;
        debugPrint('[TripoV3] Balance check success: $bal credits available');
        return bal;
      }
    } catch (e) {
      debugPrint('[TripoV3] Balance check warning: $e');
    } finally {
      client.close();
    }
    return 0;
  }

  /// Uploads user image to Tripo V3 storage and returns a file_token
  Future<String?> uploadImage(List<int> imageBytes, {String filename = 'user_photo.jpg'}) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 25);
    try {
      final boundary = '----FitvisorBoundary${DateTime.now().millisecondsSinceEpoch}';
      final uri = Uri.parse('$_baseUrl/files');
      final req = await client.postUrl(uri);
      req.headers.set('Authorization', 'Bearer $_apiKey');
      req.headers.set(HttpHeaders.contentTypeHeader, 'multipart/form-data; boundary=$boundary');

      final header = utf8.encode(
        '--$boundary\r\n'
        'Content-Disposition: form-data; name="file"; filename="$filename"\r\n'
        'Content-Type: image/jpeg\r\n\r\n',
      );
      final footer = utf8.encode('\r\n--$boundary--\r\n');

      req.contentLength = header.length + imageBytes.length + footer.length;
      req.add(header);
      req.add(imageBytes);
      req.add(footer);

      final res = await req.close().timeout(const Duration(seconds: 30));
      final body = await res.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;

      if (json['code'] == 0 && json['data'] != null) {
        final token = (json['data']['file_token'] ?? json['data']['image_token']) as String?;
        debugPrint('[TripoV3] Image uploaded successfully -> file_token: $token');
        return token;
      } else {
        debugPrint('[TripoV3] Upload error response: $body');
        return null;
      }
    } catch (e) {
      debugPrint('[TripoV3] Image upload error: $e');
      return null;
    } finally {
      client.close();
    }
  }

  /// Creates image-to-model task using Flagship v3.1 model with maximum fidelity
  Future<String?> createImageToModelTask(String fileToken) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
    try {
      final uri = Uri.parse('$_baseUrl/generation/image-to-model');
      final req = await client.postUrl(uri);
      req.headers.set('Authorization', 'Bearer $_apiKey');
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');

      final payload = jsonEncode({
        'input': fileToken,
        'model': 'v3.1-20260211',
        'texture': true,
        'pbr': true,
        'face_limit': 45000,
        'texture_quality': 'detailed',
        'geometry_quality': 'detailed',
        'texture_alignment': 'original_image',
        'auto_size': true,
      });

      req.write(payload);
      final res = await req.close().timeout(const Duration(seconds: 20));
      final body = await res.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;

      if (json['code'] == 0 && json['data'] != null) {
        final taskId = json['data']['task_id'] as String?;
        debugPrint('[TripoV3] Task created successfully: $taskId');
        return taskId;
      } else {
        debugPrint('[TripoV3] Task creation failed: $body');
        return null;
      }
    } catch (e) {
      debugPrint('[TripoV3] Task creation error: $e');
      return null;
    } finally {
      client.close();
    }
  }

  /// Polls the task until completion (max 240 seconds)
  Future<String?> pollTask(
    String taskId, {
    void Function(int progress, String status)? onProgress,
  }) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    final uri = Uri.parse('$_baseUrl/tasks/$taskId');

    try {
      // 90 iterations x 3 seconds = 270 seconds max timeout
      for (int i = 1; i <= 90; i++) {
        await Future.delayed(const Duration(seconds: 3));

        try {
          final req = await client.getUrl(uri);
          req.headers.set('Authorization', 'Bearer $_apiKey');
          final res = await req.close().timeout(const Duration(seconds: 15));
          final body = await res.transform(utf8.decoder).join();
          final json = jsonDecode(body) as Map<String, dynamic>;

          final data = json['data'] as Map<String, dynamic>?;
          if (data == null) continue;

          final status = data['status'] as String? ?? '';
          final progress = (data['progress'] as num?)?.toInt() ?? 0;
          debugPrint('[TripoV3] Task $taskId poll $i/90: status=$status, progress=$progress%');
          onProgress?.call(progress, status);

          if (status == 'success') {
            final output = data['output'] as Map<String, dynamic>?;
            final glbUrl = output?['model_url'] as String? ??
                output?['pbr_model'] as String? ??
                output?['model'] as String?;

            if (glbUrl != null && glbUrl.isNotEmpty) {
              debugPrint('[TripoV3] 3D Model ready at: $glbUrl');
              return glbUrl;
            }
            return null;
          } else if (status == 'failed' || status == 'cancelled') {
            debugPrint('[TripoV3] Task terminated with status: $status ($body)');
            return null;
          }
        } catch (iterErr) {
          debugPrint('[TripoV3] Non-fatal poll error in cycle $i (will retry next cycle): $iterErr');
          continue;
        }
      }
      debugPrint('[TripoV3] Task polling timed out');
      return null;
    } catch (e) {
      debugPrint('[TripoV3] Polling error: $e');
      return null;
    } finally {
      client.close();
    }
  }

  /// Generates a photorealistic 3D avatar directly from a local user photo file
  Future<String?> generateAvatarFromPhoto(
    File photoFile, {
    void Function(int progress, String status)? onProgress,
  }) async {
    if (!await photoFile.exists()) {
      debugPrint('[TripoV3] Photo file does not exist: ${photoFile.path}');
      return null;
    }

    final bytes = await photoFile.readAsBytes();
    if (bytes.length < 1000) {
      debugPrint('[TripoV3] Photo file too small: ${bytes.length} bytes');
      return null;
    }

    onProgress?.call(10, 'uploading');
    final token = await uploadImage(bytes, filename: 'avatar_front.jpg');
    if (token == null) {
      debugPrint('[TripoV3] Could not get file token for photo');
      return null;
    }

    onProgress?.call(20, 'initiating');
    final taskId = await createImageToModelTask(token);
    if (taskId == null) {
      debugPrint('[TripoV3] Could not create image_to_model task');
      return null;
    }

    final rawGlb = await pollTask(taskId, onProgress: onProgress);
    if (rawGlb != null && rawGlb.isNotEmpty) {
      onProgress?.call(95, 'persisting');
      try {
        final supabaseUrl = await UserAvatarService.persistGlbToStorage(rawGlb);
        if (supabaseUrl != null && supabaseUrl.isNotEmpty) {
          debugPrint('[TripoV3] Persisted to Supabase Storage: $supabaseUrl');
          return supabaseUrl;
        }
      } catch (e) {
        debugPrint('[TripoV3] Storage persist warning: $e');
      }
      return rawGlb;
    }
    return null;
  }
}


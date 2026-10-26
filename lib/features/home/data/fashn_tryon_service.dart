import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FashnTryOnResult {
  final bool isSuccess;
  final String? tryOnImageUrl;
  final String? errorMessage;
  final double processingTimeSec;

  const FashnTryOnResult({
    required this.isSuccess,
    this.tryOnImageUrl,
    this.errorMessage,
    this.processingTimeSec = 0.0,
  });
}

class FashnTryOnService {
  static final FashnTryOnService instance = FashnTryOnService._internal();
  FashnTryOnService._internal();

  static const String _baseUrl = 'https://api.fashn.ai/v1';

  // Fallback API Key provided by client
  static const String _defaultApiKey = 'fa-KUhw81FXejcv-3y474LnbmiI3yxEAbSvRHT8I';

  String get _apiKey {
    final key = dotenv.env['FASHN_API_KEY'];
    if (key != null && key.isNotEmpty) return key;
    return _defaultApiKey;
  }

  // In-memory cache to avoid redundant API credit consumption
  final Map<String, String> _tryOnCache = {};

  /// Checks if a try-on image has already been generated for this product and avatar
  String? getCachedTryOn(String cacheKey) => _tryOnCache[cacheKey];

  /// Executes AI Virtual Try-On using FASHN.ai
  /// [garmentImagePath]: Product image URL (http/https) or local asset path
  /// [userAvatarFile]: Captured 2D front portrait of user (if available)
  /// [userAvatarUrl]: Optional network image of user portrait
  Future<FashnTryOnResult> executeTryOn({
    required String garmentImagePath,
    File? userAvatarFile,
    String? userAvatarUrl,
    String category = 'tops',
    String? cacheKey,
  }) async {
    final key = cacheKey ?? garmentImagePath;
    if (_tryOnCache.containsKey(key)) {
      debugPrint('[FashnTryOnService] Serving from cache: key=$key');
      return FashnTryOnResult(
        isSuccess: true,
        tryOnImageUrl: _tryOnCache[key],
        processingTimeSec: 0.1,
      );
    }

    final stopwatch = Stopwatch()..start();
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);

    try {
      // 1. Prepare garment image
      final garmentInput = await _resolveImageInput(garmentImagePath);

      // 2. Prepare model image
      String modelInput;
      if (userAvatarFile != null && await userAvatarFile.exists()) {
        final bytes = await userAvatarFile.readAsBytes();
        modelInput = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      } else if (userAvatarUrl != null && userAvatarUrl.startsWith('http')) {
        modelInput = userAvatarUrl;
      } else {
        // High quality reference fashion avatar for demo
        modelInput = 'https://raw.githubusercontent.com/fashn-ai/api-examples/main/assets/model.jpg';
      }

      debugPrint('[FashnTryOnService] Submitting try-on request to FASHN.ai API...');

      final runUri = Uri.parse('$_baseUrl/run');
      final payload = {
        'model_name': 'tryon-v1.6',
        'inputs': {
          'model_image': modelInput,
          'garment_image': garmentInput,
          'category': _normalizeCategory(category),
          'mode': 'balanced',
          'nsfw_filter': true,
        }
      };

      final runReq = await client.postUrl(runUri);
      runReq.headers.set('Authorization', 'Bearer $_apiKey');
      runReq.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      runReq.write(jsonEncode(payload));

      final runRes = await runReq.close().timeout(const Duration(seconds: 25));
      final runBody = await runRes.transform(utf8.decoder).join();

      debugPrint('[FashnTryOnService] Run response: ${runRes.statusCode} - $runBody');

      if (runRes.statusCode != 200) {
        try {
          final errJson = jsonDecode(runBody);
          final errMsg = errJson['message'] ?? errJson['error'] ?? 'API request failed';
          return FashnTryOnResult(isSuccess: false, errorMessage: errMsg.toString());
        } catch (_) {
          return FashnTryOnResult(isSuccess: false, errorMessage: 'HTTP ${runRes.statusCode}: $runBody');
        }
      }

      final runJson = jsonDecode(runBody) as Map<String, dynamic>;
      final predictionId = runJson['id'] as String?;

      if (predictionId == null || predictionId.isEmpty) {
        return const FashnTryOnResult(isSuccess: false, errorMessage: 'Missing prediction ID');
      }

      // 3. Poll for result (FASHN generates in ~4-12 seconds)
      final statusUri = Uri.parse('$_baseUrl/status/$predictionId');
      String? completedUrl;
      int attempts = 0;
      const maxAttempts = 20; // 20 * 1.5s = 30 seconds max

      while (attempts < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 1500));
        attempts++;

        try {
          final statusReq = await client.getUrl(statusUri);
          statusReq.headers.set('Authorization', 'Bearer $_apiKey');
          final statusRes = await statusReq.close().timeout(const Duration(seconds: 10));
          final statusBody = await statusRes.transform(utf8.decoder).join();

          if (statusRes.statusCode == 200) {
            final statusJson = jsonDecode(statusBody) as Map<String, dynamic>;
            final status = statusJson['status'] as String? ?? '';
            debugPrint('[FashnTryOnService] Poll attempt $attempts: status=$status');

            if (status == 'completed') {
              final output = statusJson['output'];
              if (output is List && output.isNotEmpty) {
                completedUrl = output[0]?.toString();
              } else if (output is String) {
                completedUrl = output;
              }
              break;
            } else if (status == 'failed') {
              final error = statusJson['error'];
              final msg = error is Map ? (error['message'] ?? 'Try-on processing failed') : 'Failed';
              return FashnTryOnResult(isSuccess: false, errorMessage: msg.toString());
            }
          }
        } catch (e) {
          debugPrint('[FashnTryOnService] Status polling error: $e');
        }
      }

      stopwatch.stop();

      if (completedUrl != null && completedUrl.isNotEmpty) {
        _tryOnCache[key] = completedUrl;
        debugPrint('[FashnTryOnService] Success! Result URL: $completedUrl in ${stopwatch.elapsedMilliseconds}ms');
        return FashnTryOnResult(
          isSuccess: true,
          tryOnImageUrl: completedUrl,
          processingTimeSec: stopwatch.elapsedMilliseconds / 1000.0,
        );
      }

      return const FashnTryOnResult(
        isSuccess: false,
        errorMessage: 'Generation timed out. Please try again.',
      );
    } catch (e) {
      stopwatch.stop();
      debugPrint('[FashnTryOnService] Exception during try-on: $e');
      return FashnTryOnResult(isSuccess: false, errorMessage: e.toString());
    } finally {
      client.close();
    }
  }

  /// Converts image to public URL or base64 data URI
  Future<String> _resolveImageInput(String imagePath) async {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    // Local asset
    try {
      final byteData = await rootBundle.load(imagePath);
      final bytes = byteData.buffer.asUint8List();
      final mime = imagePath.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
      return 'data:$mime;base64,${base64Encode(bytes)}';
    } catch (e) {
      debugPrint('[FashnTryOnService] Failed to load asset $imagePath: $e');
      return imagePath;
    }
  }

  String _normalizeCategory(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('pant') || c.contains('trouser') || c.contains('jean') || c.contains('skirt')) {
      return 'bottoms';
    }
    if (c.contains('dress') || c.contains('robe') || c.contains('combinaison') || c.contains('jumpsuit')) {
      return 'one-pieces';
    }
    return 'tops';
  }
}

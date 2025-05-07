import 'dart:io';

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

class TranscriptionService {
  final Dio _dio = Dio();

  Future<String?> transcribeAudio(String audioPath) async {
    try {
      final file = File(audioPath);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: 'audio.m4a'),
        'model': 'whisper-1',
      });

      final response = await _dio.post(
        ApiConstants.whisperApiEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConstants.whisperApiKey}',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['text'];
      }
      return null;
    } catch (e) {
      print('Error transcribing audio: $e');
      return null;
    }
  }
}

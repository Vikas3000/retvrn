import 'dart:convert';

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

class AnalysisService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>?> analyzeText(String text) async {
    try {
      final response = await _dio.post(
        ApiConstants.gptApiEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConstants.openAiApiKey}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content':
                  'Analyze the following text for emotional tone, key growth themes, and probable Spiral Dynamics stage. Return the analysis in JSON format.',
            },
            {
              'role': 'user',
              'content': text,
            },
          ],
          'temperature': 0.7,
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'];
        return _parseAnalysis(content);
      }
      return null;
    } catch (e) {
      print('Error analyzing text: $e');
      return null;
    }
  }

  Map<String, dynamic>? _parseAnalysis(String content) {
    try {
      // Remove any markdown formatting if present
      final cleanContent =
          content.replaceAll('```json', '').replaceAll('```', '');
      return Map<String, dynamic>.from(jsonDecode(cleanContent));
    } catch (e) {
      print('Error parsing analysis: $e');
      return null;
    }
  }
}

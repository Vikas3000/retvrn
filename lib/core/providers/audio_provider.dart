import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../models/voice_entry.dart';
import '../services/analysis_service.dart';
import '../services/audio_service.dart';
import '../services/transcription_service.dart';

class AudioProvider with ChangeNotifier {
  final AudioService _audioService = AudioService();
  final TranscriptionService _transcriptionService = TranscriptionService();
  final AnalysisService _analysisService = AnalysisService();

  bool _isRecording = false;
  String? _currentAudioPath;
  List<VoiceEntry> _voiceEntries = [];
  bool _isProcessing = false;

  bool get isRecording => _isRecording;
  bool get isProcessing => _isProcessing;
  List<VoiceEntry> get voiceEntries => _voiceEntries;

  Future<void> loadVoiceEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getStringList(AppConstants.voiceEntriesKey) ?? [];
    _voiceEntries = entriesJson
        .map((json) => VoiceEntry.fromJson(jsonDecode(json)))
        .toList();
    notifyListeners();
  }

  Future<void> startRecording() async {
    if (!_isRecording) {
      final success = await _audioService.startRecording();
      if (success) {
        _isRecording = true;
        notifyListeners();
      }
    }
  }

  Future<void> stopRecording() async {
    if (_isRecording) {
      _isProcessing = true;
      notifyListeners();

      _currentAudioPath = await _audioService.stopRecording();
      _isRecording = false;

      if (_currentAudioPath != null) {
        // Transcribe audio
        final transcription =
            await _transcriptionService.transcribeAudio(_currentAudioPath!);

        if (transcription != null) {
          // Analyze transcription
          final analysis = await _analysisService.analyzeText(transcription);

          // Create and save voice entry
          final voiceEntry = VoiceEntry(
            audioPath: _currentAudioPath!,
            transcription: transcription,
            analysis: analysis,
          );

          _voiceEntries.add(voiceEntry);
          await _saveVoiceEntries();
        }
      }

      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> deleteVoiceEntry(String id) async {
    final entry = _voiceEntries.firstWhere((e) => e.id == id);
    await _audioService.deleteRecording(entry.audioPath);
    _voiceEntries.removeWhere((e) => e.id == id);
    await _saveVoiceEntries();
    notifyListeners();
  }

  Future<void> _saveVoiceEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson =
        _voiceEntries.map((entry) => jsonEncode(entry.toJson())).toList();
    await prefs.setStringList(AppConstants.voiceEntriesKey, entriesJson);
  }
}

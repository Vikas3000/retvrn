import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../models/reflection_entry.dart';
import '../services/analysis_service.dart';

class ReflectionProvider with ChangeNotifier {
  final AnalysisService _analysisService = AnalysisService();
  List<ReflectionEntry> _reflectionEntries = [];
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;
  List<ReflectionEntry> get reflectionEntries => _reflectionEntries;

  Future<void> loadReflectionEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson =
        prefs.getStringList(AppConstants.reflectionEntriesKey) ?? [];
    _reflectionEntries = entriesJson
        .map((json) => ReflectionEntry.fromJson(jsonDecode(json)))
        .toList();
    notifyListeners();
  }

  Future<void> addReflectionEntry(String prompt, String response,
      {String? voiceEntryId}) async {
    _isProcessing = true;
    notifyListeners();

    final entry = ReflectionEntry(
      prompt: prompt,
      response: response,
      voiceEntryId: voiceEntryId,
    );

    _reflectionEntries.add(entry);
    await _saveReflectionEntries();

    _isProcessing = false;
    notifyListeners();
  }

  Future<String> generateReflectionPrompt(String transcription) async {
    final analysis = await _analysisService.analyzeText(transcription);
    // Generate a reflection prompt based on the analysis
    // This is a simplified version - you might want to make this more sophisticated
    return "Based on your thoughts, how do you feel about ${analysis?['themes']?[0] ?? 'this topic'}?";
  }

  Future<void> deleteReflectionEntry(String id) async {
    _reflectionEntries.removeWhere((e) => e.id == id);
    await _saveReflectionEntries();
    notifyListeners();
  }

  Future<void> _saveReflectionEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson =
        _reflectionEntries.map((entry) => jsonEncode(entry.toJson())).toList();
    await prefs.setStringList(AppConstants.reflectionEntriesKey, entriesJson);
  }
}

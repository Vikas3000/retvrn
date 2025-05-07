import 'dart:async';
import 'dart:io';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class AudioService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderInitialized = false;
  String? _currentRecordingPath;

  // Initialize the recorder
  Future<void> initialize() async {
    await _recorder.openRecorder();
    _isRecorderInitialized = true;
  }

  // Start recording
  Future<bool> startRecording() async {
    if (!_isRecorderInitialized) {
      await initialize();
    }

    try {
      // Request microphone permission
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        print('Microphone permission not granted');
        return false;
      }

      // Get the recording path
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${const Uuid().v4()}.aac';
      _currentRecordingPath = '${directory.path}/$fileName';

      // Start recording
      await _recorder.startRecorder(
        toFile: _currentRecordingPath,
        codec: Codec.aacADTS,
      );

      return true;
    } catch (e) {
      print('Error starting recording: $e');
      return false;
    }
  }

  // Stop recording
  Future<String?> stopRecording() async {
    try {
      if (_recorder.isRecording) {
        await _recorder.stopRecorder();
        return _currentRecordingPath;
      }
      return null;
    } catch (e) {
      print('Error stopping recording: $e');
      return null;
    }
  }

  // Delete recording
  Future<bool> deleteRecording(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting recording: $e');
      return false;
    }
  }

  // Dispose resources
  Future<void> dispose() async {
    if (_isRecorderInitialized) {
      await _recorder.closeRecorder();
      _isRecorderInitialized = false;
    }
  }
}

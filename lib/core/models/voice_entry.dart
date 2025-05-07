import 'package:uuid/uuid.dart';

class VoiceEntry {
  final String id;
  final String audioPath;
  final String? transcription;
  final DateTime createdAt;
  final Map<String, dynamic>? analysis;

  VoiceEntry({
    String? id,
    required this.audioPath,
    this.transcription,
    DateTime? createdAt,
    this.analysis,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'audioPath': audioPath,
      'transcription': transcription,
      'createdAt': createdAt.toIso8601String(),
      'analysis': analysis,
    };
  }

  factory VoiceEntry.fromJson(Map<String, dynamic> json) {
    return VoiceEntry(
      id: json['id'],
      audioPath: json['audioPath'],
      transcription: json['transcription'],
      createdAt: DateTime.parse(json['createdAt']),
      analysis: json['analysis'],
    );
  }
}

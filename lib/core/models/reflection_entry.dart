import 'package:uuid/uuid.dart';

class ReflectionEntry {
  final String id;
  final String prompt;
  final String response;
  final DateTime createdAt;
  final String? voiceEntryId;

  ReflectionEntry({
    String? id,
    required this.prompt,
    required this.response,
    DateTime? createdAt,
    this.voiceEntryId,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prompt': prompt,
      'response': response,
      'createdAt': createdAt.toIso8601String(),
      'voiceEntryId': voiceEntryId,
    };
  }

  factory ReflectionEntry.fromJson(Map<String, dynamic> json) {
    return ReflectionEntry(
      id: json['id'],
      prompt: json['prompt'],
      response: json['response'],
      createdAt: DateTime.parse(json['createdAt']),
      voiceEntryId: json['voiceEntryId'],
    );
  }
}

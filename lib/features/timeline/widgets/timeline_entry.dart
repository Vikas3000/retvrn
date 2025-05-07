import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/models/reflection_entry.dart';
import '../../../core/models/voice_entry.dart';

class TimelineItem {
  final DateTime date;
  final String type;
  final dynamic data;

  TimelineItem({
    required this.date,
    required this.type,
    required this.data,
  });
}

class TimelineEntryWidget extends StatelessWidget {
  final TimelineItem entry;
  final bool isLast;

  const TimelineEntryWidget({
    Key? key,
    required this.entry,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeline(context),
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(left: 16, bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 8),
                    _buildContent(context),
                  ],
                ),
              ),
            ).animate().fadeIn().slideX(begin: 0.2, end: 0),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: entry.type == 'voice' ? Colors.blue : Colors.green,
          ),
        ),
        if (!isLast)
          Expanded(
            child: Container(
              width: 2,
              color: Colors.grey[300],
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          entry.type == 'voice' ? Icons.mic : Icons.edit,
          size: 16,
          color: entry.type == 'voice' ? Colors.blue : Colors.green,
        ),
        const SizedBox(width: 8),
        Text(
          entry.type == 'voice' ? 'Voice Recording' : 'Reflection',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Spacer(),
        Text(
          _formatDate(entry.date),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (entry.type == 'voice') {
      final voiceEntry = entry.data as VoiceEntry;
      return Text(voiceEntry.transcription ?? 'No transcription available');
    } else {
      final reflectionEntry = entry.data as ReflectionEntry;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reflectionEntry.prompt,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: 8),
          Text(reflectionEntry.response),
        ],
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

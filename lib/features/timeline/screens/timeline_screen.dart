import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retvrn/main.dart';

import '../../../core/providers/audio_provider.dart';
import '../../../core/providers/reflection_provider.dart';
import '../widgets/timeline_entry.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
        centerTitle: true,
      ),
      body: Consumer2<AudioProvider, ReflectionProvider>(
        builder: (context, audioProvider, reflectionProvider, child) {
          final allEntries = [
            ...audioProvider.voiceEntries.map(
                (e) => TimelineItem(date: e.createdAt, type: 'voice', data: e)),
            ...reflectionProvider.reflectionEntries.map((e) =>
                TimelineItem(date: e.createdAt, type: 'reflection', data: e)),
          ]..sort((a, b) => b.date.compareTo(a.date));

          return ListView.builder(
            padding: context.defaultPadding,
            itemCount: allEntries.length,
            itemBuilder: (context, index) {
              return TimelineEntryWidget(
                entry: allEntries[index],
                isLast: index == allEntries.length - 1,
              );
            },
          );
        },
      ),
    );
  }
}

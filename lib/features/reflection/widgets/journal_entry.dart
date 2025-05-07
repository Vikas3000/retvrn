import 'package:flutter/material.dart';

import '../../../core/models/reflection_entry.dart';

class JournalEntry extends StatelessWidget {
  final ReflectionEntry entry;

  const JournalEntry({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.prompt,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(entry.response),
            const SizedBox(height: 4),
            Text(
              entry.createdAt.toString().split('.')[0],
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

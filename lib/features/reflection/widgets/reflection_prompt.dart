import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/voice_entry.dart';
import '../../../core/providers/reflection_provider.dart';
import '../../../shared/widgets/custom_button.dart';

class ReflectionPrompt extends StatefulWidget {
  final VoiceEntry voiceEntry;

  const ReflectionPrompt({
    Key? key,
    required this.voiceEntry,
  }) : super(key: key);

  @override
  State<ReflectionPrompt> createState() => _ReflectionPromptState();
}

class _ReflectionPromptState extends State<ReflectionPrompt> {
  final TextEditingController _controller = TextEditingController();
  String? _prompt;

  @override
  void initState() {
    super.initState();
    _generatePrompt();
  }

  Future<void> _generatePrompt() async {
    if (widget.voiceEntry.transcription != null) {
      final provider = context.read<ReflectionProvider>();
      final prompt = await provider.generateReflectionPrompt(
        widget.voiceEntry.transcription!,
      );
      setState(() => _prompt = prompt);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_prompt != null) ...[
          Text(
            'Reflection Prompt:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(_prompt!),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Write your reflection here...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          CustomButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                context.read<ReflectionProvider>().addReflectionEntry(
                      _prompt!,
                      _controller.text,
                      voiceEntryId: widget.voiceEntry.id,
                    );
                _controller.clear();
              }
            },
            text: 'Save Reflection',
            icon: Icons.save,
          ),
        ],
      ],
    );
  }
}

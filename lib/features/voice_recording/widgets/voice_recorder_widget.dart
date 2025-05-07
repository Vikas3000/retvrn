import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../shared/widgets/custom_button.dart';

class VoiceRecorderWidget extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;

  const VoiceRecorderWidget({
    Key? key,
    required this.isRecording,
    required this.onStartRecording,
    required this.onStopRecording,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onPressed: isRecording ? onStopRecording : onStartRecording,
      text: isRecording ? 'Stop Recording' : 'Start Recording',
      backgroundColor: isRecording ? Colors.red : Colors.blue,
      icon: isRecording ? Icons.stop : Icons.mic,
    )
        .animate()
        .scale(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        )
        .fadeIn();
  }
}

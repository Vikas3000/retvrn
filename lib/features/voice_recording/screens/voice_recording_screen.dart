import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/audio_provider.dart';

class RecordingScreen extends StatefulWidget {
  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Load existing voice entries
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AudioProvider>().loadVoiceEntries();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Voice Journal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<AudioProvider>(
        builder: (context, audioProvider, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black,
                  Colors.purple.shade900,
                  Colors.black,
                ],
              ),
            ),
            child: Column(
              children: [
                // Processing Indicator
                if (audioProvider.isProcessing)
                  LinearProgressIndicator(
                    backgroundColor: Colors.purple.withOpacity(0.2),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                  ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Waveform Animation
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Container(
                            height: 200,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                30,
                                (index) => _buildWaveformBar(
                                  index,
                                  audioProvider.isRecording,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 50),

                      // Recording Button with Processing Overlay
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Main Recording Button
                          GestureDetector(
                            onTap: audioProvider.isProcessing
                                ? null
                                : () {
                                    if (audioProvider.isRecording) {
                                      audioProvider.stopRecording();
                                    } else {
                                      audioProvider.startRecording();
                                    }
                                  },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              height: audioProvider.isRecording ? 80 : 70,
                              width: audioProvider.isRecording ? 80 : 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: audioProvider.isProcessing
                                      ? [Colors.grey, Colors.grey.shade700]
                                      : audioProvider.isRecording
                                          ? [Colors.red, Colors.redAccent]
                                          : [Colors.blue, Colors.blueAccent],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: audioProvider.isRecording
                                        ? Colors.red.withOpacity(0.5)
                                        : Colors.blue.withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  audioProvider.isProcessing
                                      ? Icons.hourglass_empty
                                      : audioProvider.isRecording
                                          ? Icons.stop
                                          : Icons.mic,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),

                          // Processing Overlay
                          if (audioProvider.isProcessing)
                            CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Status Text
                      AnimatedDefaultTextStyle(
                        duration: Duration(milliseconds: 300),
                        style: TextStyle(
                          color: audioProvider.isProcessing
                              ? Colors.amber
                              : audioProvider.isRecording
                                  ? Colors.red
                                  : Colors.white,
                          fontSize: audioProvider.isProcessing ? 16 : 18,
                          fontWeight: FontWeight.w500,
                        ),
                        child: Text(
                          audioProvider.isProcessing
                              ? 'Processing...'
                              : audioProvider.isRecording
                                  ? 'Recording...'
                                  : 'Tap to Record',
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Voice Entries Count
                      Text(
                        '${audioProvider.voiceEntries.length} Entries',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWaveformBar(int index, bool isRecording) {
    final double animation = math.sin(
      (_animationController.value * 2 * math.pi + index / 2),
    );

    final double barHeight =
        isRecording ? (50.0).clamp(0.0, (animation * 100).abs()) : 5.0;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: 4,
      height: barHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isRecording ? Colors.red : Colors.blue,
            isRecording ? Colors.redAccent : Colors.blueAccent,
          ],
        ),
      ),
    );
  }
}

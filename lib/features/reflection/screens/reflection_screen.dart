import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/models/voice_entry.dart';
import '../../../core/providers/audio_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_indicator.dart';

class ReflectionScreen extends StatefulWidget {
  const ReflectionScreen({Key? key}) : super(key: key);

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  Future<void> _loadData() async {
    final audioProvider = context.read<AudioProvider>();
    await audioProvider.loadVoiceEntries();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset >= 400) {
      if (!_showScrollToTop) setState(() => _showScrollToTop = true);
    } else {
      if (_showScrollToTop) setState(() => _showScrollToTop = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Journal'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _showDatePicker(context),
          ),
        ],
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: _showScrollToTop ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: FloatingActionButton(
          mini: true,
          child: const Icon(Icons.arrow_upward),
          onPressed: () {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
        ),
      ),
      body: SafeArea(
        child: Consumer<AudioProvider>(
          builder: (context, audioProvider, child) {
            if (audioProvider.isProcessing) {
              return const LoadingIndicator(
                message: 'Processing your recording...',
              );
            }

            final voiceEntries = audioProvider.voiceEntries;

            if (voiceEntries.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                await audioProvider.loadVoiceEntries();
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final voiceEntry = voiceEntries[index];
                          return _buildVoiceEntryCard(
                            context,
                            voiceEntry,
                            index,
                          )
                              .animate()
                              .fadeIn(
                                  delay: Duration(milliseconds: index * 100))
                              .slideX();
                        },
                        childCount: voiceEntries.length,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.mic_none,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No Recordings Yet',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Start by recording your thoughts\nin the Recording tab',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            onPressed: () {
              DefaultTabController.of(context)?.animateTo(0);
            },
            text: 'Start Recording',
            icon: Icons.mic,
          ),
        ],
      ).animate().fadeIn().scale(),
    );
  }

  Widget _buildVoiceEntryCard(
    BuildContext context,
    VoiceEntry voiceEntry,
    int index,
  ) {
    final dateStr = _formatDateTime(
        DateTime.now()); // Replace with actual date from voiceEntry

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recording ${index + 1}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const Divider(),
            if (voiceEntry.transcription != null) ...[
              Text(
                'Transcription:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                voiceEntry.transcription!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
            ],
            if (voiceEntry.analysis != null) ...[
              Text(
                'Analysis:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildAnalysisChips(context, voiceEntry.analysis!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisChips(
      BuildContext context, Map<String, dynamic> analysis) {
    final emotions = analysis['emotions'] as List<dynamic>? ?? [];
    final themes = analysis['themes'] as List<dynamic>? ?? [];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...emotions.map((emotion) => Chip(
              label: Text(emotion.toString()),
              backgroundColor: Colors.blue[100],
              labelStyle: TextStyle(color: Colors.blue[900]),
            )),
        ...themes.map((theme) => Chip(
              label: Text(theme.toString()),
              backgroundColor: Colors.green[100],
              labelStyle: TextStyle(color: Colors.green[900]),
            )),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );

    if (picked != null && context.mounted) {
      // TODO: Implement date filtering
      print('Selected date: ${_formatDateTime(picked)}');
    }
  }
}

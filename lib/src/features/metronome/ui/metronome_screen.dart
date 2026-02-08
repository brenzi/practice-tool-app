import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/tempo_wheel_overlay.dart';
import '../providers/metronome_providers.dart';
import 'widgets/beat_pattern_editor.dart';
import 'widgets/metronome_controls.dart';

class MetronomeScreen extends ConsumerWidget {
  const MetronomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bpm = ref.watch(metronomeProvider.select((s) => s.bpm));
    final isPlaying = ref.watch(metronomeProvider.select((s) => s.isPlaying));
    final notifier = ref.read(metronomeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Metronome')),
      body: Column(
        children: [
          const Expanded(child: Center(child: BeatPatternEditor())),
          const Divider(height: 1),
          const MetronomeControls(),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => showTempoWheel(
                    context,
                    currentBpm: bpm,
                    onBpmChanged: notifier.setBpm,
                  ),
                  child: Text(
                    '\u2669 = $bpm',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => notifier.togglePlay(),
                  icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                  label: Text(isPlaying ? 'Stop' : 'Play'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

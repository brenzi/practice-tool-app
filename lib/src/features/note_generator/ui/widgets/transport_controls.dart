import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/note_generator_providers.dart';

class TransportControls extends ConsumerWidget {
  const TransportControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pianoEnabled = ref.watch(
      noteGeneratorProvider.select((s) => s.pianoEnabled),
    );
    final metronomeEnabled = ref.watch(
      noteGeneratorProvider.select((s) => s.metronomeEnabled),
    );
    final isPlaying = ref.watch(
      noteGeneratorProvider.select((s) => s.isPlaying),
    );

    return Column(
      children: [
        SwitchListTile(
          title: const Text('Piano'),
          value: pianoEnabled,
          onChanged: (_) {
            ref.read(noteGeneratorProvider.notifier).togglePiano();
          },
        ),
        SwitchListTile(
          title: const Text('Metronome'),
          value: metronomeEnabled,
          onChanged: (_) {
            ref.read(noteGeneratorProvider.notifier).toggleMetronome();
          },
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () {
            ref.read(noteGeneratorProvider.notifier).togglePlay();
          },
          icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
          label: Text(isPlaying ? 'Stop' : 'Play'),
          style: FilledButton.styleFrom(minimumSize: const Size(200, 56)),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

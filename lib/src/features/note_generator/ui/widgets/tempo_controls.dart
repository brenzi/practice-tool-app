import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/note_generator_providers.dart';

class TempoControls extends ConsumerWidget {
  const TempoControls({super.key});

  static const _beatsPerNoteOptions = [1, 2, 3, 4, 6, 8];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bpm = ref.watch(noteGeneratorProvider.select((s) => s.bpm));
    final beatsPerNote = ref.watch(
      noteGeneratorProvider.select((s) => s.beatsPerNote),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Tempo $bpm',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        Slider(
          value: bpm.toDouble(),
          min: 40,
          max: 200,
          divisions: 160,
          label: '$bpm',
          onChanged: (v) {
            ref.read(noteGeneratorProvider.notifier).setBpm(v.round());
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text('Beats', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 12),
              Expanded(
                child: SegmentedButton<int>(
                  segments: _beatsPerNoteOptions
                      .map((v) => ButtonSegment(value: v, label: Text('$v')))
                      .toList(),
                  selected: {beatsPerNote},
                  onSelectionChanged: (s) {
                    ref
                        .read(noteGeneratorProvider.notifier)
                        .setBeatsPerNote(s.first);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

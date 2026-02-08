import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/scale.dart';
import '../../providers/note_generator_providers.dart';

const _noteNames = [
  'C',
  'C#',
  'D',
  'D#',
  'E',
  'F',
  'F#',
  'G',
  'G#',
  'A',
  'A#',
  'B',
];

class NoteRules extends ConsumerWidget {
  const NoteRules({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxInterval = ref.watch(
      noteGeneratorProvider.select((s) => s.maxInterval),
    );
    final rootPitchClass = ref.watch(
      noteGeneratorProvider.select((s) => s.rootPitchClass),
    );
    final scaleType = ref.watch(
      noteGeneratorProvider.select((s) => s.scaleType),
    );
    final notifier = ref.read(noteGeneratorProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Note Rules',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SwitchListTile(
          title: const Text('Limit interval'),
          value: maxInterval != null,
          onChanged: (on) {
            notifier.setMaxInterval(on ? 12 : null);
          },
        ),
        if (maxInterval != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('$maxInterval semitones'),
                Expanded(
                  child: Slider(
                    value: maxInterval.toDouble(),
                    min: 1,
                    max: 24,
                    divisions: 23,
                    label: '$maxInterval',
                    onChanged: (v) => notifier.setMaxInterval(v.round()),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text('Root'),
              const SizedBox(width: 16),
              DropdownButton<int?>(
                value: rootPitchClass,
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  for (var i = 0; i < 12; i++)
                    DropdownMenuItem(value: i, child: Text(_noteNames[i])),
                ],
                onChanged: (root) {
                  notifier.setScale(
                    root,
                    root != null ? (scaleType ?? ScaleType.major) : null,
                  );
                },
              ),
              if (rootPitchClass != null) ...[
                const SizedBox(width: 24),
                const Text('Scale'),
                const SizedBox(width: 16),
                DropdownButton<ScaleType>(
                  value: scaleType ?? ScaleType.major,
                  items: ScaleType.values
                      .map(
                        (s) => DropdownMenuItem(value: s, child: Text(s.label)),
                      )
                      .toList(),
                  onChanged: (s) => notifier.setScale(rootPitchClass, s),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

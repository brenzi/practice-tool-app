import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/note_generator_providers.dart';

class NoteDisplay extends ConsumerWidget {
  const NoteDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteName = ref.watch(
      noteGeneratorProvider.select((s) => s.currentNoteName),
    );
    final currentBeat = ref.watch(
      noteGeneratorProvider.select((s) => s.currentBeat),
    );
    final beatsPerNote = ref.watch(
      noteGeneratorProvider.select((s) => s.beatsPerNote),
    );
    final isPlaying = ref.watch(
      noteGeneratorProvider.select((s) => s.isPlaying),
    );

    return Column(
      children: [
        const SizedBox(height: 12),
        Text(
          noteName,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(beatsPerNote, (i) {
            final isActive = isPlaying && i == currentBeat;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SizedBox(
                width: 16,
                height: 16,
                child: Center(
                  child: CircleAvatar(
                    radius: isActive ? 8 : 6,
                    backgroundColor: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

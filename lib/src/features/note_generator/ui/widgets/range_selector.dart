import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/midi_utils.dart';
import '../../domain/instrument_preset.dart';
import '../../domain/note_range.dart';
import '../../providers/note_generator_providers.dart';

class RangeSelector extends ConsumerWidget {
  const RangeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rangeLow = ref.watch(noteGeneratorProvider.select((s) => s.rangeLow));
    final rangeHigh = ref.watch(
      noteGeneratorProvider.select((s) => s.rangeHigh),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Range', style: Theme.of(context).textTheme.titleMedium),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(midiNoteToName(rangeLow)),
              Text(midiNoteToName(rangeHigh)),
            ],
          ),
        ),
        RangeSlider(
          values: RangeValues(rangeLow.toDouble(), rangeHigh.toDouble()),
          min: NoteRange.pianoLow.toDouble(),
          max: NoteRange.pianoHigh.toDouble(),
          divisions: NoteRange.pianoHigh - NoteRange.pianoLow,
          labels: RangeLabels(
            midiNoteToName(rangeLow),
            midiNoteToName(rangeHigh),
          ),
          onChanged: (values) {
            ref
                .read(noteGeneratorProvider.notifier)
                .setRange(values.start.round(), values.end.round());
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            children: InstrumentPreset.values.map((preset) {
              final isSelected =
                  rangeLow == preset.range.low &&
                  rangeHigh == preset.range.high;
              return ChoiceChip(
                label: Text(preset.label),
                selected: isSelected,
                onSelected: (_) {
                  ref
                      .read(noteGeneratorProvider.notifier)
                      .applyPreset(preset.range);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

import 'note_range.dart';

enum InstrumentPreset {
  grandPiano('Grand Piano', NoteRange(low: 21, high: 108)),
  tenorSax('Tenor Sax', NoteRange(low: 44, high: 76)),
  altoFlute('Alto Flute', NoteRange(low: 55, high: 91));

  const InstrumentPreset(this.label, this.range);

  final String label;
  final NoteRange range;
}

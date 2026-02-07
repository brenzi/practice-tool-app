class NoteRange {
  const NoteRange({required this.low, required this.high})
    : assert(low <= high),
      assert(low >= pianoLow),
      assert(high <= pianoHigh);

  final int low;
  final int high;

  int get span => high - low;

  bool contains(int midiNote) => midiNote >= low && midiNote <= high;

  static const int pianoLow = 21;
  static const int pianoHigh = 108;
  static const piano = NoteRange(low: pianoLow, high: pianoHigh);
}

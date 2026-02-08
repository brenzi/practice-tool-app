enum ScaleType {
  major('Major', [0, 2, 4, 5, 7, 9, 11]),
  minor('Minor', [0, 2, 3, 5, 7, 8, 10]),
  melodicMinor('Melodic Minor', [0, 2, 3, 5, 7, 9, 11]),
  harmonicMinor('Harmonic Minor', [0, 2, 3, 5, 7, 8, 11]),
  wholeTone('Whole Tone', [0, 2, 4, 6, 8, 10]),
  halfWholeTone('Half-Whole Tone', [0, 1, 3, 4, 6, 7, 9, 10]);

  const ScaleType(this.label, this.intervals);

  final String label;
  final List<int> intervals;
}

Set<int> scalePitchClasses(int root, ScaleType scale) {
  return scale.intervals.map((i) => (root + i) % 12).toSet();
}

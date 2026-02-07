import 'dart:async';
import 'dart:math';

import 'audio_service.dart';

class SequencerService {
  SequencerService({required this.audioService});

  final AudioService audioService;
  final _random = Random();

  // Mutable parameters — changed at any time
  int bpm = 80;
  int beatsPerNote = 4;
  int rangeLow = 21;
  int rangeHigh = 108;
  bool pianoEnabled = true;
  bool metronomeEnabled = true;

  // Callbacks for UI
  void Function(int midiNote)? onNewNote;
  void Function(int beatInMeasure)? onBeat;

  // Internal state
  Timer? _timer;
  int _nextBeatIndex = 0;
  int _nextBeatTimeMs = 0;
  int? _currentPianoNote;

  static const _timerIntervalMs = 20;
  static const _noteReleaseGapMs = 50;

  bool get isPlaying => _timer != null;

  double get _beatIntervalMs => 60000.0 / bpm;

  Future<void> start() async {
    _nextBeatTimeMs = DateTime.now().millisecondsSinceEpoch;
    _nextBeatIndex = 0;
    _currentPianoNote = null;
    _timer = Timer.periodic(
      const Duration(milliseconds: _timerIntervalMs),
      (_) => _tick(),
    );
    await _tick();
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    if (_currentPianoNote != null) {
      await audioService.stopPianoNote(_currentPianoNote!);
      _currentPianoNote = null;
    }
    await audioService.stopAllNotes();
  }

  Future<void> _tick() async {
    final now = DateTime.now().millisecondsSinceEpoch;

    while (_nextBeatTimeMs <= now) {
      final beatInMeasure = _nextBeatIndex % beatsPerNote;

      if (metronomeEnabled) {
        await audioService.playClick();
      }

      if (beatInMeasure == 0 && pianoEnabled) {
        // Stop previous note
        if (_currentPianoNote != null) {
          await audioService.stopPianoNote(_currentPianoNote!);
        }
        final note = _randomNote();
        await audioService.playPianoNote(note);
        _currentPianoNote = note;
        onNewNote?.call(note);
      }

      onBeat?.call(beatInMeasure);

      _nextBeatIndex++;
      _nextBeatTimeMs += _beatIntervalMs.round();
    }

    // Stop piano note shortly before next note beat
    if (_currentPianoNote != null) {
      final msUntilNextNote =
          _nextBeatTimeMs -
          now -
          (_nextBeatIndex % beatsPerNote) * _beatIntervalMs.round();
      if (msUntilNextNote <= _noteReleaseGapMs &&
          _nextBeatIndex % beatsPerNote == 0) {
        await audioService.stopPianoNote(_currentPianoNote!);
        _currentPianoNote = null;
      }
    }
  }

  int _randomNote() {
    final span = rangeHigh - rangeLow;
    if (span <= 0) return rangeLow;
    return rangeLow + _random.nextInt(span + 1);
  }
}

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
  int _nextBeatTickMs = 0;

  static const _timerIntervalMs = 50;
  static const _lookaheadMs = 200;
  static const _noteReleaseGapMs = 50;

  bool get isPlaying => _timer != null;

  double get _beatIntervalMs => 60000.0 / bpm;

  Future<void> start() async {
    final currentTick = await audioService.getCurrentTick();
    _nextBeatTickMs = currentTick;
    _nextBeatIndex = 0;
    _timer = Timer.periodic(
      const Duration(milliseconds: _timerIntervalMs),
      (_) => _tick(),
    );
    await _tick();
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    await audioService.stopAllNotes();
  }

  Future<void> _tick() async {
    final currentTick = await audioService.getCurrentTick();
    final horizon = currentTick + _lookaheadMs;

    while (_nextBeatTickMs <= horizon) {
      final beatInMeasure = _nextBeatIndex % beatsPerNote;

      if (metronomeEnabled) {
        await audioService.scheduleClick(_nextBeatTickMs);
      }

      if (beatInMeasure == 0 && pianoEnabled) {
        final note = _randomNote();
        final duration = (_beatIntervalMs * beatsPerNote - _noteReleaseGapMs)
            .round();
        await audioService.scheduleNote(_nextBeatTickMs, note, duration);
        onNewNote?.call(note);
      }

      onBeat?.call(beatInMeasure);

      _nextBeatIndex++;
      _nextBeatTickMs += _beatIntervalMs.round();
    }
  }

  int _randomNote() {
    final span = rangeHigh - rangeLow;
    if (span <= 0) return rangeLow;
    return rangeLow + _random.nextInt(span + 1);
  }
}

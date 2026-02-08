import 'dart:async';

import '../../../common/audio_service.dart';
import '../../../common/click_sounds.dart';

class MetronomeSequencerService {
  MetronomeSequencerService({required this.audioService});

  final AudioService audioService;

  int bpm = 120;
  int beatsPerBar = 4;
  List<bool> beatToggles = [true, true, true, true];
  List<bool> offbeatToggles = [false, false, false, false];
  bool accentBeat1 = true;
  int barsPerSection = 0;

  void Function(int beat, int bar)? onBeat;

  Timer? _timer;
  int _nextBeatIndex = 0;
  int _nextBeatTickMs = 0;

  static const _timerIntervalMs = 50;
  static const _lookaheadMs = 200;

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
      final beatInBar = _nextBeatIndex % beatsPerBar;
      final barIndex = barsPerSection > 0
          ? (_nextBeatIndex ~/ beatsPerBar) % barsPerSection
          : 0;

      if (beatInBar < beatToggles.length && beatToggles[beatInBar]) {
        if (barsPerSection > 0 && beatInBar == 0 && barIndex == 0) {
          await audioService.scheduleClick(
            _nextBeatTickMs,
            key: ClickSound.section,
          );
        } else if (accentBeat1 && beatInBar == 0) {
          await audioService.scheduleClick(
            _nextBeatTickMs,
            key: ClickSound.accent,
          );
        } else {
          await audioService.scheduleClick(_nextBeatTickMs);
        }
      }

      if (beatInBar < offbeatToggles.length && offbeatToggles[beatInBar]) {
        final halfTick = _nextBeatTickMs + (_beatIntervalMs / 2).round();
        await audioService.scheduleClick(
          halfTick,
          key: ClickSound.regular,
          velocity: 70,
        );
      }

      onBeat?.call(beatInBar, barIndex);

      _nextBeatIndex++;
      _nextBeatTickMs += _beatIntervalMs.round();
    }
  }
}

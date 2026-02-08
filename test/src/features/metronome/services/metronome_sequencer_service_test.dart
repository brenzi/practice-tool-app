import 'package:flutter_test/flutter_test.dart';
import 'package:jazz_practice_tools/src/common/click_sounds.dart';
import 'package:jazz_practice_tools/src/features/metronome/services/metronome_sequencer_service.dart';

import '../../../common/mock_audio_service.dart';

void main() {
  late MockAudioService mockAudio;
  late MetronomeSequencerService sequencer;

  setUp(() {
    mockAudio = MockAudioService();
    sequencer = MetronomeSequencerService(audioService: mockAudio);
  });

  List<int> clickTicks() =>
      mockAudio.scheduledClicks.map((c) => c.tick).toList();
  List<int> clickKeys() => mockAudio.scheduledClicks.map((c) => c.key).toList();
  List<int> clickVelocities() =>
      mockAudio.scheduledClicks.map((c) => c.velocity).toList();

  group('basic scheduling', () {
    test('schedules clicks on start', () async {
      sequencer.bpm = 120;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      expect(mockAudio.scheduledClicks, isNotEmpty);
    });

    test('schedules correct number of beats in lookahead', () async {
      sequencer.bpm = 600; // 100ms per beat
      sequencer.beatsPerBar = 4;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // 200ms lookahead, 100ms interval → ticks at 0, 100, 200
      expect(clickTicks(), equals([0, 100, 200]));
    });

    test('stop calls stopAllNotes', () async {
      mockAudio.currentTick = 0;
      await sequencer.start();
      await sequencer.stop();
      expect(mockAudio.stopAllCalled, isTrue);
    });
  });

  group('beat toggles', () {
    test('disabled beat produces no click', () async {
      sequencer.bpm = 120; // 500ms → only 1 beat in lookahead
      sequencer.beatsPerBar = 4;
      sequencer.beatToggles = [false, true, true, true];
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // Beat 0 is off → no click
      expect(mockAudio.scheduledClicks, isEmpty);
    });

    test('toggled beats produce clicks selectively', () async {
      sequencer.bpm = 600; // 100ms per beat
      sequencer.beatsPerBar = 4;
      sequencer.beatToggles = [true, false, true, false];
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // Beats at 0ms(on), 100ms(off), 200ms(on)
      expect(clickTicks(), equals([0, 200]));
    });
  });

  group('offbeats', () {
    test('offbeat adds click at half interval', () async {
      sequencer.bpm = 120; // 500ms per beat
      sequencer.beatsPerBar = 4;
      sequencer.offbeatToggles = [true, false, false, false];
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // Beat at 0, offbeat at 250
      expect(clickTicks(), equals([0, 250]));
    });

    test('offbeat has reduced velocity', () async {
      sequencer.bpm = 120;
      sequencer.beatsPerBar = 4;
      sequencer.offbeatToggles = [true, false, false, false];
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // First click (beat) = 100 velocity, second (offbeat) = 70
      expect(clickVelocities(), equals([100, 70]));
    });
  });

  group('accents', () {
    test('accent on beat 1 uses accent key', () async {
      sequencer.bpm = 120;
      sequencer.beatsPerBar = 4;
      sequencer.accentBeat1 = true;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      expect(clickKeys().first, ClickSound.accent);
    });

    test('no accent uses regular key', () async {
      sequencer.bpm = 120;
      sequencer.beatsPerBar = 4;
      sequencer.accentBeat1 = false;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      expect(clickKeys().first, ClickSound.regular);
    });
  });

  group('section markers', () {
    test('section start uses section key', () async {
      sequencer.bpm = 120;
      sequencer.beatsPerBar = 1; // 1 beat per bar
      sequencer.barsPerSection = 4;
      sequencer.accentBeat1 = true;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // Beat 0 = bar 0, beat 0 → section marker
      expect(clickKeys().first, ClickSound.section);
    });

    test('section overrides accent', () async {
      sequencer.bpm = 600; // 100ms per beat
      sequencer.beatsPerBar = 2;
      sequencer.barsPerSection = 2;
      sequencer.accentBeat1 = true;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // Beat 0 (bar 0, beat 0) = section
      // Beat 1 (bar 0, beat 1) = regular
      // Beat 2 (bar 1, beat 0) = accent (not section start)
      expect(clickKeys()[0], ClickSound.section);
      expect(clickKeys()[1], ClickSound.regular);
      expect(clickKeys()[2], ClickSound.accent);
    });
  });

  group('onBeat callback', () {
    test('fires with beat and bar indices', () async {
      sequencer.bpm = 600;
      sequencer.beatsPerBar = 2;
      sequencer.barsPerSection = 2;
      mockAudio.currentTick = 0;

      final beats = <int>[];
      final bars = <int>[];
      sequencer.onBeat = (beat, bar) {
        beats.add(beat);
        bars.add(bar);
      };

      await sequencer.start();
      await sequencer.stop();

      // 3 beats in 200ms lookahead at 100ms interval
      expect(beats, equals([0, 1, 0]));
      expect(bars, equals([0, 0, 1]));
    });
  });
}

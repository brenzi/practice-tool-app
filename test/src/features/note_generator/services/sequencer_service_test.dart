import 'package:flutter_test/flutter_test.dart';
import 'package:jazz_practice_tools/src/features/note_generator/services/audio_service.dart';
import 'package:jazz_practice_tools/src/features/note_generator/services/sequencer_service.dart';

class MockAudioService extends AudioService {
  MockAudioService() : super(midiPro: null);

  int currentTick = 0;
  final scheduledNotes = <({int tick, int midiNote, int durationMs})>[];
  final scheduledClicks = <int>[];
  bool stopAllCalled = false;

  @override
  Future<void> init() async {}

  @override
  Future<int> getCurrentTick() async => currentTick;

  @override
  Future<void> scheduleNote(int tick, int midiNote, int durationMs) async {
    scheduledNotes.add((
      tick: tick,
      midiNote: midiNote,
      durationMs: durationMs,
    ));
  }

  @override
  Future<void> scheduleClick(int tick) async {
    scheduledClicks.add(tick);
  }

  @override
  Future<void> stopAllNotes() async {
    stopAllCalled = true;
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  late MockAudioService mockAudio;
  late SequencerService sequencer;

  setUp(() {
    mockAudio = MockAudioService();
    sequencer = SequencerService(audioService: mockAudio);
  });

  group('scheduling logic', () {
    test('start triggers immediate scheduling', () async {
      sequencer.bpm = 120;
      sequencer.beatsPerNote = 2;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // First tick should schedule beats within lookahead window
      expect(mockAudio.scheduledClicks, isNotEmpty);
      expect(mockAudio.scheduledNotes, isNotEmpty);
    });

    test('schedules beats within lookahead window', () async {
      sequencer.bpm = 120; // 500ms per beat
      sequencer.beatsPerNote = 4;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // At 120 BPM, beat interval is 500ms. Lookahead is 200ms.
      // So only beat at tick 0 should be scheduled (next at 500 > 200).
      expect(mockAudio.scheduledClicks, equals([0]));
      expect(mockAudio.scheduledNotes.length, 1);
      expect(mockAudio.scheduledNotes.first.tick, 0);
    });

    test('schedules multiple beats when interval is short', () async {
      sequencer.bpm = 600; // 100ms per beat
      sequencer.beatsPerNote = 4;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // At 600 BPM, beat interval is 100ms. Lookahead is 200ms.
      // Beats at 0, 100, 200 should be scheduled.
      expect(mockAudio.scheduledClicks, equals([0, 100, 200]));
      // Piano note only on beat 0 (beatInMeasure == 0)
      expect(mockAudio.scheduledNotes.length, 1);
    });

    test('random notes are within range', () async {
      sequencer.bpm = 600;
      sequencer.beatsPerNote = 1;
      sequencer.rangeLow = 60;
      sequencer.rangeHigh = 72;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      for (final note in mockAudio.scheduledNotes) {
        expect(note.midiNote, greaterThanOrEqualTo(60));
        expect(note.midiNote, lessThanOrEqualTo(72));
      }
    });

    test('piano disabled means no notes scheduled', () async {
      sequencer.bpm = 600;
      sequencer.beatsPerNote = 1;
      sequencer.pianoEnabled = false;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      expect(mockAudio.scheduledNotes, isEmpty);
    });

    test('metronome disabled means no clicks scheduled', () async {
      sequencer.bpm = 600;
      sequencer.beatsPerNote = 1;
      sequencer.metronomeEnabled = false;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      expect(mockAudio.scheduledClicks, isEmpty);
    });

    test('stop calls stopAllNotes', () async {
      mockAudio.currentTick = 0;
      await sequencer.start();
      await sequencer.stop();
      expect(mockAudio.stopAllCalled, isTrue);
    });

    test('onNewNote callback fires on note beats', () async {
      sequencer.bpm = 600;
      sequencer.beatsPerNote = 1;
      mockAudio.currentTick = 0;
      final notes = <int>[];
      sequencer.onNewNote = notes.add;

      await sequencer.start();
      await sequencer.stop();

      expect(notes, isNotEmpty);
    });

    test('note duration accounts for release gap', () async {
      sequencer.bpm = 120; // 500ms per beat
      sequencer.beatsPerNote = 2; // note spans 1000ms
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // Duration should be beatsPerNote * beatInterval - releaseGap
      // = 2 * 500 - 50 = 950ms
      expect(mockAudio.scheduledNotes.first.durationMs, 950);
    });
  });
}

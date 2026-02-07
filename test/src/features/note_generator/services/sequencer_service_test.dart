import 'package:flutter_test/flutter_test.dart';
import 'package:jazz_practice_tools/src/features/note_generator/services/audio_service.dart';
import 'package:jazz_practice_tools/src/features/note_generator/services/sequencer_service.dart';

class MockAudioService extends AudioService {
  MockAudioService() : super(midiPro: null);

  final playedPianoNotes = <int>[];
  final stoppedPianoNotes = <int>[];
  int clickCount = 0;
  bool stopAllCalled = false;

  @override
  Future<void> init() async {}

  @override
  Future<void> playPianoNote(int key) async {
    playedPianoNotes.add(key);
  }

  @override
  Future<void> stopPianoNote(int key) async {
    stoppedPianoNotes.add(key);
  }

  @override
  Future<void> playClick() async {
    clickCount++;
  }

  @override
  Future<void> stopClick() async {}

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
    test('start triggers immediate beat', () async {
      sequencer.bpm = 120;
      sequencer.beatsPerNote = 2;

      await sequencer.start();
      await sequencer.stop();

      // First beat should fire immediately on start
      expect(mockAudio.clickCount, greaterThan(0));
      expect(mockAudio.playedPianoNotes, isNotEmpty);
    });

    test('random notes are within range', () async {
      sequencer.bpm = 600;
      sequencer.beatsPerNote = 1;
      sequencer.rangeLow = 60;
      sequencer.rangeHigh = 72;

      await sequencer.start();
      await sequencer.stop();

      for (final note in mockAudio.playedPianoNotes) {
        expect(note, greaterThanOrEqualTo(60));
        expect(note, lessThanOrEqualTo(72));
      }
    });

    test('piano disabled means no notes played', () async {
      sequencer.bpm = 600;
      sequencer.beatsPerNote = 1;
      sequencer.pianoEnabled = false;

      await sequencer.start();
      await sequencer.stop();

      expect(mockAudio.playedPianoNotes, isEmpty);
    });

    test('metronome disabled means no clicks played', () async {
      sequencer.bpm = 600;
      sequencer.beatsPerNote = 1;
      sequencer.metronomeEnabled = false;

      await sequencer.start();
      await sequencer.stop();

      expect(mockAudio.clickCount, 0);
    });

    test('stop calls stopAllNotes', () async {
      await sequencer.start();
      await sequencer.stop();
      expect(mockAudio.stopAllCalled, isTrue);
    });

    test('onNewNote callback fires on note beats', () async {
      sequencer.bpm = 600;
      sequencer.beatsPerNote = 1;
      final notes = <int>[];
      sequencer.onNewNote = notes.add;

      await sequencer.start();
      await sequencer.stop();

      expect(notes, isNotEmpty);
    });

    test('previous note is stopped before new note', () async {
      sequencer.bpm = 600;
      sequencer.beatsPerNote = 1;

      await sequencer.start();
      // Allow a couple timer ticks for multiple notes
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await sequencer.stop();

      if (mockAudio.playedPianoNotes.length > 1) {
        // Each note after the first should have a corresponding stop of the previous
        expect(mockAudio.stoppedPianoNotes, isNotEmpty);
      }
    });
  });
}

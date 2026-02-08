import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jazz_practice_tools/src/features/note_generator/providers/note_generator_providers.dart';
import 'package:jazz_practice_tools/src/features/note_generator/services/audio_service.dart';
import 'package:jazz_practice_tools/src/features/note_generator/ui/note_generator_screen.dart';

class FakeAudioService extends AudioService {
  FakeAudioService() : super(midiPro: null);

  @override
  Future<void> init() async {}
  @override
  Future<int> getCurrentTick() async => 0;
  @override
  Future<void> scheduleNote(int tick, int midiNote, int durationMs) async {}
  @override
  Future<void> scheduleClick(int tick) async {}
  @override
  Future<void> stopAllNotes() async {}
  @override
  Future<void> dispose() async {}
}

Widget _buildTestApp() {
  return ProviderScope(
    overrides: [audioServiceProvider.overrideWithValue(FakeAudioService())],
    child: MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const NoteGeneratorScreen(),
    ),
  );
}

void main() {
  testWidgets('renders without crash', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    expect(find.text('Note Generator'), findsOneWidget);
  });

  testWidgets('shows initial note display', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    expect(find.text('---'), findsOneWidget);
  });

  testWidgets('shows Play button', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    expect(find.text('Play'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  testWidgets('shows toggle buttons for Piano and Metro', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    expect(find.text('Piano'), findsOneWidget);
    expect(find.text('Metro'), findsOneWidget);
  });

  testWidgets('shows range section with presets', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    expect(find.text('Range'), findsOneWidget);
    expect(find.text('Grand Piano'), findsOneWidget);
    expect(find.text('Tenor Sax'), findsOneWidget);
    expect(find.text('Alto Flute'), findsOneWidget);
  });

  testWidgets('shows tempo section', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    expect(find.text('Tempo 80'), findsOneWidget);
    expect(find.text('Beats'), findsOneWidget);
  });

  testWidgets('shows interval and scale controls', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    expect(find.text('Interval'), findsOneWidget);
    expect(find.text('Scale'), findsOneWidget);
    expect(find.text('chromatic'), findsOneWidget);
  });

  testWidgets('tap Play toggles to Stop and back', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.tap(find.text('Play'));
    await tester.pump();
    expect(find.text('Stop'), findsOneWidget);
    expect(find.byIcon(Icons.stop), findsOneWidget);
    // Stop to clean up timer
    await tester.tap(find.text('Stop'));
    await tester.pump();
    expect(find.text('Play'), findsOneWidget);
  });
}

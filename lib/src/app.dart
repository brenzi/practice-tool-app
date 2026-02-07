import 'package:flutter/material.dart';

import 'features/note_generator/ui/note_generator_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jazz Practice Tools',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const NoteGeneratorScreen(),
    );
  }
}

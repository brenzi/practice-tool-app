import 'package:flutter/material.dart';

import 'widgets/note_display.dart';
import 'widgets/range_selector.dart';
import 'widgets/tempo_controls.dart';
import 'widgets/transport_controls.dart';

class NoteGeneratorScreen extends StatelessWidget {
  const NoteGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Note Generator')),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            NoteDisplay(),
            Divider(),
            RangeSelector(),
            SizedBox(height: 16),
            Divider(),
            TempoControls(),
            SizedBox(height: 16),
            Divider(),
            TransportControls(),
          ],
        ),
      ),
    );
  }
}

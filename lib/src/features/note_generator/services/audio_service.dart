import 'package:flutter_midi_pro/flutter_midi_pro.dart';

class AudioService {
  AudioService({MidiPro? midiPro}) : _midi = midiPro ?? MidiPro();

  final MidiPro _midi;
  late int _sfId;
  late int _clickFluidSfId;

  static const _pianoChannel = 0;
  static const _clickChannel = 1;
  static const _clickKey = 76; // woodblock

  Future<void> init() async {
    _sfId = await _midi.loadSoundfontAsset(
      assetPath: 'assets/sf2/SalamanderC5Light.sf2',
    );

    _clickFluidSfId = await _midi.loadSoundfontAssetIntoSynth(
      existingSfId: _sfId,
      assetPath: 'assets/sf2/click.sf2',
    );

    await _midi.selectInstrumentBySfontId(
      sfId: _sfId,
      channel: _clickChannel,
      fluidSfontId: _clickFluidSfId,
      bank: 0,
      program: 0,
    );
  }

  Future<void> playPianoNote(int key) => _midi.playNote(
    channel: _pianoChannel,
    key: key,
    velocity: 100,
    sfId: _sfId,
  );

  Future<void> stopPianoNote(int key) =>
      _midi.stopNote(channel: _pianoChannel, key: key, sfId: _sfId);

  Future<void> playClick() => _midi.playNote(
    channel: _clickChannel,
    key: _clickKey,
    velocity: 100,
    sfId: _sfId,
  );

  Future<void> stopClick() =>
      _midi.stopNote(channel: _clickChannel, key: _clickKey, sfId: _sfId);

  Future<void> stopAllNotes() => _midi.stopAllNotes(sfId: _sfId);

  Future<void> dispose() => _midi.dispose();
}

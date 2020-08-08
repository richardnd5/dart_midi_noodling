import '../remove_melody_from_piano.dart';
import '../remove_melody_two.dart';
import 'create_midi_file.dart';
import '../add_block_chords.dart';
import '../clean_up_pedal.dart';
import '../parse_piano_track.dart';

void main() {
  // runMidiProgram();
  // var midiFile = removeMelody("melodyOfTheDay");
  var midiFile = parsePianoTrack();
  // var midiFile = createMidiFile();

  // var midiFile = addBlockChords();
  // var midiFile = cleanUpPedal();
  writeToFile('parsedPianoTrack', midiFile);
}

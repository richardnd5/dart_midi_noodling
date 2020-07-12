import '../remove_melody_from_piano.dart';
import '../remove_melody_two.dart';

void main() {
  // runMidiProgram();
  var midiFile = removeMelody();
  writeToFile('removedMelody', midiFile);
}

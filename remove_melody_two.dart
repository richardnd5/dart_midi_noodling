import 'package:dart_midi/dart_midi.dart';
import 'remove_melody_from_piano.dart';

MidiFile removeMelody() {
  String allPianoFileName = "midiWithSustain";

  MidiFile allPiano = getMidiFileFrom(allPianoFileName);

  List<MidiEventWithGlobalTime> eventMap = [];

  int globalTime = 0;

  allPiano.tracks.first.forEach((element) {
    globalTime += element.deltaTime;

    eventMap.add(MidiEventWithGlobalTime(
      globalTime: globalTime,
      event: element,
    ));
  });

  eventMap.forEach((element) {
    print(element.globalTime);
  });
}

// separate file
class MidiEventWithGlobalTime {
  int globalTime;
  MidiEvent event;

  MidiEventWithGlobalTime({
    int globalTime,
    MidiEvent event,
  }) {
    this.globalTime = globalTime;
    this.event = event;
  }
}

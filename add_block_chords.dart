import 'package:dart_midi/dart_midi.dart';
import 'remove_melody_from_piano.dart';
import 'remove_melody_two.dart';

MidiFile addBlockChords() {
  String allPianoFileName = "pedalTest";
  // String rightHandFileName = "1rightHand";

  MidiFile allPiano = getMidiFileFrom(allPianoFileName);
  // MidiFile rightHand = getMidiFileFrom(rightHandFileName);

  var pianoEventList = getEventsWithGlobalTime(allPiano.tracks.first);

  List<MidiEventWithGlobalTime> heldNotesTempStore = [];
  List<List<MidiEventWithGlobalTime>> listOfChordCollections = [];

  List<MidiEventWithGlobalTime> tempNotesInPedal = [];
  bool pedalDown = false;

  pianoEventList.forEach((element) {
    switch (element.type) {
      case MidiEventGlobalType.noteOn:
        pedalDown
            ? tempNotesInPedal.add(element)
            : heldNotesTempStore.add(element);
        break;
      case MidiEventGlobalType.noteOff:
        heldNotesTempStore.removeWhere(
            (e) => e.noteOnEvent.noteNumber == element.noteOffEvent.noteNumber);
        break;
      case MidiEventGlobalType.controller:
        if (element.controllerEvent.value == 127) {
          tempNotesInPedal.addAll(heldNotesTempStore);
          heldNotesTempStore = [];
          pedalDown = true;
        } else if (element.controllerEvent.value == 0) {
          listOfChordCollections.add(tempNotesInPedal);
          tempNotesInPedal = [];
          pedalDown = false;
        }
        break;
      default:
        break;
    }
  });

  List<List<MidiEventWithGlobalTime>> organizedByGlobalTime =
      listOfChordCollections.map((chord) {
    chord.sort((a, b) => a.globalTime.compareTo(b.globalTime));

    if (chord.length == 0) {
      return chord;
    }
    // int firstGlobalTime = chord.first.globalTime;
    chord.forEach((note) {
      if (note == chord.first) {
        note.event.deltaTime = note.globalTime;
      }
      if (note != chord.first) {
        note.event.deltaTime = 0;
      }
    });

    return chord;
  }).toList();

  List<MidiEvent> chordTrack = [];

  organizedByGlobalTime.forEach((chord) {
    List<NoteOffEvent> noteOffsToAdd = [];
    chord.asMap().forEach((index, note) {
      chordTrack.add(note.event);

      NoteOffEvent noteOff = NoteOffEvent();
      noteOff.noteNumber = note.noteOnEvent.noteNumber;
      noteOff.velocity = 0;
      noteOff.deltaTime = 100;
      noteOff.channel = 0;
      noteOff.type = "noteOff";
      noteOff.useByte9ForNoteOff = false;
      noteOff.running = false;
      noteOff.meta = false;
      noteOff.byte9 = true;

      noteOffsToAdd.add(noteOff);

      if (note == chord.last) {
        chordTrack.addAll(noteOffsToAdd);
      }
    });
  });

  MidiHeader header = new MidiHeader(
    framesPerSecond: allPiano.header.framesPerSecond,
    ticksPerBeat: allPiano.header.ticksPerBeat,
    ticksPerFrame: allPiano.header.ticksPerFrame,
    numTracks: 2,
    format: allPiano.header.format,
    timeDivision: allPiano.header.timeDivision,
  );

  // var trackEvents = pianoEventList.map((e) => e.event).toList();

  MidiFile midiFile = MidiFile([chordTrack], header);

  return midiFile;
}

import 'package:dart_midi/dart_midi.dart';
import 'remove_melody_from_piano.dart';

bool noteEventMatches(
  MidiEventWithGlobalTime rightHand,
  MidiEventWithGlobalTime allPiano,
) {
  return rightHand.globalTime == allPiano.globalTime &&
      rightHand.number == allPiano.number;
}

MidiFile removeMelody() {
  String allPianoFileName = "Untitled";
  // String rightHandFileName = "1rightHand";

  MidiFile allPiano = getMidiFileFrom(allPianoFileName);
  // MidiFile rightHand = getMidiFileFrom(rightHandFileName);

  var pianoEventList = getEventsWithGlobalTime(allPiano.tracks[2]);
  var rightHandEventList = getEventsWithGlobalTime(allPiano.tracks[1]);

  List<MidiEventWithGlobalTime> leftHandEventList = [];

  MidiEventWithGlobalTime previousNotAddedNote;
  for (var i = 0; i < pianoEventList.length; i++) {
    var currentPianoEvent = pianoEventList[i];

    if (currentPianoEvent.type == MidiEventGlobalType.noteOn ||
        currentPianoEvent.type == MidiEventGlobalType.noteOff) {
      var rightHandNotes = rightHandEventList.where((currentPianoEvent) =>
          currentPianoEvent.noteOnEvent != null ||
          currentPianoEvent.noteOffEvent != null);

      var allMatching = rightHandNotes
          .where(
            (rightHand) =>
                rightHand.globalTime == currentPianoEvent.globalTime &&
                rightHand.number == currentPianoEvent.number,
          )
          .toList();

      if (allMatching.length == 1) {
        if (i < pianoEventList.length) {
          pianoEventList[i + 1].event.deltaTime +=
              currentPianoEvent.event.deltaTime;
          previousNotAddedNote = currentPianoEvent;
        }
      } else {
        leftHandEventList.add(currentPianoEvent);
        previousNotAddedNote = null;
      }
    } else {
      leftHandEventList.add(currentPianoEvent);
      previousNotAddedNote = null;
    }
  }

  MidiHeader header = new MidiHeader(
    framesPerSecond: allPiano.header.framesPerSecond,
    ticksPerBeat: allPiano.header.ticksPerBeat,
    ticksPerFrame: allPiano.header.ticksPerFrame,
    numTracks: 1,
    format: allPiano.header.format,
    timeDivision: allPiano.header.timeDivision,
  );

  var trackEvents = leftHandEventList.map((e) => e.event).toList();

  MidiFile midiFile = MidiFile([trackEvents], header);

  return midiFile;
}

List<MidiEventWithGlobalTime> getEventsWithGlobalTime(
    List<MidiEvent> midiEvents) {
  List<MidiEventWithGlobalTime> eventMap = [];

  int globalTime = 0;

  midiEvents.forEach((element) {
    globalTime += element.deltaTime;

    switch (element.type) {
      case 'noteOn':
        NoteOnEvent event = element;
        eventMap.add(MidiEventWithGlobalTime(
            globalTime: globalTime,
            event: element,
            number: event.noteNumber,
            type: MidiEventGlobalType.noteOn,
            noteOnEvent: event));
        break;
      case 'noteOff':
        NoteOffEvent event = element;
        eventMap.add(MidiEventWithGlobalTime(
            globalTime: globalTime,
            event: element,
            number: event.noteNumber,
            type: MidiEventGlobalType.noteOff,
            noteOffEvent: event));

        break;
      case 'controller':
        eventMap.add(MidiEventWithGlobalTime(
            globalTime: globalTime,
            event: element,
            type: MidiEventGlobalType.controller,
            controllerEvent: element as ControllerEvent));

        break;
      default:
        eventMap.add(MidiEventWithGlobalTime(
          globalTime: globalTime,
          event: element,
          type: MidiEventGlobalType.other,
        ));
        break;
    }
  });
  return eventMap;
}

// separate file
class MidiEventWithGlobalTime {
  int globalTime;
  MidiEvent event;
  int number;

  NoteOnEvent noteOnEvent;
  NoteOffEvent noteOffEvent;
  ControllerEvent controllerEvent;
  MidiEventGlobalType type;

  MidiEventWithGlobalTime({
    int globalTime,
    MidiEvent event,
    int number,
    NoteOnEvent noteOnEvent,
    NoteOffEvent noteOffEvent,
    ControllerEvent controllerEvent,
    MidiEventGlobalType type,
  }) {
    this.globalTime = globalTime;
    this.event = event;
    this.number = number;

    this.noteOnEvent = noteOnEvent;
    this.noteOffEvent = noteOffEvent;
    this.controllerEvent = controllerEvent;
    this.type = type;
  }
}

// separate file
enum MidiEventGlobalType { noteOn, noteOff, controller, other }

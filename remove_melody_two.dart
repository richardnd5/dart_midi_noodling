import 'package:dart_midi/dart_midi.dart';
import 'remove_melody_from_piano.dart';

MidiFile removeMelody() {
  String allPianoFileName = "allPianoLong";
  String rightHandFileName = "rightHandLong";

  MidiFile allPiano = getMidiFileFrom(allPianoFileName);
  MidiFile rightHand = getMidiFileFrom(rightHandFileName);

  var pianoEventList = getEventsWithGlobalTime(allPiano.tracks.first);
  var rightHandEventList = getEventsWithGlobalTime(rightHand.tracks.first);

  List<MidiEventWithGlobalTime> leftHandEventList = [];

  for (var i = 0; i < pianoEventList.length; i++) {
    var element = pianoEventList[i];
    if (element.type == MidiEventGlobalType.noteOn ||
        element.type == MidiEventGlobalType.noteOff) {
      if (rightHandEventList.firstWhere(
              (rightHand) => rightHand.globalTime == element.globalTime,
              orElse: () => null) !=
          null) {
        if (i < pianoEventList.length) {
          pianoEventList[i + 1].event.deltaTime +=
              pianoEventList[i].event.deltaTime;
        }
      } else {
        leftHandEventList.add(element);
      }
    } else {
      leftHandEventList.add(element);
    }
  }

  MidiHeader header = allPiano.header;

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

    MidiEventGlobalType type;
    switch (element.type) {
      case 'noteOn':
        type = MidiEventGlobalType.noteOn;
        break;
      case 'noteOff':
        type = MidiEventGlobalType.noteOff;
        break;
      case 'controller':
        type = MidiEventGlobalType.controller;
        break;
      default:
        type = MidiEventGlobalType.other;
        break;
    }

    eventMap.add(MidiEventWithGlobalTime(
      globalTime: globalTime,
      event: element,
      type: type,
    ));
  });
  return eventMap;
}

// separate file
class MidiEventWithGlobalTime {
  int globalTime;
  MidiEvent event;
  MidiEventGlobalType type;

  MidiEventWithGlobalTime({
    int globalTime,
    MidiEvent event,
    MidiEventGlobalType type,
  }) {
    this.globalTime = globalTime;
    this.event = event;
    this.type = type;
  }
}

// separate file
enum MidiEventGlobalType { noteOn, noteOff, controller, other }

import 'package:dart_midi/dart_midi.dart';
import 'remove_melody_from_piano.dart';
import 'remove_melody_two.dart';
import 'enums/midi_event_with_global_type.dart';
import 'models/midi_event_with_global_time.dart';

MidiFile cleanUpPedal() {
  String allPianoFileName = "fiveNoteScale60";
  MidiFile allPiano = getMidiFileFrom(allPianoFileName);
  var pianoEventList = getEventsWithGlobalTime(allPiano.tracks.first);

  pianoEventList.asMap().forEach((index, element) {
    print('index: $index ${element.type}');
  });

  for (var i = 0; i < pianoEventList.length; i++) {
    MidiEventWithGlobalTime event = pianoEventList[i];

    int startOfPedalSet;
    int endOfPedalSet;

    if (event.type == MidiEventGlobalType.controller &&
        event.controllerEvent.value == 127) {
      endOfPedalSet = i;
      startOfPedalSet = pianoEventList.lastIndexWhere(
          (element) =>
              element.type == MidiEventGlobalType.controller &&
              element.controllerEvent.value == 40,
          i);

      List<MidiEventWithGlobalTime> eventSubList =
          pianoEventList.sublist(startOfPedalSet, endOfPedalSet + 1);

// find a set that's not all controller events
      if (eventSubList.firstWhere(
              (element) => element.type != MidiEventGlobalType.controller,
              orElse: () => null) ==
          null) {
        var deltaSum = eventSubList
            .map((e) => e.event.deltaTime)
            .reduce((value, element) => value + element);

        for (var index = startOfPedalSet; index < endOfPedalSet + 1; index++) {
          if (pianoEventList[index].type == MidiEventGlobalType.controller &&
              index != endOfPedalSet) {
            pianoEventList[index].event.deltaTime = -1;
          } else if (pianoEventList[index].type ==
                  MidiEventGlobalType.controller &&
              index == endOfPedalSet) {
            pianoEventList[index].event.deltaTime = deltaSum;
          }
        }
      } else {
        MidiEventWithGlobalTime lastPedalDown = pianoEventList[endOfPedalSet];
        int earliestSavedNoteIndex = i;

        for (var index = endOfPedalSet; index >= startOfPedalSet; index--) {
          var event = pianoEventList[index];

          if (event.type == MidiEventGlobalType.controller &&
              event != lastPedalDown) {
            pianoEventList[earliestSavedNoteIndex].event.deltaTime +=
                event.event.deltaTime;
            pianoEventList[index].event.deltaTime = -1;
          } else if (event.type != MidiEventGlobalType.controller) {
            earliestSavedNoteIndex = index;
          }
        }
      }
      // remove extra pedalOff Pedals
    } else if (event.type == MidiEventGlobalType.controller &&
        event.controllerEvent.value == 0) {
      endOfPedalSet = i;
      startOfPedalSet = pianoEventList.lastIndexWhere(
          (element) =>
              element.type == MidiEventGlobalType.controller &&
              element.controllerEvent.value == 104,
          i);

      List<MidiEventWithGlobalTime> eventSubList =
          pianoEventList.sublist(startOfPedalSet, endOfPedalSet + 1);

// find a set that's not all controller events
      if (eventSubList.firstWhere(
              (element) => element.type != MidiEventGlobalType.controller,
              orElse: () => null) ==
          null) {
        var deltaSum = eventSubList
            .map((e) => e.event.deltaTime)
            .reduce((value, element) => value + element);

        for (var index = startOfPedalSet; index < endOfPedalSet + 1; index++) {
          if (pianoEventList[index].type == MidiEventGlobalType.controller &&
              index != endOfPedalSet) {
            pianoEventList[index].event.deltaTime = -1;
          } else {
            if (pianoEventList[index].type == MidiEventGlobalType.controller &&
                index == endOfPedalSet) {
              pianoEventList[index].event.deltaTime = deltaSum;
            }
          }
        }
      } else {
        MidiEventWithGlobalTime lastPedalDown = pianoEventList[endOfPedalSet];
        int earliestSavedNoteIndex = i;

        for (var index = endOfPedalSet; index >= startOfPedalSet; index--) {
          var event = pianoEventList[index];

          if (event.type == MidiEventGlobalType.controller &&
              event != lastPedalDown) {
            pianoEventList[earliestSavedNoteIndex].event.deltaTime +=
                event.event.deltaTime;
            pianoEventList[index].event.deltaTime = -1;
          } else if (event.type != MidiEventGlobalType.controller) {
            earliestSavedNoteIndex = index;
          }
        }
      }
    }
  }
  pianoEventList.removeWhere((value) =>
      value.event.deltaTime == -1 &&
      value.type == MidiEventGlobalType.controller);

  pianoEventList.forEach((element) {
    if (element.event.deltaTime < 0) {
      print('ut oh $element');
    }
  });

  MidiHeader header = new MidiHeader(
    framesPerSecond: allPiano.header.framesPerSecond,
    ticksPerBeat: allPiano.header.ticksPerBeat,
    ticksPerFrame: allPiano.header.ticksPerFrame,
    numTracks: allPiano.header.numTracks,
    format: allPiano.header.format,
    timeDivision: allPiano.header.timeDivision,
  );

  var trackEvents = pianoEventList.map((e) => e.event).toList();

  MidiFile midiFile = MidiFile([trackEvents], header);

  return midiFile;
}

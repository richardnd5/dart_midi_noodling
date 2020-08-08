import 'dart:io';

import 'package:dart_midi/dart_midi.dart';
import 'custom_midi_event.dart';

void runMidiProgram() {
  String allPianoFileName = "newTestAllPiano";
  String rightHandFileName = "newTestRightHand";

  MidiFile allPiano = getMidiFileFrom(allPianoFileName);
  MidiFile rightHand = getMidiFileFrom(rightHandFileName);
  MidiFile midiFileWithSustain = getMidiFileFrom("midiWithSustain");
  var justSustain = getMidiFileFrom("justSustain").tracks.first;

  var midiWithSustain = midiFileWithSustain.tracks.first;

  midiWithSustain.forEach((element) {
    if (element.type == 'controller') {
      ControllerEvent controller = element;
      // print(
      //     'controller type: ${controller.controllerType} value: ${controller.value} delta time: ${controller.deltaTime}');
    }
  });

  Map<int, MidiEvent> pianoTrack = allPiano.tracks.first.asMap();
  Map<int, MidiEvent> rightHandTrack = rightHand.tracks.first.asMap();
  Map<int, MidiEvent> midiWithSustainTrack =
      midiFileWithSustain.tracks.first.asMap();

  var rightHandNoteEvents = getNoteDurationEventsFromMidiTrack(rightHandTrack);
  var allPianoNoteEvents = getNoteDurationEventsFromMidiTrack(pianoTrack);
  var midiFileWithSustainEvents =
      getNoteDurationEventsFromMidiTrack(midiWithSustainTrack);

  // rightHandTrack.forEach((index, element) {
  //   if (element.type == 'noteOn') {
  //     NoteOnEvent noteOn = element;

  //     pianoTrack.removeWhere((key, value) {
  //       if (element.type == 'noteOn') {
  //         NoteOnEvent pianoTrackNoteOn = element;
  //         if (pianoTrackNoteOn.noteNumber == noteOn.noteNumber) {
  //           return true;
  //         }
  //       }
  //       return false;
  //     });
  //   } else if (element.type == 'noteOff') {
  //     NoteOffEvent noteOff = element;

  //     pianoTrack.removeWhere((key, value) {
  //       if (element.type == 'noteOff') {
  //         NoteOffEvent pianoTrackNoteOff = element;
  //         if (pianoTrackNoteOff.noteNumber == noteOff.noteNumber) {
  //           return true;
  //         }
  //       }
  //       return false;
  //     });
  //   }
  // });

  // List<MidiEvent> pianoTrackEventList =
  //     pianoTrack.entries.map((e) => e.value).toList();

  // var midiFile = MidiFile([pianoTrackEventList], allPiano.header);

  var midiFile = createMidiFileFromCustomEvents(midiFileWithSustainEvents);
  writeToFile(allPianoFileName, midiFile);
}

MidiFile createMidiFileFromCustomEvents(List<dynamic> midiEvents) {
  var midiWithSustain = getMidiFileFrom("midiWithSustain");
  ChannelPrefixEvent channelPrefixEvent = midiWithSustain.tracks.first
      .firstWhere((element) => element.type == 'channelPrefix');
  TrackNameEvent trackNameEvent = midiWithSustain.tracks.first
      .firstWhere((element) => element.type == 'trackName');
  InstrumentNameEvent instrumentNameEvent = midiWithSustain.tracks.first
      .firstWhere((element) => element.type == 'instrumentName');
  TimeSignatureEvent timeSignatureEvent = midiWithSustain.tracks.first
      .firstWhere((element) => element.type == 'timeSignature');
  KeySignatureEvent keySignatureEvent = midiWithSustain.tracks.first
      .firstWhere((element) => element.type == 'keySignature');
  SmpteOffsetEvent smpteOffsetEvent = midiWithSustain.tracks.first
      .firstWhere((element) => element.type == 'smpteOffset');
  SetTempoEvent setTempoEvent = midiWithSustain.tracks.first
      .firstWhere((element) => element.type == 'setTempo');
  EndOfTrackEvent endOfTrackEvent = midiWithSustain.tracks.first
      .firstWhere((element) => element.type == 'endOfTrack');

  List<MidiEvent> trackEvents = [];

  midiEvents.sort((a, b) => a.startTime.compareTo(b.startTime));

  // midiEvents.asMap().forEach((index, element) {
  //   midiEvents[index].deltaTime = midiEvents[index].;
  //   print(element.startTime);
  // });

  midiEvents.forEach((element) {
    if (element) {
      CustomMidiEvent event = element;

      NoteOnEvent noteOn = new NoteOnEvent();
      noteOn.noteNumber = event.noteNumber;
      noteOn.velocity = event.noteOnVelocity;
      noteOn.channel = event.channel;
      noteOn.deltaTime = event.startTime;

      trackEvents.add(noteOn);

      NoteOffEvent noteOff = new NoteOffEvent();
      noteOff.noteNumber = event.noteNumber;
      noteOff.deltaTime = event.startTime + event.duration;
      noteOff.channel = event.channel;

      trackEvents.add(noteOff);
    }

    // else if (element is CustomControllerEvent) {
    //   CustomControllerEvent event = element;

    //   ControllerEvent controller = new ControllerEvent();
    //   controller.deltaTime = event.deltaTime;
    //   controller.controllerType = event.controllerType;
    //   controller.value = event.value;

    //   trackEvents.add(controller);
    // }
  });

  List<MidiEvent> track = [
    channelPrefixEvent,
    trackNameEvent,
    instrumentNameEvent,
    timeSignatureEvent,
    keySignatureEvent,
    smpteOffsetEvent,
    setTempoEvent,
    ...trackEvents,
    endOfTrackEvent
  ];
  MidiHeader header = midiWithSustain.header;

  MidiFile midiFile = MidiFile([track], header);

  return midiFile;
}

List<CustomMidiEvent> getNoteDurationEventsFromMidiTrack(
    Map<int, MidiEvent> midiTrack) {
  List<CustomMidiEvent> eventList = [];

  int globalTime = 0;
  midiTrack.forEach((index, value) {
    globalTime += value.deltaTime;
    if (value.type == 'noteOn') {
      NoteOnEvent noteOn = value;

      int duration = 0;

      for (var subIndex = index; subIndex < midiTrack.length; subIndex++) {
        duration += midiTrack[subIndex].deltaTime;
        if (midiTrack[subIndex].type == 'noteOff') {
          NoteOffEvent noteOff = midiTrack[subIndex];

          if (noteOff.noteNumber == noteOn.noteNumber) {
            var event = CustomMidiEvent(
                type: MidiEventType.note,
                startTime: globalTime,
                endTime: globalTime + duration,
                noteOnIndex: index,
                noteOnDeltaTime: noteOn.deltaTime,
                noteNumber: noteOn.noteNumber,
                noteOnVelocity: noteOn.velocity,
                noteOffIndex: subIndex,
                noteOffDeltaTime: noteOff.deltaTime,
                channel: noteOn.channel,
                duration: duration);

            eventList.add(event);
            break;
          }
        }
      }
    } else if (value.type == 'controller') {
      ControllerEvent controller = value;
      var event = CustomMidiEvent(
          type: MidiEventType.controller,
          startTime: globalTime,
          controllerType: controller.controllerType,
          controllerValue: controller.value,
          controllerDeltaTime: controller.deltaTime);
      eventList.add(event);
    }
  });
  return eventList;
}

MidiFile getMidiFileFrom(String fileName) {
  var file = File('./$fileName.mid');
  return MidiParser().parseMidiFromFile(file);
}

void writeToFile(String fileName, MidiFile midiFile) {
  var writer = MidiWriter();
  writer.writeMidiToFile(midiFile, File('../$fileName.mid'));
}

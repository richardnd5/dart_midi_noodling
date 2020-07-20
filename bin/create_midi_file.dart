import 'package:dart_midi/dart_midi.dart';
import 'dart:math';

MidiFile createMidiFile() {
  print('printing!');

  MidiHeader header = createHeader();

  var noteList = createNotes();
  var totalDelta = noteList.map((e) => e.deltaTime).reduce((a, b) => a + b);

  List<MidiEvent> track1 = [
    ...createStartOfTrack(),
    ...noteList,
    createEndOfTrackEvent(totalDelta),
  ];

  List<MidiEvent> timeAndKey = [
    createTimeSignatureEvent(),
    createKeySignatureEvent(),
    createSmpteOffsetEvent(),
    createSetTempoEvent(),
    createEndOfTrackEvent(totalDelta)
  ];

  MidiFile midiFile = MidiFile([timeAndKey, track1], header);

  return midiFile;
}

NoteOnEvent createNoteOn({int number, int velocity, int delta}) {
  NoteOnEvent noteOn = NoteOnEvent();
  noteOn.deltaTime = delta;
  noteOn.noteNumber = number;
  noteOn.velocity = velocity;
  noteOn.channel = 0;
  noteOn.useByte9ForNoteOff = false;
  noteOn.running = false;
  noteOn.meta = false;
  noteOn.byte9 = false;
  noteOn.type = 'noteOn';

  return noteOn;
}

NoteOffEvent createNoteOff({int number, int delta}) {
  NoteOffEvent noteOff = NoteOffEvent();
  noteOff.deltaTime = delta;
  noteOff.noteNumber = number;
  noteOff.channel = 0;
  noteOff.byte9 = true;
  noteOff.meta = false;
  noteOff.useByte9ForNoteOff = false;
  noteOff.type = 'noteOff';
  noteOff.velocity = 0;

  return noteOff;
}

List<MidiEvent> createNotes() {
  List<MidiEvent> events = [];
  for (var i = 0; i < 100; i++) {
    List<int> cScale = [60, 62, 64, 65, 67, 69, 71, 72];

    int randomInt = cScale[randomInRange(0, cScale.length)];

    NoteOnEvent noteOn = createNoteOn(
      number: randomInt,
      velocity: 90,
      delta: 0,
    );

    events.add(noteOn);

    NoteOnEvent harmony = createNoteOn(
      number: randomInt,
      velocity: 90,
      delta: 0,
    );

    events.add(noteOn);

    NoteOffEvent noteOff = createNoteOff(
      number: randomInt,
      delta: 480,
    );

    events.add(noteOff);
  }

  return events;
}

MidiHeader createHeader() {
  return MidiHeader(
    framesPerSecond: null,
    ticksPerBeat: 480,
    ticksPerFrame: null,
    numTracks: 1,
    format: 1,
    timeDivision: null,
  );
}

TimeSignatureEvent createTimeSignatureEvent() {
  var event = TimeSignatureEvent();
  event.deltaTime = 0;
  event.numerator = 4;
  event.denominator = 4;
  event.meta = false;
  event.metronome = 24;
  event.running = false;
  event.thirtyseconds = 8;
  event.useByte9ForNoteOff = false;
  event.type = 'timeSignature';

  return event;
}

KeySignatureEvent createKeySignatureEvent() {
  var event = KeySignatureEvent();
  event.deltaTime = 0;
  event.key = 0;
  event.scale = 0;
  event.meta = false;
  event.running = false;
  event.useByte9ForNoteOff = false;
  event.type = 'keySignature';

  return event;
}

SmpteOffsetEvent createSmpteOffsetEvent() {
  var event = SmpteOffsetEvent();
  event.deltaTime = 0;
  event.frame = 0;
  event.frameRate = 25;
  event.hour = 1;
  event.min = 0;
  event.sec = 0;
  event.subFrame = 0;
  event.type = 'smpteOffset';

  event.meta = false;
  event.running = false;
  event.useByte9ForNoteOff = false;

  return event;
}

SetTempoEvent createSetTempoEvent() {
  var event = SetTempoEvent();
  event.deltaTime = 0;
  event.microsecondsPerBeat = 637580;

  event.meta = false;
  event.running = false;
  event.useByte9ForNoteOff = false;
  event.type = 'setTempo';

  return event;
}

List<MidiEvent> createStartOfTrack() {
  return [
    createChannelPrefix(),
    createTrackNameEvent('Piano Track'),
    createInstrumentNameEvent('Piano'),
  ];
}

ChannelPrefixEvent createChannelPrefix() {
  var prefix = ChannelPrefixEvent();
  prefix.channel = 0;
  prefix.deltaTime = 0;
  prefix.meta = false;
  prefix.running = false;
  prefix.useByte9ForNoteOff = false;
  prefix.type = 'channelPrefix';

  return prefix;
}

TrackNameEvent createTrackNameEvent(String trackName) {
  var event = TrackNameEvent();
  event.text = trackName;
  event.deltaTime = 0;
  event.meta = false;
  event.running = false;
  event.useByte9ForNoteOff = false;
  event.type = 'trackName';

  return event;
}

InstrumentNameEvent createInstrumentNameEvent(String name) {
  InstrumentNameEvent event = InstrumentNameEvent();
  event.text = name;
  event.deltaTime = 0;
  event.meta = false;
  event.running = false;
  event.useByte9ForNoteOff = false;
  event.type = 'instrumentName';

  return event;
}

EndOfTrackEvent createEndOfTrackEvent(int totalDelta) {
  EndOfTrackEvent event = EndOfTrackEvent();
  event.deltaTime = totalDelta;
  event.meta = false;
  event.running = false;
  event.useByte9ForNoteOff = false;
  event.type = 'endOfTrack';
  return event;
}

int randomInRange(int min, int max) {
  return min + new Random().nextInt(max - min);
}

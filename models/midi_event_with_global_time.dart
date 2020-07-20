import 'package:dart_midi/dart_midi.dart';
import '../enums/midi_event_with_global_type.dart';

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
